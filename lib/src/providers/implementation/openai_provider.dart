import 'package:openai_dart/openai_dart.dart' as oai;

import '../../models/implementations/langchain_openai_model.dart';
import '../../models/interface/model.dart';
import '../../models/interface/model_settings.dart';
import '../../platform/platform.dart' as platform;
import '../interface/provider.dart';
import '../interface/provider_caps.dart';

/// Provider for OpenAI models using LangChain.
///
/// This provider creates instances of [LangchainOpenAiModel] with full
/// multi-step tool calling support through the LangChain framework.
class OpenAiProvider extends Provider {
  /// Creates a new [OpenAiProvider] with the given parameters.
  ///
  /// The [modelName] is the name of the OpenAI model to use.
  /// If not provided, [LangchainOpenAiModel.defaultModelName] is used.
  /// The [embeddingModelName] is the name of the OpenAI embedding model to use.
  /// If not provided, [LangchainOpenAiModel.defaultEmbeddingModelName] is used.
  /// The [apiKey] is the API key to use for authentication.
  /// If not provided, it's retrieved from the environment.
  /// 
  /// Note: The [parallelToolCalls] parameter is deprecated and no longer used.
  /// Tool calling is now handled through LangChain's multi-step agent approach.
  OpenAiProvider({
    this.name = 'openai',
    this.modelName,
    this.embeddingModelName,
    String? apiKey,
    this.baseUrl,
    this.caps = ProviderCaps.all,
    @Deprecated('Tool calling is now handled by LangChain multi-step approach')
    bool? parallelToolCalls,
  }) : apiKey = _resolveApiKey(apiKey, name);

  /// The name of the environment variable that contains the API key.
  static const apiKeyName = 'OPENAI_API_KEY';

  @override
  final String name;

  /// The name of the OpenAI model to use.
  final String? modelName;

  /// The name of the OpenAI embedding model to use.
  final String? embeddingModelName;

  /// The API key to use for authentication with the OpenAI API.
  final String apiKey;

  /// The base URL for the OpenAI API.
  final Uri? baseUrl;

  /// Creates a [Model] instance using this provider's configuration.
  ///
  /// The [settings] parameter contains additional configuration options
  /// for the model, such as the system prompt, output schema, and tools.
  /// 
  /// This implementation uses LangChain with full multi-step tool calling
  /// support. Tools are executed through an iterative agent loop that
  /// can handle complex multi-step workflows.
  @override
  Model createModel(ModelSettings settings) => LangchainOpenAiModel(
    modelName: modelName,
    embeddingModelName: embeddingModelName,
    apiKey: apiKey,
    caps: caps,
    systemPrompt: settings.systemPrompt,
    tools: settings.tools,
    temperature: settings.temperature,
    outputSchema: settings.outputSchema,
    baseUrl: baseUrl,
    providerName: name,
  );

  @override
  final Set<ProviderCaps> caps;

  @override
  Future<Iterable<ModelInfo>> listModels() async {
    final client = oai.OpenAIClient(
      apiKey: apiKey,
      baseUrl: baseUrl?.toString(),
    );
    try {
      final res = await client.listModels();
      return res.data.map<ModelInfo>((m) {
        final id = m.id;

        final kind = () {
          if (id.contains('embedding')) return ModelKind.embedding;
          if (id.startsWith('dall-e') || id.contains('gpt-image')) {
            return ModelKind.image;
          }
          if (id.startsWith('whisper')) return ModelKind.audio;
          if (id.startsWith('tts-')) return ModelKind.tts;
          return ModelKind.chat; // default assumption
        }();

        return ModelInfo(
          name: id,
          providerName: name,
          kinds: {kind},
          stable: _isStable(id),
        );
      }).toList();
    } finally {
      client.endSession();
    }
  }

  /// Resolves the API key for this provider.
  /// 
  /// Checks explicit key first, then falls back to environment variables.
  /// platform.getEnv() already checks Agent.environment before system environment.
  static String _resolveApiKey(String? providedKey, String providerName) {
    if (providedKey != null && providedKey.isNotEmpty) {
      return providedKey;
    }
    
    // Map provider name to correct environment variable
    final envVarName = _getEnvironmentVariableName(providerName);
    
    return platform.getEnv(envVarName) ?? '';
  }

  /// Maps provider name to the correct environment variable name
  static String _getEnvironmentVariableName(String providerName) {
    switch (providerName.toLowerCase()) {
      case 'openai':
        return 'OPENAI_API_KEY';
      case 'openrouter':
        return 'OPENROUTER_API_KEY';
      case 'google':
      case 'gemini':
      case 'gemini-compat':
        return 'GEMINI_API_KEY';
      default:
        return 'OPENAI_API_KEY'; // fallback for openai-compatible providers
    }
  }

  static bool _isStable(String modelName) {
    final lowerName = modelName.toLowerCase();

    // Check for explicit preview/experimental markers
    final unstableMarkers = [
      'preview',
      'beta',
      'alpha',
      'experimental',
      'latest',
    ];
    for (final marker in unstableMarkers) {
      if (lowerName.contains(marker)) return false;
    }

    // Check for date patterns:
    // - MMDD format (e.g. -0914, -1106, -0125)
    // - YYYY-MM-DD format (e.g. -2024-05-13, -2025-01-31)
    final datePatterns = [
      RegExp(r'-\d{4}$'), // -MMDD at end
      RegExp(r'-\d{4}-\d{2}-\d{2}$'), // -YYYY-MM-DD at end
    ];

    for (final pattern in datePatterns) {
      if (pattern.hasMatch(modelName)) return false;
    }

    return true;
  }
}
