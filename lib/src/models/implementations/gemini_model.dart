import 'dart:convert';
import 'dart:typed_data';

import 'package:langchain/langchain.dart';
import 'package:langchain_google/langchain_google.dart';
import 'package:uuid/uuid.dart';

import '../../agent/agent_response.dart';
import '../../agent/embedding_type.dart';
import '../../agent/tool.dart' as ai_tool;
import '../../message.dart';
import '../../providers/interface/provider_caps.dart';
import '../../utils.dart';
import '../interface/model.dart';

/// Implementation of [Model] that uses Google's Gemini API via LangChain.
///
/// This model handles interaction with Gemini models, supporting both
/// standard text responses and tool calling.
class GeminiModel extends Model {
  /// Creates a new [GeminiModel] with the given parameters.
  ///
  /// The [modelName] is the name of the Gemini model to use.
  /// The [embeddingModelName] is the name of the Gemini embedding model to use.
  /// The [apiKey] is the API key to use for authentication.
  /// The [outputSchema] is an optional JSON schema for structured outputs.
  /// The [systemPrompt] is an optional system prompt to use.
  GeminiModel({
    required String apiKey,
    String? modelName,
    String? embeddingModelName,
    String? systemPrompt,
    Iterable<ai_tool.Tool>? tools,
    double? temperature,
  }) : generativeModelName = modelName ?? defaultModelName,
       embeddingModelName = embeddingModelName ?? defaultEmbeddingModelName,
       _tools = tools?.toList(),
       _systemPrompt = systemPrompt,
       _llm = ChatGoogleGenerativeAI(
         apiKey: apiKey,
         defaultOptions: ChatGoogleGenerativeAIOptions(
           model: modelName ?? defaultModelName,
           temperature: temperature ?? 0.7,
         ),
       ),
       _embeddings = GoogleGenerativeAIEmbeddings(
         apiKey: apiKey,
         model: embeddingModelName ?? defaultEmbeddingModelName,
       );

  /// The default model name to use if none is provided.
  static const defaultModelName = 'gemini-2.0-flash';

  /// The default embedding model name to use if none is provided.
  static const defaultEmbeddingModelName = 'text-embedding-004';

  final List<ai_tool.Tool>? _tools;
  final String? _systemPrompt;
  final ChatGoogleGenerativeAI _llm;
  final GoogleGenerativeAIEmbeddings _embeddings;

  @override
  final String generativeModelName;

  @override
  final String embeddingModelName;

  @override
  Stream<AgentResponse> runStream({
    required String prompt,
    required Iterable<Message> messages,
    required Iterable<Part> attachments,
  }) async* {
    log.finer(
      '[GeminiModel] Starting stream with ${messages.length} messages, '
      'prompt length: ${prompt.length}',
    );

    log.fine(
      '[GeminiModel] Starting stream with tools: ${_tools?.length ?? 0}',
    );

    if (_tools == null || _tools.isEmpty) {
      // No tools available, use simple LLM streaming
      yield* _streamWithoutTools(prompt, messages, attachments);
    } else {
      // Tools available, implement tool calling loop
      yield* _streamWithTools(prompt, messages, attachments);
    }
  }

  @override
  Future<Float64List> createEmbedding(
    String text, {
    EmbeddingType type = EmbeddingType.document,
  }) async {
    log.fine(
      '[GeminiModel] Creating embedding for text (length: ${text.length}, '
      'type: $type)',
    );

    try {
      // Use LangChain embeddings API
      // Note: LangChain Dart currently uses embedQuery for both document
      // and query types. This may be enhanced in future versions of the
      // LangChain Dart package
      final result = await _embeddings.embedQuery(text);
      
      log.fine(
        '[GeminiModel] Generated embedding with ${result.length} dimensions '
        'using LangChain',
      );
      return Float64List.fromList(result);
    } on Exception catch (e) {
      log.severe(
        '[GeminiModel] LangChain embedding failed: $e',
      );
      rethrow;
    }
  }

