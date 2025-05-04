import '../agent/agent_response.dart';
import '../config/agent_config.dart';
import '../config/provider_config.dart';

abstract class Provider<T extends ProviderConfig> {
  Provider({required this.agentConfig, required this.providerConfig});

  final AgentConfig agentConfig;
  final T providerConfig;

  Future<AgentResponse> run(String prompt);
}
