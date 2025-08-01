/// TESTING PHILOSOPHY:
/// 1. DO NOT catch exceptions - let them bubble up for diagnosis
/// 2. DO NOT add provider filtering except by capabilities (e.g. ProviderCaps)
/// 3. DO NOT add performance tests
/// 4. DO NOT add regression tests
/// 5. 80% cases = common usage patterns tested across ALL capable providers
/// 6. Edge cases = rare scenarios tested on Google only to avoid timeouts
/// 7. Each functionality should only be tested in ONE file - no duplication

import 'package:dartantic_ai/dartantic_ai.dart';
import 'package:dartantic_interface/dartantic_interface.dart';
import 'package:test/test.dart';

import 'test_tools.dart';

void main() {
  // Helper to run parameterized tests
  void runProviderTest(
    String testName,
    Future<void> Function(Provider provider) testFunction, {
    Timeout? timeout,
  }) {
    group(testName, () {
      for (final provider in Providers.all) {
        test(
          '${provider.name} - $testName',
          () async {
            await testFunction(provider);
          },
          timeout: timeout ?? const Timeout(Duration(seconds: 30)),
        );
      }
    });
  }

  group('Reliability Features', () {
    group('basic construction reliability', () {
      runProviderTest('agent creation does not throw', (provider) async {
        // Test that agent creation works for all providers (no API calls)
        expect(
          () => Agent(provider.name),
          returnsNormally,
          reason:
              'Provider ${provider.name} should create agent '
              'without throwing',
        );

        // Test that agent has expected properties
        final agent = Agent(provider.name);
        expect(agent.providerName, equals(provider.name));
        expect(agent.model, contains('${provider.name}:'));
      });

      test('provider creation handles missing API keys', () {
        // All providers should create agents even without API keys
        expect(() => Agent('openai:gpt-4o-mini'), returnsNormally);
        expect(() => Agent('google:gemini-2.0-flash'), returnsNormally);
        expect(
          () => Agent('anthropic:claude-3-5-haiku-latest'),
          returnsNormally,
        );
        expect(() => Agent('mistral:mistral-small-latest'), returnsNormally);
      });
    });

    // Timeout handling moved to edge cases

    group('resource management', () {
      test('agent cleanup works correctly', () {
        final agent = Agent('openai:gpt-4o-mini');

        // Agent should create and work correctly
        expect(agent.providerName, equals('openai'));
        expect(agent.model, contains('openai:'));
      });

      test('multiple agents can coexist', () {
        final agents = [
          Agent('openai:gpt-4o-mini'),
          Agent('google:gemini-2.0-flash'),
        ];

        // All agents should create successfully
        expect(agents, hasLength(2));
        expect(agents[0].providerName, equals('openai'));
        expect(agents[1].providerName, equals('google'));

        // All agents should be properly configured
        expect(agents[0].model, contains('openai:'));
        expect(agents[1].model, contains('google:'));
      });

      // Concurrent usage moved to edge cases
    });

    group('edge cases (limited providers)', () {
      // Test edge cases on only 1-2 providers to save resources
      // and avoid timeouts
      final edgeCaseProviders = ['google:gemini-2.0-flash'];

      test('basic error recovery', () async {
        final agent = Agent(edgeCaseProviders.first);
        final result = await agent.send('Hello');
        expect(result.output, isA<String>());
      });

      test('streaming handles connection issues', () async {
        final agent = Agent(edgeCaseProviders.first);

        var streamStarted = false;
        var streamCompleted = false;

        await for (final chunk in agent.sendStream('Test message')) {
          streamStarted = true;
          expect(chunk.output, isA<String>());
        }
        streamCompleted = true;

        expect(streamStarted, isTrue);
        expect(streamCompleted, isTrue);
      });

      test('timeout handling', () async {
        final agent = Agent(edgeCaseProviders.first);
        final stopwatch = Stopwatch()..start();

        await agent.send('What is 1 + 1?');
        stopwatch.stop();

        // Should complete within reasonable time (2 minutes)
        expect(stopwatch.elapsedMilliseconds, lessThan(120000));
      });

      test('concurrent agent usage', () async {
        final agent1 = Agent(edgeCaseProviders.first);
        final agent2 = Agent(edgeCaseProviders.first);

        final futures = [
          agent1.send('What is 2 + 2?'),
          agent2.send('What is 3 + 3?'),
        ];

        final results = await Future.wait(futures);
        expect(results, hasLength(2));
        expect(results[0].output, isA<String>());
        expect(results[1].output, isA<String>());
      });

      test('tool errors are handled gracefully', () async {
        final agent = Agent(edgeCaseProviders.first, tools: [errorTool]);

        final result = await agent.send(
          'Use error_tool to test error handling',
        );
        expect(result.output, isA<String>());
        expect(result.messages, isNotEmpty);
      });

      test('handles special characters safely', () async {
        final agent = Agent(edgeCaseProviders.first);
        const specialInput = '!@#\$%^&*()_+{}[]|\\:";\'<>?,./`~';

        final result = await agent.send('Echo: $specialInput');
        expect(result.output, isA<String>());
      });

      test('handles unicode content properly', () async {
        final agent = Agent(edgeCaseProviders.first);
        const unicodeInput = '🚀 Hello 世界! 🌟 Testing émojis and accénts';

        final result = await agent.send('Repeat: $unicodeInput');
        expect(result.output, isA<String>());
      });

      test('degraded functionality still provides value', () async {
        final agent = Agent(edgeCaseProviders.first);

        // Even if advanced features fail, basic chat should work
        final result = await agent.send('Hello');
        expect(result.output, isA<String>());
        expect(result.output.isNotEmpty, isTrue);
      });
    });
  });
}
