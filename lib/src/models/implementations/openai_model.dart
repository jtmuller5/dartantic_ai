import 'dart:convert';
import 'dart:developer' as dev;

import 'package:openai_dart/openai_dart.dart' as openai;

import '../../agent/agent.dart';
import '../interface/model.dart';

/// Implementation of [Model] that uses OpenAI's API.
///
/// This model handles interaction with OpenAI models, supporting both
/// standard text responses and structured JSON schema responses.
class OpenAiModel extends Model {
  /// Creates a new [OpenAiModel] with the given parameters.
  ///
  /// The [apiKey] is the API key to use for authentication.
  /// The [modelName] is the name of the OpenAI model to use.
  /// The [outputType] is an optional JSON schema for structured outputs.
  /// The [systemPrompt] is an optional system prompt to use.
  OpenAiModel({
    required String apiKey,
    required String modelName,
    Map<String, dynamic>? outputType,
    String? systemPrompt,
    Iterable<Tool>? tools,
  }) : _tools = tools,
       _systemPrompt = systemPrompt,
       _modelName = modelName,
       _client = openai.OpenAIClient(apiKey: apiKey),
       _responseFormat =
           outputType != null
               ? openai.ResponseFormat.jsonSchema(
                 jsonSchema: _schemaObjectFrom(outputType),
               )
               : null;

  final openai.OpenAIClient _client;
  final String _modelName;
  final openai.ResponseFormat? _responseFormat;
  final String? _systemPrompt;
  final Iterable<Tool>? _tools;

  /// Runs the given [prompt] through the OpenAI model and returns the response.
  ///
  /// Returns an [AgentResponse] containing the text from the model's response.
  /// If tool calls are present, they will be executed and the results will be
  /// included in the final response.
  @override
  Future<AgentResponse> run(String prompt) async {
    final messages = <openai.ChatCompletionMessage>[
      if (_systemPrompt != null)
        openai.ChatCompletionMessage.system(content: _systemPrompt),
      openai.ChatCompletionMessage.user(
        content: openai.ChatCompletionUserMessageContent.string(prompt),
      ),
    ];

    while (true) {
      final res = await _client.createChatCompletion(
        request: openai.CreateChatCompletionRequest(
          model: openai.ChatCompletionModel.modelId(_modelName),
          responseFormat: _responseFormat,
          messages: messages,
          tools:
              _tools
                  ?.map(
                    (tool) => openai.ChatCompletionTool(
                      type: openai.ChatCompletionToolType.function,
                      function: openai.FunctionObject(
                        name: tool.name,
                        description: tool.description,
                        parameters: tool.inputType ?? {},
                      ),
                    ),
                  )
                  .toList(),
        ),
      );

      final message = res.choices.first.message;
      messages.add(message);

      // If there are no tool calls, return the final response
      if (message.toolCalls == null || message.toolCalls!.isEmpty) {
        return AgentResponse(output: message.content ?? '');
      }

      // Handle tool calls
      for (final toolCall in message.toolCalls!) {
        final args =
            jsonDecode(toolCall.function.arguments) as Map<String, Object?>;
        final result = await _callTool(toolCall.function.name, args);

        // Add the tool response to the messages
        messages.add(
          openai.ChatCompletionMessage.tool(
            toolCallId: toolCall.id,
            content: jsonEncode(result),
          ),
        );
      }
    }
  }

  Future<Map<String, Object?>?> _callTool(
    String name,
    Map<String, Object?> args,
  ) async {
    Map<String, Object?>? result;
    try {
      // if the tool isn't found, return an error
      final tool = _tools?.where((t) => t.name == name).singleOrNull;
      result =
          tool == null
              ? {'error': 'Tool $name not found'}
              : await tool.onCall.call(args);
    } on Exception catch (ex) {
      // if the tool call throws an error, return the exception message
      result = {'error': ex.toString()};
    }

    dev.log('Tool: $name($args)= $result');
    return result;
  }

  static openai.JsonSchemaObject _schemaObjectFrom(
    Map<String, dynamic> jsonSchema, {
    String name = 'response',
    bool strict = true,
  }) => openai.JsonSchemaObject(
    name: name,
    description: jsonSchema['description'],
    schema: {...jsonSchema, 'additionalProperties': false},
    strict: strict,
  );
}
