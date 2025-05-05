import '../providers.dart';

class ProviderTable {
  static final providers = <String, ProviderFactory>{
    'openai':
        (settings) => OpenAiProvider(
          modelName: settings.modelName,
          apiKey: settings.apiKey,
        ),
    'google-gla':
        (settings) => GeminiProvider(
          modelName: settings.modelName,
          apiKey: settings.apiKey,
        ),
  };

  static Provider providerFor(ProviderSettings settings) {
    final providerFactory = providers[settings.familyName];
    if (providerFactory != null) return providerFactory(settings);
    throw ArgumentError('Unsupported provider family: $settings.family');
  }
}
