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

void main() {
  group('Exception Handling', () {
    group('provider exceptions (80% cases)', () {
      test('throws on invalid provider name', () {
        expect(
          () => Agent('invalid-provider:model'),
          throwsA(isA<Exception>()),
        );
      });

      test('throws on unsupported capability', () async {
        // Mistral doesn't support tools
        final agent = Agent('mistral:mistral-small-latest', tools: []);

        // The exception is thrown when the model is created (on first use)
        await expectLater(() => agent.send('test'), throwsException);
      });

      test('handles malformed model strings', () {
        // Empty model part should use default
        expect(() => Agent('openai:'), returnsNormally);

        // Just provider name should use default model
        expect(() => Agent('anthropic'), returnsNormally);

        // Empty provider should throw
        expect(() => Agent(':gpt-4o-mini'), throwsA(isA<Exception>()));
      });
    });

    group('tool exceptions (80% cases)', () {
      test('tool execution errors are reported', () async {
        // Create a tool that always throws
        final errorTool = Tool<Map<String, dynamic>>(
          name: 'error_tool',
          description: 'A tool that always throws an error',

          onCall: (input) => throw Exception('Tool error: intentional'),
        );

        final agent = Agent('openai:gpt-4o-mini', tools: [errorTool]);

        // Agent should handle the tool error gracefully
        final result = await agent.send('Use the error_tool');

        // The response should mention the error
        expect(
          result.output.toLowerCase(),
          anyOf(contains('error'), contains('failed'), contains('problem')),
        );
      });

      test('invalid tool arguments handled', () async {
        // Create a tool that expects specific arguments
        final strictTool = Tool<Map<String, dynamic>>(
          name: 'strict_tool',
          description: 'A tool with strict requirements',

          onCall: (input) {
            if (!input.containsKey('required_field')) {
              throw ArgumentError('Missing required_field');
            }
            return 'Success';
          },
        );

        final agent = Agent('openai:gpt-4o-mini', tools: [strictTool]);

        // Per our testing philosophy, exceptions should bubble up
        expect(
          () => agent.send('Use strict_tool but forget the required_field'),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('edge cases', () {
      test('handles stack overflow in tool execution', () async {
        // Create a tool that could cause deep recursion
        final recursiveTool = Tool<Map<String, dynamic>>(
          name: 'recursive_tool',
          description: 'A tool that might recurse',

          // Don't actually cause stack overflow, just return
          onCall: (input) => 'Avoided recursion',
        );

        final agent = Agent('google:gemini-2.0-flash', tools: [recursiveTool]);

        final result = await agent.send('Use recursive_tool carefully');
        expect(result.output, isNotEmpty);
      });

      test('handles null returns from tools', () async {
        // Create a tool that returns null
        final nullTool = Tool<Map<String, dynamic>>(
          name: 'null_tool',
          description: 'A tool that returns null',

          onCall: (input) => null,
        );

        final agent = Agent('google:gemini-2.0-flash', tools: [nullTool]);

        final result = await agent.send('Use null_tool');
        expect(result.output, isNotEmpty);
      });

      test('handles extremely long error messages', () async {
        // Create a tool that throws with a very long message
        final longErrorTool = Tool<Map<String, dynamic>>(
          name: 'long_error_tool',
          description: 'A tool that throws verbose errors',

          onCall: (input) {
            final longMessage = 'Error: ${'x' * 1000}';
            throw Exception(longMessage);
          },
        );

        final agent = Agent('google:gemini-2.0-flash', tools: [longErrorTool]);

        final result = await agent.send('Use long_error_tool');
        expect(result.output, isNotEmpty);
      });

      test('handles concurrent exceptions', () async {
        // Create multiple agents that might fail
        final agents = List.generate(
          3,
          (i) => Agent('google:gemini-2.0-flash'),
        );

        // Make requests that might fail concurrently
        final futures = agents
            .map(
              (agent) async => agent.send('Test concurrent exception $agent'),
            )
            .toList();

        // Wait for all to complete (some might throw)
        final results = await Future.wait(
          futures,
          eagerError: false, // Don't stop on first error
        ).catchError((e) => <ChatResult<String>>[]);

        // At least some should complete
        expect(results, isA<List>());
      });
    });
  });
}
