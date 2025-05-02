import 'package:google_generative_ai/google_generative_ai.dart';

import '../agent/agent_impl.dart';
import '../agent/agent_response.dart';
import '../model/language_model.dart';
import '../model/model_config.dart';
import '../platform/platform.dart' as platform;

class GeminiConfig extends ModelConfig {
  GeminiConfig({this.model = 'gemini-2.0-flash', String? apiKey})
    : apiKey = apiKey ?? platform.getEnv('GEMINI_API_KEY');

  final String model;
  final String apiKey;

  @override
  LanguageModel<ModelConfig> languageModelFor(Agent agent) =>
      _GeminiModel(modelConfig: this, systemInstructions: agent.systemPrompt);

  @override
  String get displayName => 'Gemini $model';
}

class _GeminiModel extends LanguageModel<GeminiConfig> {
  _GeminiModel({required super.modelConfig, required this.systemInstructions})
    : _model = GenerativeModel(
        model: modelConfig.model,
        apiKey: modelConfig.apiKey,
        systemInstruction:
            systemInstructions != null
                ? Content.text(systemInstructions)
                : null,
      );

  final GenerativeModel _model;
  final String? systemInstructions;

  @override
  Future<AgentResponse> run(String prompt) async {
    final result = await _model.generateContent([Content.text(prompt)]);
    return AgentResponse(output: result.text ?? '');
  }
}
