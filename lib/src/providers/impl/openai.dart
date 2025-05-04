import 'package:openai_dart/openai_dart.dart';

import '../../agent/agent_response.dart';
import '../../config/impl/openai_config.dart';
import '../provider.dart';

class OpenAiProvider extends Provider<OpenAiConfig> {
  OpenAiProvider({required super.agentConfig, required super.providerConfig})
    : _client = OpenAIClient(apiKey: providerConfig.apiKey);

  final OpenAIClient _client;

  @override
  Future<AgentResponse> run(String prompt) async {
    final res = await _client.createChatCompletion(
      request: CreateChatCompletionRequest(
        model: ChatCompletionModel.modelId(providerConfig.modelName),
        responseFormat:
            agentConfig.outputFromJson != null
                ? ResponseFormat.jsonSchema(
                  jsonSchema: _schemaObjectFrom(agentConfig.outputType!),
                )
                : null,
        messages: [
          if (agentConfig.systemPrompt != null)
            ChatCompletionMessage.system(content: agentConfig.systemPrompt!),
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
