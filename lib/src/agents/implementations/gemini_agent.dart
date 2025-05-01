import 'package:google_generative_ai/google_generative_ai.dart';

import '../agents.dart';

class GeminiAgent extends AgentBase {
  GeminiAgent({
    required String apiKey,
    required String model,
    required String systemPrompt,
  }) : _model = GenerativeModel(
         model: model,
         apiKey: apiKey,
         systemInstruction: Content.text(systemPrompt),
       );

  final GenerativeModel _model;

  @override
  Future<AgentResponse> generate(String prompt) async {
    final response = await _model.generateContent([Content.text(prompt)]);
    return AgentResponse(output: response.text ?? '');
  }
}
