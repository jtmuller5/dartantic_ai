import 'dart:typed_data';

import 'package:json_schema/json_schema.dart';

import '../../agent/agent_response.dart';
import '../../agent/embedding_type.dart';
import '../../agent/tool.dart';
import '../../message.dart';
import '../../providers/interface/provider_caps.dart';
import '../interface/model.dart';
import 'langchain_wrapper.dart';

/// Langchain-based implementation of [Model] that uses Google's Gemini API.
///
/// This model delegates prompt execution to Langchain while maintaining
/// the existing API interface for seamless integration.
class LangchainGeminiModel extends Model {
  /// Creates a new [LangchainGeminiModel] with the given parameters.
  LangchainGeminiModel({
    required String apiKey,
    String? modelName,
    String? embeddingModelName,
    String? systemPrompt,
    Iterable<Tool>? tools,
    double? temperature,
    JsonSchema? outputSchema,
  }) : generativeModelName = modelName ?? defaultModelName,
       embeddingModelName = embeddingModelName ?? defaultEmbeddingModelName,
       _wrapper = LangchainWrapper(
          provider: 'google',
          apiKey: apiKey,
          caps: ProviderCaps.all,
          modelName: modelName ?? defaultModelName,
          embeddingModelName: embeddingModelName ?? defaultEmbeddingModelName,
          systemPrompt: systemPrompt,
          tools: tools,
          temperature: temperature,
          outputSchema: outputSchema,
        );

  /// The default model name to use if none is provided.
  static const defaultModelName = 'gemini-2.0-flash';

  /// The default embedding model name to use if none is provided.
  static const defaultEmbeddingModelName = 'text-embedding-004';

  final LangchainWrapper _wrapper;

  @override
  late final String generativeModelName;

  @override
  late final String embeddingModelName;

  @override
  final Set<ProviderCaps> caps = ProviderCaps.all;

  @override
  Stream<AgentResponse> runStream({
    required String prompt,
    required Iterable<Message> messages,
    required Iterable<Part> attachments,
  }) =>
      _wrapper.runStream(
        prompt: prompt,
        messages: messages,
        attachments: attachments,
      );

  @override
  Future<Float64List> createEmbedding(
    String text, {
    EmbeddingType type = EmbeddingType.document,
  }) =>
      _wrapper.createEmbedding(text, type: type);
}
