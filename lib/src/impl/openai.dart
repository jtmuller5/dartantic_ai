import 'package:openai_dart/openai_dart.dart';

import '../agent/agent_impl.dart';
import '../agent/agent_response.dart';
import '../model/language_model.dart';
import '../model/model_config.dart';
import '../platform/platform.dart' as platform;

class OpenAiConfig extends ModelConfig {
  OpenAiConfig({this.model = 'gpt-4o', String? apiKey})
    : apiKey = apiKey ?? platform.getEnv('OPENAI_API_KEY');

  final String model;
  final String apiKey;

  @override
  LanguageModel<ModelConfig> languageModelFor(Agent agent) => _OpenAiModel(
    modelConfig: this,
    systemInstructions: agent.systemPrompt,
    outputType: agent.outputType,
  );

  @override
  String get displayName => 'OpenAI $model';
}

class _OpenAiModel extends LanguageModel<OpenAiConfig> {
  _OpenAiModel({
    required super.modelConfig,
    required this.systemInstructions,
    required this.outputType,
  }) : _client = OpenAIClient(apiKey: modelConfig.apiKey);

  final OpenAIClient _client;
  final String? systemInstructions;
  final Map<String, dynamic>? outputType;

  @override
  Future<AgentResponse> run(String prompt) async {
    final res = await _client.createChatCompletion(
      request: CreateChatCompletionRequest(
        model: ChatCompletionModel.modelId(modelConfig.model),
        responseFormat:
            outputType != null
                ? ResponseFormat.jsonSchema(
                  jsonSchema: _schemaObjectFrom(outputType!),
                )
                : null,
        messages: [
          if (systemInstructions != null)
            ChatCompletionMessage.system(content: systemInstructions!),
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
