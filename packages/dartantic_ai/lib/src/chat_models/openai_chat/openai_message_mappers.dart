import 'dart:convert';

import 'package:dartantic_interface/dartantic_interface.dart';
import 'package:logging/logging.dart';
import 'package:openai_dart/openai_dart.dart';

import '../helpers/message_part_helpers.dart';
import '../helpers/tool_id_helpers.dart';
import 'openai_chat_options.dart';
import 'openai_message_mappers_helpers.dart';

/// Logger for OpenAI message mapping operations.
final Logger _logger = Logger('dartantic.chat.mappers.openai');

/// Creates a [CreateChatCompletionRequest] from the given Message input.
CreateChatCompletionRequest createChatCompletionRequestFromMessages(
  List<ChatMessage> messages, {
  required String modelName,
  required OpenAIChatOptions? options,
  required OpenAIChatOptions defaultOptions,
  List<Tool>? tools,
  double? temperature,
}) {
  final messagesDtos = messages.toOpenAIMessages();
  final toolsDtos = tools
      ?.map(
        (tool) => ChatCompletionTool(
          type: ChatCompletionToolType.function,
          function: FunctionObject(
            name: tool.name,
            description: tool.description,
            parameters: tool.inputSchema.schemaMap as Map<String, dynamic>?,
            strict: null, // Explicitly pass null to override any defaults
          ),
        ),
      )
      .toList();

  final toolChoice = (toolsDtos?.isNotEmpty ?? false) ? null : null;

  return CreateChatCompletionRequest(
    model: ChatCompletionModel.modelId(modelName),
    messages: messagesDtos,
    tools: toolsDtos,
    toolChoice: toolChoice,
    frequencyPenalty:
        options?.frequencyPenalty ?? defaultOptions.frequencyPenalty,
    logitBias: options?.logitBias ?? defaultOptions.logitBias,
    maxCompletionTokens: options?.maxTokens ?? defaultOptions.maxTokens,
    n: options?.n ?? defaultOptions.n,
    presencePenalty: options?.presencePenalty ?? defaultOptions.presencePenalty,
    responseFormat: options?.responseFormat ?? defaultOptions.responseFormat,
    seed: options?.seed ?? defaultOptions.seed,
    stop: (options?.stop ?? defaultOptions.stop) != null
        ? ChatCompletionStop.listString(options?.stop ?? defaultOptions.stop!)
        : null,
    temperature:
        temperature ?? options?.temperature ?? defaultOptions.temperature,
    topP: options?.topP ?? defaultOptions.topP,
    parallelToolCalls:
        options?.parallelToolCalls ?? defaultOptions.parallelToolCalls,
    user: options?.user ?? defaultOptions.user,
    streamOptions: options?.streamOptions ?? defaultOptions.streamOptions,
  );
}

/// Extension on [List<Message>] to convert messages to OpenAI SDK messages.
extension MessageListToOpenAI on List<ChatMessage> {
  /// Converts this list of [ChatMessage]s to a list of
  /// [ChatCompletionMessage]s.
  List<ChatCompletionMessage> toOpenAIMessages() {
    _logger.fine('Converting $length messages to OpenAI format');

    // Expand messages to handle multiple tool results
    final expandedMessages = <ChatCompletionMessage>[];
    for (final message in this) {
      if (message.role == ChatMessageRole.user) {
        // Check if this is a tool result message with multiple results
        final toolResults = message.parts.toolResults;
        if (toolResults.length > 1) {
          // OpenAI requires separate tool messages for each result
          for (final toolResult in toolResults) {
            final content = ToolResultHelpers.serialize(toolResult.result);
            expandedMessages.add(
              ChatCompletionMessage.tool(
                toolCallId: toolResult.id,
                content: content,
              ),
            );
          }
        } else {
          // Single result or regular message
          expandedMessages.add(_mapMessage(message));
        }
      } else {
        // Non-user messages are mapped normally
        expandedMessages.add(_mapMessage(message));
      }
    }

    return expandedMessages;
  }

