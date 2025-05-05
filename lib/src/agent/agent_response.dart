/// A response from an agent.
///
/// This class represents the response from an agent, containing the output
/// as a string. For typed responses, see [AgentResponseFor].
class AgentResponse {
  /// Creates a new [AgentResponse] with the given [output].
  ///
  /// The [output] is the raw string response from the agent.
  AgentResponse({required this.output});

  /// The raw string output from the agent.
  final String output;
}

/// A response from an agent.
///
/// This class represents the response from an agent, containing the output
/// as a typed object. For string responses, see [AgentResponse].
class AgentResponseFor<T> {
  /// Creates a new [AgentResponseFor] with the given [output].
  ///
  /// The [output] is the typed object response from the agent.
  AgentResponseFor({required this.output});

  /// The typed object output from the agent.
  final T output;
}
