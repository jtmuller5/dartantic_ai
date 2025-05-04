import '../../platform/platform.dart' as platform;
import '../provider_config.dart';

class GeminiConfig extends ProviderConfig {
  GeminiConfig({this.modelName = 'gemini-2.0-flash', String? apiKey})
    : apiKey = apiKey ?? platform.getEnv('GEMINI_API_KEY');

  final String modelName;
  final String apiKey;

  @override
  String get family => 'google-gla';

  @override
  String get displayName => '$family:$modelName';
}
