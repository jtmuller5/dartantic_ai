import 'package:google_generative_ai/google_generative_ai.dart';

import '../../agent/agent_response.dart';
import '../../config/impl/gemini_config.dart';
import '../provider.dart';

class GeminiProvider extends Provider<GeminiConfig> {
  GeminiProvider({required super.agentConfig, required super.providerConfig})
    : _model = GenerativeModel(
        model: providerConfig.modelName,
        apiKey: providerConfig.apiKey,
      );

  final GenerativeModel _model;

  @override
  Future<AgentResponse> run(String prompt) async {
    final result = await _model.generateContent([Content.text(prompt)]);
    return AgentResponse(output: result.text ?? '');
  }
}
