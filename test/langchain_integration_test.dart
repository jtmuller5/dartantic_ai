import 'package:dartantic_ai/dartantic_ai.dart';
import 'package:test/test.dart';

void main() {
  group('Langchain Integration', () {
    test('can create openai agent with langchain backend', () {
      // Set a dummy API key for testing
      Agent.environment['OPENAI_API_KEY'] = 'test-key';
      
      expect(
        () => Agent('openai:gpt-4o'),
        returnsNormally,
      );
      
      final agent = Agent('openai:gpt-4o');
      expect(agent, isA<Agent>());
    });

    test('can create google agent with langchain backend', () {
      // Set a dummy API key for testing
      Agent.environment['GOOGLE_API_KEY'] = 'test-key';
      
      expect(
        () => Agent('google:gemini-2.0-flash'),
        returnsNormally,
      );
      
      final agent = Agent('google:gemini-2.0-flash');
      expect(agent, isA<Agent>());
    });

    test('agent creation works with API keys', () {
      // Clear API keys to test fallback
      Agent.environment.clear();
      
      // Should still create an agent even without API keys
      final agent = Agent('openai:gpt-4o');
      expect(agent, isA<Agent>());
      expect(agent.model, equals('openai:gpt-4o'));
    });

    test('langchain wrapper initialization preserves API', () {
      Agent.environment['OPENAI_API_KEY'] = 'test-key';
      
      final agent = Agent('openai:gpt-4o',
        systemPrompt: 'You are a helpful assistant',
        temperature: 0.7,
      );
      
      expect(agent, isA<Agent>());
      expect(agent.model, equals('openai:gpt-4o'));
    });
  });
}
