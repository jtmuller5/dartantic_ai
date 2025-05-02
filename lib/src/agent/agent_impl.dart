import '../model/model_config.dart';
import 'agent_response.dart';

class Agent {
  Agent({
    required this.modelConfig,
    required this.systemPrompt,
    this.outputType,
    this.instrument = false,
  });

  final ModelConfig modelConfig;
  final String systemPrompt;
  final Object? outputType;
  final bool instrument;

  Future<AgentResponse> run(String prompt) =>
      modelConfig.languageModelFor(this).generate(prompt);
}
