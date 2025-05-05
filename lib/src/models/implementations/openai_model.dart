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

class OpenAiModel extends Model {
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

  final String modelName;
  final OpenAIClient _client;
  final ResponseFormat? responseFormat;
  final String? systemPrompt;

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
    schema: jsonSchema,
    strict: strict,
  );
}
