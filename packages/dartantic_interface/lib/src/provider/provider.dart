import 'package:http/http.dart' as http;
import '../chat/chat_model.dart';
import '../chat/chat_model_options.dart';
import '../embeddings/embeddings_model.dart';
import '../embeddings/embeddings_model_options.dart';
import '../model/model.dart';
import '../tool.dart';
import 'provider_caps.dart';

export 'provider_caps.dart';

/// Provides a unified interface for accessing all major LLM, chat, and
/// embedding providers in dartantic_ai.
///
/// The interface ensures all providers are accessible without importing
/// provider-specific packages. All configuration (API keys, base URLs, models)
/// is handled via the provider interface.
///
/// This interface is used to create a provider instance, which can be used to
/// create a chat model or an embeddings model.
///
/// The provider interface is used to create a provider instance, which can be
/// used to create a chat model or an embeddings model.
abstract class Provider<
  TChatOptions extends ChatModelOptions,
  TEmbeddingsOptions extends EmbeddingsModelOptions
> {
  /// Creates a new provider instance.
  ///
  /// - [name]: The canonical provider name (e.g., 'openai', 'ollama').
  /// - [displayName]: Human-readable name for display.
  /// - [defaultModelNames]: The default model for this provider (null means use
  ///   model's own default).
  /// - [baseUrl]: The default API endpoint.
  /// - [client]: The HTTP client to use for API requests.
  /// - [apiKeyName]: The environment variable for the API key (if any).
  /// - [aliases]: Alternative names for lookup.
  const Provider({
    required this.name,
    required this.displayName,
    required this.defaultModelNames,
    required this.caps,
    this.apiKey,
    this.baseUrl,
    this.client,
    this.apiKeyName,
    this.aliases = const [],
  });

  /// The canonical provider name (e.g., 'openai', 'ollama').
  final String name;

  /// Alternative names for lookup (e.g., 'claude' => 'anthropic').
  final List<String> aliases;

  /// Human-readable name for display.
  final String displayName;

  /// The default model for this provider.
  final Map<ModelKind, String> defaultModelNames;

  /// The API key for this provider.
  final String? apiKey;

  /// The default API endpoint for this provider.
  final Uri? baseUrl;

  /// The HTTP client to use for API requests.
  final http.Client? client;

  /// The environment variable for the API key (if any).
  final String? apiKeyName;

  /// The capabilities of this provider.
  final Set<ProviderCaps> caps;

  /// Returns all available models for this provider.
  ///
  /// Implementations may or may not cache results. If your application requires
  /// caching, you should implement it yourself rather than relying on the
  /// provider.
  Stream<ModelInfo> listModels();

  /// Creates a chat model instance for this provider.
  ChatModel<TChatOptions> createChatModel({
    String? name,
    List<Tool>? tools,
    double? temperature,
    TChatOptions? options,
  });

  /// Creates an embeddings model instance for this provider.
  EmbeddingsModel<TEmbeddingsOptions> createEmbeddingsModel({
    String? name,
    TEmbeddingsOptions? options,
  });
}
