import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/implementations/langchain_gemini_model.dart';
import '../../models/interface/model.dart';
import '../../models/interface/model_settings.dart';
import '../../platform/platform.dart' as platform;
import '../../utils.dart';
import '../interface/provider.dart';
import '../interface/provider_caps.dart';

/// Provider for Google's Gemini AI models using LangChain.
///
/// This provider creates instances of [LangchainGeminiModel] with full
/// multi-step tool calling support through the LangChain framework.
class GeminiProvider extends Provider {
  /// Creates a new [GeminiProvider] with the given parameters.
  ///
  /// The [modelName] is the name of the Gemini model to use.
  /// If not provided, [LangchainGeminiModel.defaultModelName] is used.
  /// The [embeddingModelName] is the name of the Gemini embedding model to use.
  /// If not provided, [LangchainGeminiModel.defaultEmbeddingModelName] is used.
  /// The [apiKey] is the API key to use for authentication.
  /// If not provided, it's retrieved from the environment.
  /// The [temperature] controls the randomness of responses.
  GeminiProvider({
    this.modelName,
    this.embeddingModelName,
    String? apiKey,
    this.temperature,
  }) : apiKey = _resolveApiKey(apiKey);

  /// The name of the environment variable that contains the API key.
  static const apiKeyName = 'GEMINI_API_KEY';

  @override
  String get name => 'google';

  /// The name of the Gemini model to use.
  final String? modelName;

  /// The name of the Gemini embedding model to use.
  final String? embeddingModelName;

  /// The API key to use for authentication with the Gemini API.
  final String apiKey;

  /// The temperature to use for the Gemini API.
  final double? temperature;

  /// Creates a [Model] instance using this provider's configuration.
  ///
  /// The [settings] parameter contains additional configuration options
  /// for the model, such as the system prompt, output schema, and tools.
  /// 
  /// This implementation uses LangChain with full multi-step tool calling
  /// support. Tools are executed through an iterative agent loop that
  /// can handle complex multi-step workflows.
  @override
  Model createModel(ModelSettings settings) => LangchainGeminiModel(
    modelName: modelName,
    embeddingModelName: embeddingModelName,
    apiKey: apiKey,
    systemPrompt: settings.systemPrompt,
    temperature: temperature ?? settings.temperature,
    tools: settings.tools,
    outputSchema: settings.outputSchema,
  );

  @override
  final caps = ProviderCaps.all;

  static const _methodToKind = {
    'embedContent': ModelKind.embedding,
    'embedText': ModelKind.embedding,
    'generateImage': ModelKind.image,
    'generateContent': ModelKind.chat,
    'countTokens': ModelKind.countTokens,
    'countTextTokens': ModelKind.countTokens,
  };

  @override
  Future<Iterable<ModelInfo>> listModels() async {
    final uri = Uri.https(
      'generativelanguage.googleapis.com',
      '/v1beta/models',
      {'key': apiKey},
    );

    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Gemini list failed: ${res.statusCode}');
    }

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final allModels = <ModelInfo>[];

    for (final model in body['models'] as List<dynamic>) {
      final modelName =
      // ignore: avoid_dynamic_calls
      (model['name'] as String).replaceFirst('models/', '');

      final methods =
          // ignore: avoid_dynamic_calls
          model['supportedGenerationMethods'] as List<dynamic>;
      final remainingMethods = methods.map((m) => m.toString().trim()).toList();

      final kinds = {
        for (final entry in _methodToKind.entries)
          if (remainingMethods.remove(entry.key)) entry.value,
      };

      if (remainingMethods.isNotEmpty) {
        log.finer('Other kind(s): [$modelName] $remainingMethods');
        kinds.add(ModelKind.other);
      }

      allModels.add(
        ModelInfo(
          name: modelName,
          providerName: name,
          kinds: kinds,
          stable: _isStable(modelName),
        ),
      );
    }

    return allModels;
  }

  /// Resolves the API key for this provider.
  /// 
  /// Checks explicit key first, then falls back to environment variables.
  /// platform.getEnv() already checks Agent.environment before system environment.
  static String _resolveApiKey(String? providedKey) {
    if (providedKey != null && providedKey.isNotEmpty) {
      return providedKey;
    }
    
    return platform.getEnv('GEMINI_API_KEY') ??
           platform.getEnv('GOOGLE_API_KEY') ??
           '';
  }

  static bool _isStable(String modelName) {
    final lowerName = modelName.toLowerCase();

    // Check for explicit preview/experimental markers
    final unstableMarkers = ['preview', 'experimental', 'exp', 'latest'];
    for (final marker in unstableMarkers) {
      if (lowerName.contains(marker)) return false;
    }

    // Check for date patterns (MM-DD format at end)
    final datePattern = RegExp(r'-\d{2}-\d{2}$');
    if (datePattern.hasMatch(modelName)) return false;

    // Check for version number suffixes on gemini models only
    // (e.g. gemini-1.5-flash-002, but NOT embedding-001)
    if (lowerName.startsWith('gemini-')) {
      final versionPattern = RegExp(r'-\d{3}$');
      if (versionPattern.hasMatch(modelName)) return false;
    }

    // Check for variant suffixes
    final variantPatterns = [
      RegExp(r'-\d+b$'), // -8b, -16b, etc. (size variants)
      RegExp(r'-lite-\d{3}$'), // -lite-001, etc. (lite with version)
    ];
    for (final pattern in variantPatterns) {
      if (pattern.hasMatch(modelName)) return false;
    }

    return true;
  }
}
