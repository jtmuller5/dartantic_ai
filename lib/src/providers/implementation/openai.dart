import 'package:openai_dart/openai_dart.dart';

import '../../agent/agent_response.dart';
import '../../platform/platform.dart' as platform;
import '../interface/provider.dart';

class OpenAiProvider extends Provider {
  OpenAiProvider({
    String? familyName,
    String? modelName,
    String? apiKey,
    this.outputType,
    this.systemPrompt,
  }) : assert(familyName == null || familyName == openaiFamily),
       modelName = modelName ?? openaiModelName,
       _client = OpenAIClient(
         apiKey: apiKey ?? platform.getEnv(openaiApiKeyName),
       );

  static const openaiFamily = 'openai';
  static const openaiModelName = 'gpt-4o';
  static const openaiApiKeyName = 'OPENAI_API_KEY';

  @override
  String get familyName => openaiFamily;

  @override
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
