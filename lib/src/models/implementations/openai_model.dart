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
    this.outputType,
    this.systemPrompt,
  }) : _client = OpenAIClient(apiKey: apiKey);

  final String modelName;
  final OpenAIClient _client;
  final Map<String, dynamic>? outputType;
  final String? systemPrompt;

  @override
  Future<AgentResponse> run(String prompt) async {
    final res = await _client.createChatCompletion(
      request: CreateChatCompletionRequest(
        model: ChatCompletionModel.modelId(modelName),
        responseFormat:
            outputType != null
                ? ResponseFormat.jsonSchema(
                  jsonSchema: _schemaObjectFrom(outputType!),
                )
                : null,
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

  JsonSchemaObject _schemaObjectFrom(
    Map<String, dynamic> schema, {
    String name = 'response',
    bool strict = true,
  }) => JsonSchemaObject(
    name: name,
    description: schema['description'],
    schema: schema,
    strict: strict,
  );
}
