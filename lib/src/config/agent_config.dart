class AgentConfig {
  AgentConfig({
    required this.systemPrompt,
    required this.outputType,
    required this.instrument,
    required this.outputFromJson,
    required this.outputToJson,
  });

  final String? systemPrompt;
  final Map<String, dynamic>? outputType;
  final bool instrument;
  final dynamic Function(Map<String, dynamic>)? outputFromJson;
  final dynamic Function(dynamic)? outputToJson;
}