  /// Stream LLM response without tool calling
  Stream<AgentResponse> _streamWithoutTools(
    String prompt,
    Iterable<Message> messages,
    Iterable<Part> attachments,
  ) async* {
    // Convert messages to LangChain format
    final langchainMessages = _convertMessages(messages, prompt, attachments);
    
    // Create prompt value from messages
    final promptValue = PromptValue.chat(langchainMessages);
    
    final responseBuffer = StringBuffer();
    final stream = _llm.stream(promptValue);
    await for (final chunk in stream) {
      if (chunk.output.content.isNotEmpty) {
        responseBuffer.write(chunk.output.content);
        yield AgentResponse(output: chunk.output.content, messages: const []);
      }
    }

    // Final response with complete message history including AI response
    final aiResponse = responseBuffer.toString();
    yield AgentResponse(
      output: '',
      messages: _buildMessageHistory(messages, prompt, aiResponse),
    );
  }

  /// Stream LLM response with tool calling support
  Stream<AgentResponse> _streamWithTools(
    String prompt,
    Iterable<Message> messages,
    Iterable<Part> attachments,
  ) async* {
    final currentMessages = messages.toList();
    var currentPrompt = prompt;
    const maxIterations = 5; // Prevent infinite loops
    var iterations = 0;
    
    while (iterations < maxIterations) {
      iterations++;
      
      // Create tool calling prompt
      final toolDescriptions = _tools?.map((tool) => 
        '${tool.name}: ${tool.description ?? "No description"}')
        .join('\n') ?? '';
      
      final systemPrompt = '''
You are an AI assistant with access to tools. When you need to use a tool, respond with:
TOOL_CALL: {"name": "tool_name", "args": {"arg1": "value1", "arg2": "value2"}}

Available tools:
$toolDescriptions

User request: $currentPrompt''';
      
      // Convert messages to LangChain format
      final langchainMessages = _convertMessages(currentMessages, '', const []);
      
      // Add the system prompt and user prompt
      final promptValue = PromptValue.chat([
        ChatMessage.system(systemPrompt),
        ...langchainMessages,
        if (currentPrompt.isNotEmpty) ChatMessage.humanText(currentPrompt),
      ]);
      
      final responseBuffer = StringBuffer();
      final stream = _llm.stream(promptValue);
      await for (final chunk in stream) {
        if (chunk.output.content.isNotEmpty) {
          responseBuffer.write(chunk.output.content);
          yield AgentResponse(output: chunk.output.content, messages: const []);
        }
      }

      final aiResponse = responseBuffer.toString();
      
      // Check if the response contains a tool call
      final toolCall = _parseToolCall(aiResponse);
      if (toolCall != null) {
        // Execute the tool
        final toolResult = await _callTool(toolCall['name'], toolCall['args']);
        
        // Add proper ToolPart objects to message history
        final toolCallId = const Uuid().v4();
        currentMessages.add(Message.user([TextPart(currentPrompt)]));
        currentMessages.add(Message.model([
          TextPart(aiResponse),
          ToolPart(
            kind: ToolPartKind.call,
            id: toolCallId,
            name: toolCall['name'],
            arguments: toolCall['args'],
          ),
          ToolPart(
            kind: ToolPartKind.result,
            id: toolCallId,
            name: toolCall['name'],
            result: toolResult,
          ),
        ]));
        
        // Continue with next iteration, asking for final response
        currentPrompt = 'Please provide a final response based on the tool results.';
      } else {
        // No tool call found, this is the final response
        currentMessages.add(Message.user([TextPart(prompt)]));
        currentMessages.add(Message.model([TextPart(aiResponse)]));
        
        yield AgentResponse(
          output: '',
          messages: currentMessages,
        );
        return; // Exit the loop
      }
    }
    
    // If we reach here, we hit the max iterations limit
    log.warning('[GeminiModel] Max tool calling iterations reached');
    yield AgentResponse(
      output: '',
      messages: currentMessages,
    );
  }

