import 'dart:convert';

import '../agent_table.dart';
import '../config/agent_config.dart';
import '../config/provider_config.dart';
import '../providers/provider.dart';
import 'agent_response.dart';

class Agent {
  Agent({
    required ProviderConfig providerConfig,
    String? systemPrompt,
    Map<String, dynamic>? outputType,
    bool instrument = false,
    dynamic Function(Map<String, dynamic>)? outputFromJson,
    dynamic Function(dynamic)? outputToJson,
  }) : _provider = _providerFor(
         providerConfig,
         AgentConfig(
           systemPrompt: systemPrompt,
           outputType: outputType,
           instrument: instrument,
           outputFromJson: outputFromJson,
           outputToJson: outputToJson,
         ),
       );

  final Provider<ProviderConfig> _provider;

  Future<AgentResponse> run(String prompt) => _provider.run(prompt);

  Future<AgentResponseFor<T>> runFor<T>(String prompt) async {
    final output = await _provider.run(prompt);
    final outputJson =
        _provider.agentConfig.outputFromJson?.call(jsonDecode(output.output)) ??
        jsonDecode(output.output);
    final outputTyped =
        _provider.agentConfig.outputToJson?.call(outputJson) ?? outputJson;
    return AgentResponseFor(output: outputTyped);
  }

  static Provider<ProviderConfig> _providerFor(
    ProviderConfig providerConfig,
    AgentConfig agentConfig,
  ) => agentTable
      .singleWhere(
        (info) => info.family == providerConfig.family,
        orElse:
            () =>
                throw ArgumentError(
                  'Unsupported provider family: ${providerConfig.family}',
                ),
      )
      .providerFactory(agentConfig, providerConfig);
}
