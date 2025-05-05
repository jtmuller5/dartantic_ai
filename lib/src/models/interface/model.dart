import '../../agent/agent.dart';

abstract class Model {
  Future<AgentResponse> run(String prompt);
}
