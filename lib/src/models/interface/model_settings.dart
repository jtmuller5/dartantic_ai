/// Settings used to configure a model.
///
/// Contains configuration options that are common across different model
/// implementations.
class ModelSettings {
  /// Creates a new [ModelSettings] instance.
  ///
  /// The [systemPrompt] is the system prompt to use for the model.
  /// The [outputType] is an optional JSON schema for structured outputs.
  ModelSettings({required this.systemPrompt, this.outputType});

  /// The system prompt to use for the model.
  ///
  /// Provides context and instructions to guide the model's responses.
  final String? systemPrompt;

  /// The output type for structured responses.
  ///
  /// When provided, configures the model to return responses in JSON format
  /// that match this schema.
  final Map<String, dynamic>? outputType;
}
