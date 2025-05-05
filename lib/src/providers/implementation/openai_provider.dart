import '../../models/implementations/openai_model.dart';
import '../../models/interface/model.dart';
import '../../models/interface/model_settings.dart';
import '../../platform/platform.dart' as platform;
import '../interface/provider.dart';

class OpenAiProvider extends Provider {
  OpenAiProvider({String? modelName, String? apiKey})
    : modelName = modelName ?? defaultModelName,
      apiKey = apiKey ?? platform.getEnv(apiKeyName);

  static const defaultModelName = 'gpt-4o';
  static const apiKeyName = 'OPENAI_API_KEY';

  @override
  String get displayName => 'openai:$modelName';
  final String modelName;
  final String apiKey;

  @override
  Model createModel(ModelSettings settings) => OpenAiModel(
    modelName: modelName,
    apiKey: apiKey,
    outputType: settings.outputType,
    systemPrompt: settings.systemPrompt,
  );
}