  ChatCompletionMessage _mapMessage(ChatMessage message) {
    switch (message.role) {
      case ChatMessageRole.system:
        return _mapSystemMessage(message);
      case ChatMessageRole.user:
        return _mapUserMessage(message);
      case ChatMessageRole.model:
        return _mapModelMessage(message);
    }
  }

  ChatCompletionMessage _mapSystemMessage(ChatMessage message) {
    // System messages should have a single text part
    final text = message.parts.text;
    return ChatCompletionMessage.system(content: text);
  }

  ChatCompletionMessage _mapUserMessage(ChatMessage message) {
    // Check if this is a tool result message
    final toolResults = message.parts.toolResults;

    if (toolResults.isNotEmpty) {
      // OpenAI expects separate tool messages for each result This should be
      // handled at a higher level, so here we just take the first
      final toolResult = toolResults.first;
      // ignore: avoid_dynamic_calls
      final content = ToolResultHelpers.serialize(toolResult.result);
      return ChatCompletionMessage.tool(
        toolCallId: toolResult.id,
        content: content,
      );
    }

    // Regular user message with content parts
    final contentParts = <ChatCompletionMessageContentPart>[];

    for (final part in message.parts) {
      switch (part) {
        case TextPart(:final text):
          contentParts.add(ChatCompletionMessageContentPartText(text: text));
        case DataPart(:final bytes, :final mimeType):
          if (mimeType.startsWith('image/')) {
            // Images: Use native image support for better quality
            final base64Data = base64.encode(bytes);
            contentParts.add(
              ChatCompletionMessageContentPartImage(
                imageUrl: ChatCompletionMessageImageUrl(
                  url: 'data:$mimeType;base64,$base64Data',
                ),
              ),
            );
          } else {
            // Non-images: Use dartantic_ai text format
            // This allows any MIME type to work with OpenAI
            final base64Data = base64.encode(bytes);
            contentParts.add(
              ChatCompletionMessageContentPartText(
                text: '[media: $mimeType] data:$mimeType;base64,$base64Data',
              ),
            );
          }
        case LinkPart(:final url):
          contentParts.add(
            ChatCompletionMessageContentPartImage(
              imageUrl: ChatCompletionMessageImageUrl(url: url.toString()),
            ),
          );
        case ToolPart():
          // Skip tool parts in user messages (handled above)
          break;
      }
    }

    if (contentParts.isEmpty) {
      return const ChatCompletionMessage.user(
        content: ChatCompletionUserMessageContentString(''),
      );
    } else if (contentParts.length == 1 &&
        contentParts.first is ChatCompletionMessageContentPartText) {
      final text =
          (contentParts.first as ChatCompletionMessageContentPartText).text;
      return ChatCompletionMessage.user(
        content: ChatCompletionUserMessageContentString(text),
      );
    } else {
      return ChatCompletionMessage.user(
        content: ChatCompletionUserMessageContent.parts(contentParts),
      );
    }
  }

  ChatCompletionMessage _mapModelMessage(ChatMessage message) {
    // Extract text content
    final textContent = message.parts.text;

    // Extract tool calls
    final toolCalls = message.parts.toolCalls
        .map(
          (p) => ChatCompletionMessageToolCall(
            id: p.id,
            type: ChatCompletionMessageToolCallType.function,
            function: ChatCompletionMessageFunctionCall(
              name: p.name,
              arguments: json.encode(p.arguments ?? {}),
            ),
          ),
        )
        .toList();

    return ChatCompletionMessage.assistant(
      content: textContent.isEmpty ? null : textContent,
      toolCalls: toolCalls.isEmpty ? null : toolCalls,
    );
  }
}

