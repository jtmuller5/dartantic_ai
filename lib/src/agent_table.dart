import 'config/agent_config.dart';
import 'config/impl/gemini_config.dart';
import 'config/impl/openai_config.dart';
import 'config/provider_config.dart';
import 'providers/providers.dart';

class AgentInfo {
  AgentInfo({
    required this.family,
    required this.providerFactory,
    required this.defaultModel,
  });

  final String family;
  final String defaultModel;
  final Provider<T> Function<T extends ProviderConfig>(
    AgentConfig agentConfig,
    T providerConfig,
  )
  providerFactory;
}

final agentTable = [
  AgentInfo(
    family: 'openai',
    defaultModel: 'gpt-4o',
    providerFactory: <T extends ProviderConfig>(agentConfig, providerConfig) {
      assert(providerConfig is OpenAiConfig);
      return OpenAiProvider(
            agentConfig: agentConfig,
            providerConfig: providerConfig as OpenAiConfig,
          )
          as Provider<T>;
    },
  ),
  AgentInfo(
    family: 'google-gla',
    defaultModel: 'gemini-2.0-flash',
    providerFactory: <T extends ProviderConfig>(agentConfig, providerConfig) {
      assert(providerConfig is GeminiConfig);
      return GeminiProvider(
            agentConfig: agentConfig,
            providerConfig: providerConfig as GeminiConfig,
          )
          as Provider<T>;
    },
  ),
];
