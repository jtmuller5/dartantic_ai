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
    required this.modelName,
    Map<String, dynamic>? outputType,
    this.systemPrompt,
    this.tools,
  }) : _client = openai.OpenAIClient(apiKey: apiKey),
       responseFormat =
           outputType != null
               ? openai.ResponseFormat.jsonSchema(
                 jsonSchema: _schemaObjectFrom(outputType),
               )
               : null;

  /// The name of the OpenAI model to use.
  final String modelName;
  final openai.OpenAIClient _client;

  /// The response format configuration for the model.
  ///
  /// When set, it configures the model to return responses in JSON format
  /// that match the provided schema.
  final openai.ResponseFormat? responseFormat;

  /// The system prompt used for this model instance.
  ///
  /// This provides context and instructions to guide the model's responses.
  final String? systemPrompt;

  /// The tools to use for this model instance.
  final Iterable<Tool>? tools;

  /// Runs the given [prompt] through the OpenAI model and returns the response.
  ///
  /// Returns an [AgentResponse] containing the text from the model's response.
  @override
  Future<AgentResponse> run(String prompt) async {
    final res = await _client.createChatCompletion(
      request: openai.CreateChatCompletionRequest(
        model: openai.ChatCompletionModel.modelId(modelName),
        responseFormat: responseFormat,
        messages: [
          if (systemPrompt != null)
            openai.ChatCompletionMessage.system(content: systemPrompt!),
          openai.ChatCompletionMessage.user(
            content: openai.ChatCompletionUserMessageContent.string(prompt),
          ),
        ],
      ),
    );

    return AgentResponse(output: res.choices.first.message.content ?? '');
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
