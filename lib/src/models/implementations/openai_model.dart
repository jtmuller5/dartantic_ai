import 'package:openai_dart/openai_dart.dart'
    show
        ChatCompletionMessage,
        ChatCompletionModel,
        ChatCompletionUserMessageContent,
        CreateChatCompletionRequest,
        JsonSchemaObject,
        OpenAIClient,
        ResponseFormat;

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
  }) : _client = OpenAIClient(apiKey: apiKey),
       responseFormat =
           outputType != null
               ? ResponseFormat.jsonSchema(
                 jsonSchema: _schemaObjectFrom(outputType),
               )
               : null;

  /// The name of the OpenAI model to use.
  final String modelName;
  final OpenAIClient _client;

  /// The response format configuration for the model.
  ///
  /// When set, it configures the model to return responses in JSON format
  /// that match the provided schema.
  final ResponseFormat? responseFormat;

  /// The system prompt used for this model instance.
  ///
  /// This provides context and instructions to guide the model's responses.
  final String? systemPrompt;

  /// Runs the given [prompt] through the OpenAI model and returns the response.
  ///
  /// Returns an [AgentResponse] containing the text from the model's response.
  @override
  Future<AgentResponse> run(String prompt) async {
    final res = await _client.createChatCompletion(
      request: CreateChatCompletionRequest(
        model: ChatCompletionModel.modelId(modelName),
        responseFormat: responseFormat,
        messages: [
          if (systemPrompt != null)
            ChatCompletionMessage.system(content: systemPrompt!),
          ChatCompletionMessage.user(
            content: ChatCompletionUserMessageContent.string(prompt),
          ),
        ],
      ),
    );

    return AgentResponse(output: res.choices.first.message.content ?? '');
  }

  static JsonSchemaObject _schemaObjectFrom(
    Map<String, dynamic> jsonSchema, {
    String name = 'response',
    bool strict = true,
  }) => JsonSchemaObject(
    name: name,
    description: jsonSchema['description'],
    schema: {...jsonSchema, 'additionalProperties': false},
    strict: strict,
  );
}
