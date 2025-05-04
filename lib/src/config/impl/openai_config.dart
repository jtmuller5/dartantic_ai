import '../../platform/platform.dart' as platform;
import '../provider_config.dart';

class OpenAiConfig extends ProviderConfig {
  OpenAiConfig({this.modelName = 'gpt-4o', String? apiKey})
    : apiKey = apiKey ?? platform.getEnv('OPENAI_API_KEY');

  final String modelName;
  final String apiKey;

  @override
  String get family => 'openai';

  @override
  String get displayName => '$family:$modelName';
}
