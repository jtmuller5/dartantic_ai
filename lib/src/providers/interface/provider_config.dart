class ProviderConfig {
  ProviderConfig({
    required this.familyName,
    required this.modelName,
    required this.apiKey,
    required this.systemPrompt,
    required this.outputType,
  });

  final String familyName;
  final String modelName;
  final String? apiKey;
  final String? systemPrompt;
  final Map<String, dynamic>? outputType;
}
