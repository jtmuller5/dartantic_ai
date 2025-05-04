import '../providers.dart';

class ProviderTable {
  static final providers = <String, ProviderFactory>{
    'openai':
        (config) => OpenAiProvider(
          familyName: config.familyName,
          modelName: config.modelName,
          apiKey: config.apiKey,
          outputType: config.outputType,
          systemPrompt: config.systemPrompt,
        ),
    'google-gla':
        (config) => GeminiProvider(
          familyName: config.familyName,
          modelName: config.modelName,
          apiKey: config.apiKey,
          outputType: config.outputType,
          systemPrompt: config.systemPrompt,
        ),
  };

  static Provider providerFor(ProviderConfig config) {
    final providerFactory = providers[config.familyName];
    if (providerFactory != null) return providerFactory(config);
    throw ArgumentError('Unsupported provider family: $config.family');
  }
}
