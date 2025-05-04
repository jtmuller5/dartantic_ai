import 'package:google_generative_ai/google_generative_ai.dart';

import '../../agent/agent_response.dart';
import '../../platform/platform.dart' as platform;
import '../interface/provider.dart';

class GeminiProvider extends Provider {
  GeminiProvider({
    String? familyName,
    String? modelName,
    String? apiKey,
    this.outputType,
    this.systemPrompt,
  }) : assert(familyName == null || familyName == geminiFamily),
       modelName = modelName ?? geminiModelName {
    _model = GenerativeModel(
      apiKey: apiKey ?? platform.getEnv(geminiApiKeyName),
      model: this.modelName,
      systemInstruction:
          systemPrompt != null ? Content.text(systemPrompt!) : null,
    );
  }

  static const geminiFamily = 'google-gla';
  static const geminiModelName = 'gemini-2.0-flash';
  static const geminiApiKeyName = 'GEMINI_API_KEY';

  @override
  final String modelName;

  late final GenerativeModel _model;
  final Map<String, dynamic>? outputType;
  final String? systemPrompt;

  @override
  Future<AgentResponse> run(String prompt) async {
    final result = await _model.generateContent([Content.text(prompt)]);
    return AgentResponse(output: result.text ?? '');
  }

  @override
  String get familyName => 'google-gla';
}
