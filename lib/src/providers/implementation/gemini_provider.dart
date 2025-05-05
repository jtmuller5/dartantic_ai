import '../../models/implementations/gemini_model.dart';
import '../../models/interface/model.dart';
import '../../models/interface/model_settings.dart';
import '../../platform/platform.dart' as platform;
import '../interface/provider.dart';

class GeminiProvider extends Provider {
  GeminiProvider({String? modelName, String? apiKey})
    : modelName = modelName ?? defaultModelName,
      apiKey = apiKey ?? platform.getEnv(apiKeyName);

  static const defaultModelName = 'gemini-2.0-flash';
  static const apiKeyName = 'GEMINI_API_KEY';

  @override
  String get displayName => 'google-gla:$modelName';

  final String modelName;
  final String apiKey;

  @override
  Model createModel(ModelSettings settings) => GeminiModel(
    modelName: modelName,
    apiKey: apiKey,
    outputType: settings.outputType,
    systemPrompt: settings.systemPrompt,
  );
}
