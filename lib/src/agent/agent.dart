import 'dart:convert';

import '../models/interface/model.dart';
import '../models/interface/model_settings.dart';
import '../providers/implementation/provider_table.dart';
import '../providers/interface/provider.dart';
import '../providers/interface/provider_settings.dart';
import 'agent_response.dart';

export 'agent_response.dart';

class Agent {
  Agent({
    String? model,
    Provider? provider,
    String? systemPrompt,
    Map<String, dynamic>? outputType,
    this.outputFromJson,
  }) : assert(
         model != null || provider != null,
         'Either model or provider must be provided',
       ),
       assert(
         !(model != null && provider != null),
         'Only one of model or provider can be provided',
       ),
       assert(
         model == null || model.split(':').length == 2,
         'Model must be in the format "family:model"',
       ) {
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
      ModelSettings(systemPrompt: systemPrompt, outputType: outputType),
    );
  }

  late final Model _model;
  final dynamic Function(Map<String, dynamic> json)? outputFromJson;

  Future<AgentResponse> run(String prompt) => _model.run(prompt);

  Future<AgentResponseFor<T>> runFor<T>(String prompt) async {
    final output = await run(prompt);
    final outputJson = jsonDecode(output.output);
    final outputTyped = outputFromJson?.call(outputJson) ?? outputJson;
    return AgentResponseFor(output: outputTyped);
  }
}
