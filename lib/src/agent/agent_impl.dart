import 'package:ack/ack.dart' as ack;

import '../model/model_config.dart';
import 'agent_response.dart';

class Agent {
  Agent({
    required this.modelConfig,
    this.systemPrompt,
    this.outputType,
    this.instrument = false,
  });

  final ModelConfig modelConfig;
  final String? systemPrompt;
  final ack.Schema? outputType;
  final bool instrument;

  Future<AgentResponse> run(String prompt) =>
      modelConfig.languageModelFor(this).run(prompt);
}
