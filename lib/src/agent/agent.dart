import 'dart:convert';

import '../models/interface/model.dart';
import '../models/interface/model_settings.dart';
import '../providers/implementation/provider_table.dart';
import '../providers/interface/provider.dart';
import '../providers/interface/provider_settings.dart';
import 'agent_response.dart';
import 'tool.dart';

export 'agent_response.dart';
export 'tool.dart';

/// An agent that can run prompts through an AI model and return responses.
///
/// This class provides a unified interface for interacting with different
/// AI model providers and handling both string and typed responses.
class Agent {
  /// Creates a new [Agent] with the given [model] and [provider].
  ///
  /// The [model] is the model to use for the agent in the format
  /// "family:model". The [provider] is the provider to use for the agent. One
  /// of [model] or [provider] must be provided but not both. The [systemPrompt]
  /// is the system prompt to use for the agent. The [outputType] is the output
  /// type to use for the agent. The [outputFromJson] is the function to use to
  /// convert the output to a typed object. The [tools] parameter allows you to
  /// provide a collection of tools that the agent can use to perform external
  /// actions or access specific capabilities.
  Agent({
    String? model,
    Provider? provider,
    String? systemPrompt,
    Map<String, dynamic>? outputType,
    this.outputFromJson,
    Iterable<Tool>? tools,
  }) {
    if (model == null && provider == null) {
      throw ArgumentError('Either model or provider must be provided');
    }
    if (model != null && provider != null) {
      throw ArgumentError('Only one of model or provider can be provided');
    }
    if (model != null && model.split(':').length != 2) {
      throw ArgumentError('Model must be in the format "family:model"');
    }

    provider =
        provider ??
        ProviderTable.providerFor(
          ProviderSettings(
            familyName: model!.split(':').first,
            modelName: model.split(':').last,
            apiKey: null,
          ),
        );

    _model = provider.createModel(
      ModelSettings(
        systemPrompt: systemPrompt,
        outputType: outputType,
        tools: tools,
      ),
    );
  }

  late final Model _model;

  /// Function to convert JSON output to a typed object.
  ///
  /// When provided, this function is used to convert the JSON response from the
  /// model into a strongly-typed object when using [runFor].
  final dynamic Function(Map<String, dynamic> json)? outputFromJson;

  /// Runs the given [prompt] through the model and returns the response.
  ///
  /// Returns an [AgentResponse] containing the raw string output.
  Future<AgentResponse> run(String prompt) => _model.run(prompt);

  /// Runs the given [prompt] through the model and returns a typed response.
  ///
  /// Returns an [AgentResponseFor<T>] containing the output converted to type
  /// [T]. Uses [outputFromJson] to convert the JSON response if provided.
  Future<AgentResponseFor<T>> runFor<T>(String prompt) async {
    final output = await run(prompt);
    final outputJson = jsonDecode(output.output);
    final outputTyped = outputFromJson?.call(outputJson) ?? outputJson;
    return AgentResponseFor(output: outputTyped);
  }
}