  /// Parse tool call from LLM response
  Map<String, dynamic>? _parseToolCall(String response) {
    try {
      // Look for TOOL_CALL: pattern - use a simpler approach
      final lines = response.split('\n');
      for (final line in lines) {
        if (line.contains('TOOL_CALL:')) {
          // Extract everything after TOOL_CALL:
          final toolCallIndex = line.indexOf('TOOL_CALL:');
          final jsonStr = line.substring(toolCallIndex + 'TOOL_CALL:'.length).trim();
          
          // Check if we have a complete JSON object
          if (jsonStr.startsWith('{') && jsonStr.endsWith('}')) {
            try {
              final toolCall = json.decode(jsonStr) as Map<String, dynamic>;
              if (toolCall.containsKey('name')) {
                log.info('[GeminiModel] Successfully parsed tool call: ${toolCall['name']}');
                return {
                  'name': toolCall['name'] as String,
                  'args': toolCall['args'] as Map<String, dynamic>? ?? {},
                };
              }
            } catch (jsonError) {
              log.warning('[GeminiModel] JSON parsing failed for "$jsonStr": $jsonError');
            }
          }
        }
      }
      return null;
    } catch (e) {
      log.warning('[GeminiModel] Error parsing tool call: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> _callTool(
    String name,
    Map<String, dynamic> args,
  ) async {
    try {
      // if the tool isn't found, return an error
      final tool = _tools?.where((t) => t.name == name).singleOrNull;
      final result = tool == null
          ? {'error': 'Tool $name not found'}
          : await tool.onCall.call(args);
      log.fine('Tool: $name($args)= $result');
      return result;
    } on Exception catch (ex) {
      // if the tool call throws an error, return the exception message
      final result = {'error': ex.toString()};
      log.fine('Tool: $name($args)= $result');
      return result;
    }
  }

  /// Convert our message format to LangChain format
  List<ChatMessage> _convertMessages(
    Iterable<Message> messages,
    String prompt,
    Iterable<Part> attachments,
  ) {
    final result = <ChatMessage>[];

    // Add system prompt if available
    if (_systemPrompt != null && _systemPrompt.isNotEmpty) {
      result.add(ChatMessage.system(_systemPrompt));
    }

    // Convert existing messages
    for (final message in messages) {
      final content = _extractTextContent(message.parts);
      if (content.isNotEmpty) {
        switch (message.role) {
          case MessageRole.system:
            if (result.isEmpty) {
              result.add(ChatMessage.system(content));
            }
          case MessageRole.user:
            result.add(ChatMessage.humanText(content));
          case MessageRole.model:
            result.add(ChatMessage.ai(content));
        }
      }
    }

    // Add the current prompt
    final attachmentText = _extractAttachmentText(attachments);
    final fullPrompt = attachmentText.isEmpty
        ? prompt
        : '$prompt $attachmentText';
    if (fullPrompt.isNotEmpty) {
      result.add(ChatMessage.humanText(fullPrompt));
    }

    return result;
  }

  /// Extract text content from message parts
  String _extractTextContent(Iterable<Part> parts) {
    final textParts = <String>[];
    for (final part in parts) {
      if (part is TextPart) {
        textParts.add(part.text);
      } else if (part is LinkPart) {
        textParts.add('[Link: ${part.url}]');
      } else if (part is DataPart) {
        textParts.add('[Media: ${part.mimeType}]');
      }
      // Note: Tool parts are handled separately for tool calling
    }
    return textParts.join(' ');
  }

  /// Extract text representation of attachments
  String _extractAttachmentText(Iterable<Part> attachments) {
    final attachmentTexts = <String>[];
    for (final part in attachments) {
      if (part is TextPart) {
        attachmentTexts.add(part.text);
      } else if (part is LinkPart) {
        attachmentTexts.add('[Attachment: ${part.url}]');
      } else if (part is DataPart) {
        attachmentTexts.add('[Attachment: ${part.mimeType}]');
      }
    }
    return attachmentTexts.join(' ');
  }

  /// Build message history for response
  List<Message> _buildMessageHistory(
    Iterable<Message> previousMessages, 
    String prompt,
    [String? aiResponse]
  ) {
    final result = <Message>[...previousMessages];
    result.add(Message.user([TextPart(prompt)]));
    if (aiResponse != null && aiResponse.isNotEmpty) {
      result.add(Message.model([TextPart(aiResponse)]));
    }
    return result;
  }

  @override
  final Set<ProviderCaps> caps = ProviderCaps.all;
}
