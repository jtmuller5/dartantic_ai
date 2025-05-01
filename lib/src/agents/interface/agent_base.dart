import 'agent_response.dart';

abstract class AgentBase {
  Future<AgentResponse> generate(String prompt);
}
