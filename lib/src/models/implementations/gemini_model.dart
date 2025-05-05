import 'package:google_generative_ai/google_generative_ai.dart';

import '../../agent/agent_response.dart';
import '../interface/model.dart';

class GeminiModel extends Model {
  GeminiModel({
    required String modelName,
    required String apiKey,
    Map<String, dynamic>? outputType,
    this.systemPrompt,
  }) : _model = GenerativeModel(
         apiKey: apiKey,
         model: modelName,
         generationConfig:
             outputType == null
                 ? null
                 : GenerationConfig(
                   responseMimeType: 'application/json',
                   responseSchema: _schemaObjectFrom(outputType),
                 ),
         systemInstruction:
             systemPrompt != null ? Content.text(systemPrompt) : null,
       );

  late final GenerativeModel _model;
  final String? systemPrompt;

  @override
  Future<AgentResponse> run(String prompt) async {
    final result = await _model.generateContent([Content.text(prompt)]);
    return AgentResponse(output: result.text ?? '');
  }

  // TODO: implement
  static Schema _schemaObjectFrom(Map<String, dynamic> outputType) =>
      Schema.object(properties: {});
}
