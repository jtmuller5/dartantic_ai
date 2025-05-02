import '../agent/agent_response.dart';
import 'model_config.dart';

abstract class LanguageModel<T extends ModelConfig> {
  LanguageModel({required this.modelConfig});

  final T modelConfig;

  Future<AgentResponse> generate(String prompt);
}
