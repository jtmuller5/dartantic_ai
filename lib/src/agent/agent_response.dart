class AgentResponse {
  AgentResponse({required this.output});
  final String output;
}

class AgentResponseFor<T> {
  AgentResponseFor({required this.output});
  final T output;
}
