import 'dart:convert';

import '../model/model_config.dart';
import 'agent_response.dart';

class Agent {
  Agent({
    required this.modelConfig,
    this.systemPrompt,
    this.outputType,
    this.instrument = false,
    this.outputFromJson,
    this.outputToJson,
  });

  final ModelConfig modelConfig;
  final String? systemPrompt;
  final Map<String, dynamic>? outputType;
  final bool instrument;
  final dynamic Function(Map<String, dynamic>)? outputFromJson;
  final dynamic Function(dynamic)? outputToJson;

  Future<AgentResponse> run(String prompt) =>
      modelConfig.languageModelFor(this).run(prompt);

  Future<AgentResponseFor<T>> runFor<T>(String prompt) async {
    final output = await modelConfig.languageModelFor(this).run(prompt);
    final outputJson =
        outputFromJson?.call(jsonDecode(output.output)) ??
        jsonDecode(output.output);
    final outputTyped = outputToJson?.call(outputJson) ?? outputJson;
    return AgentResponseFor(output: outputTyped);
  }
}
