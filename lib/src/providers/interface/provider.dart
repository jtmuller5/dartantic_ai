import '../../agent/agent_response.dart';

abstract class Provider {
  String get familyName;
  String get modelName;
  String get displayName => '$familyName:$modelName';

  Future<AgentResponse> run(String prompt);

  @override
  String toString() => displayName;
}
