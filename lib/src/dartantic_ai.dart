import 'dart:io';

import 'package:google_generative_ai/google_generative_ai.dart';

abstract class ModelConfig {
  String get displayName;

  LanguageModel<ModelConfig> languageModelFor(Agent agent);
}

class GeminiConfig extends ModelConfig {
  GeminiConfig({required this.model, String? apiKey})
    : apiKey = apiKey ?? _getEnv('GEMINI_API_KEY');

  final String model;
  final String apiKey;

  @override
  LanguageModel<ModelConfig> languageModelFor(Agent agent) =>
      _GeminiModel(modelConfig: this, systemInstructions: agent.systemPrompt);

  @override
  String get displayName => 'Gemini $model';
}

class AgentResponse {
  AgentResponse({required this.output});
  final String output;
}

abstract class LanguageModel<T extends ModelConfig> {
  LanguageModel({required this.modelConfig});

  final T modelConfig;

  Future<AgentResponse> generate(String prompt);
}

class _GeminiModel extends LanguageModel<GeminiConfig> {
  _GeminiModel({required super.modelConfig, this.systemInstructions})
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
  Future<AgentResponse> generate(String prompt) async {
    final result = await _model.generateContent([Content.text(prompt)]);
    return AgentResponse(output: result.text ?? '');
  }
}

class Agent {
  Agent({
    required this.modelConfig,
    required this.systemPrompt,
    this.outputType,
    this.instrument = false,
  });

  final ModelConfig modelConfig;
  final String systemPrompt;
  final Object? outputType;
  final bool instrument;

  Future<AgentResponse> generate(String prompt) =>
      modelConfig.languageModelFor(this).generate(prompt);
}

String _getEnv(String key) {
  final value = Platform.environment[key] ?? '';
  if (value.isEmpty) {
    throw Exception('Environment variable $key is not set');
  }
  return value;
}