/// Converts OpenAI streaming response to Message. During streaming, only
/// returns text content. Tool calls are accumulated in the provided list but
/// not converted to ToolParts until streaming completes.
ChatMessage messageFromOpenAIStreamDelta(
  ChatCompletionStreamResponseDelta delta,
  List<StreamingToolCall> accumulatedToolCalls,
) {
  final parts = <Part>[];

  // Add text content if present
  if (delta.content != null && delta.content!.isNotEmpty) {
    parts.add(TextPart(delta.content!));
  }

  // Process tool calls - only accumulate, don't create ToolParts yet
  if (delta.toolCalls != null) {
    for (var i = 0; i < delta.toolCalls!.length; i++) {
      final toolCall = delta.toolCalls![i];

      // OpenAI streaming pattern:
      // - First chunk of a tool: has id, name, empty arguments
      // - Subsequent chunks: no id, no name, partial arguments We need to match
      //   by position when there's no ID

      if (toolCall.id != null) {
        // This is a new tool call with an ID
        // Google's OpenAI endpoint returns empty IDs, so generate one if needed
        final toolId = toolCall.id!.isEmpty
            ? ToolIdHelpers.generateToolCallId(
                toolName: toolCall.function?.name ?? '',
                providerHint: 'openai',
                index: i,
              )
            : toolCall.id!;
        accumulatedToolCalls.add(
          StreamingToolCall(
            id: toolId,
            name: toolCall.function?.name ?? '',
            argumentsJson: toolCall.function?.arguments ?? '',
          ),
        );
      } else if (accumulatedToolCalls.isNotEmpty) {
        // This is a continuation chunk - append to the last tool call
        final lastTool = accumulatedToolCalls.last;
        if (toolCall.function?.arguments != null) {
          lastTool.argumentsJson += toolCall.function!.arguments!;
        }
        // Update name if provided (shouldn't happen in practice)
        if (toolCall.function?.name != null &&
            toolCall.function!.name!.isNotEmpty) {
          lastTool.name = toolCall.function!.name!;
        }
      }
    }
  }

  // During streaming, only return text parts Tool parts will be created when
  // streaming completes
  return ChatMessage(role: ChatMessageRole.model, parts: parts);
}

/// Creates a complete message from accumulated tool calls. This is called after
/// streaming completes to create the final message with all tool calls properly
/// parsed.
ChatMessage createCompleteMessageWithTools(
  List<StreamingToolCall> accumulatedToolCalls, {
  String? accumulatedText,
}) {
  final parts = <Part>[];

  // Add accumulated text as a single TextPart if present
  if (accumulatedText != null && accumulatedText.isNotEmpty) {
    parts.add(TextPart(accumulatedText));
  }

  // Convert accumulated tool calls to ToolParts with parsed arguments
  for (final streamingCall in accumulatedToolCalls) {
    var arguments = <String, dynamic>{};
    final rawArgs = streamingCall.argumentsJson;

    // Parse the complete JSON arguments
    if (rawArgs.isNotEmpty) {
      final decoded = json.decode(rawArgs);
      if (decoded is Map<String, dynamic>) {
        arguments = decoded;
      } else if (decoded == null || decoded == 'null') {
        // Handle null case
        arguments = <String, dynamic>{};
      }
    }

    parts.add(
      ToolPart.call(
        id: streamingCall.id,
        name: streamingCall.name,
        arguments: arguments,
      ),
    );
  }

  return ChatMessage(role: ChatMessageRole.model, parts: parts);
}

/// Converts OpenAI completion response to Message.
ChatMessage messageFromOpenAIResponse(CreateChatCompletionResponse response) {
  if (response.choices.isEmpty) {
    return const ChatMessage(role: ChatMessageRole.model, parts: []);
  }

  final choice = response.choices.first;
  final message = choice.message;

  final parts = <Part>[];

  // Add text content
  if (message.content != null && message.content!.isNotEmpty) {
    parts.add(TextPart(message.content!));
  }

  // Add tool calls
  if (message.toolCalls != null) {
    for (final toolCall in message.toolCalls!) {
      var arguments = <String, dynamic>{};
      final rawArgs = toolCall.function.arguments;

      // Parse arguments, handling empty arguments case for streaming
      if (rawArgs.isNotEmpty) {
        final decoded = json.decode(rawArgs);
        if (decoded is Map<String, dynamic>) {
          arguments = decoded;
        } else if (decoded == null || decoded == 'null') {
          // Handle cases where decoded is null (e.g., Cohere sends "null" for
          // no params)
          arguments = <String, dynamic>{};
        }
      }

      parts.add(
        ToolPart.call(
          id: toolCall.id,
          name: toolCall.function.name,
          arguments: arguments,
        ),
      );
    }
  }

  return ChatMessage(role: ChatMessageRole.model, parts: parts);
}
