import 'dart:convert';

import '../providers/implementation/provider_table.dart';
import '../providers/interface/provider.dart';
import '../providers/interface/provider_config.dart';
import 'agent_response.dart';

export 'agent_response.dart';

class Agent {
  Agent({
    String? model,
    Provider? provider,
    String? systemPrompt,
    Map<String, dynamic>? outputType,
    this.instrument = false,
    this.outputFromJson,
    this.outputToJson,
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
       ),
       provider =
           provider ??
           ProviderTable.providerFor(
             ProviderConfig(
               familyName: model!.split(':').first,
               modelName: model.split(':').last,
               apiKey: null,
               systemPrompt: systemPrompt,
               outputType: outputType,
             ),
           );

  final Provider provider;
  final bool instrument;
  final dynamic Function(Map<String, dynamic>)? outputFromJson;
  final dynamic Function(dynamic)? outputToJson;

  Future<AgentResponse> run(String prompt) => provider.run(prompt);

  Future<AgentResponseFor<T>> runFor<T>(String prompt) async {
    final output = await run(prompt);
    final outputJson =
        outputFromJson?.call(jsonDecode(output.output)) ??
        jsonDecode(output.output);
    final outputTyped = outputToJson?.call(outputJson) ?? outputJson;
    return AgentResponseFor(output: outputTyped);
  }
}
