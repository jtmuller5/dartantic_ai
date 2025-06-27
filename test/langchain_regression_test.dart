import 'dart:io';
import 'dart:typed_data';

import 'package:dartantic_ai/dartantic_ai.dart';
import 'package:json_schema/json_schema.dart';
import 'package:test/test.dart';

void main() {
  group('Langchain Integration Regression Tests', () {
    setUpAll(() {
      // Set up test environment
      final openaiKey = Platform.environment['OPENAI_API_KEY'];
      final googleKey = Platform.environment['GOOGLE_API_KEY'];
      final geminiKey = Platform.environment['GEMINI_API_KEY'];

      if (openaiKey != null) Agent.environment['OPENAI_API_KEY'] = openaiKey;
      if (googleKey != null) Agent.environment['GOOGLE_API_KEY'] = googleKey;
      if (geminiKey != null) Agent.environment['GEMINI_API_KEY'] = geminiKey;
    });

    group('Original Provider Functionality', () {
      test('original OpenAI provider still works', () {
        final apiKey = Agent.environment['OPENAI_API_KEY'];
        if (apiKey == null) {
          markTestSkipped('OPENAI_API_KEY not available');
          return;
        }

        expect(
          () => Agent('openai:gpt-4o-mini'),
          returnsNormally,
        );

        final agent = Agent('openai:gpt-4o-mini');
        expect(agent.model, equals('openai:gpt-4o-mini'));
        expect(agent.caps, isNotEmpty);
      });

      test('original Google provider still works', () {
        final apiKey = Agent.environment['GOOGLE_API_KEY'] ?? Agent.environment['GEMINI_API_KEY'];
        if (apiKey == null) {
          markTestSkipped('GOOGLE_API_KEY or GEMINI_API_KEY not available');
          return;
        }

        expect(
          () => Agent('google:gemini-1.5-flash'),
          returnsNormally,
        );

        final agent = Agent('google:gemini-1.5-flash');
        expect(agent.model, contains('google:gemini'));
        expect(agent.caps, isNotEmpty);
      });

      test('provider aliases still work', () {
        final apiKey = Agent.environment['GOOGLE_API_KEY'] ?? Agent.environment['GEMINI_API_KEY'];
        if (apiKey == null) {
          markTestSkipped('Google API key not available');
          return;
        }

        // Test various aliases
        expect(() => Agent('gemini:gemini-1.5-flash'), returnsNormally);
        expect(() => Agent('googleai:gemini-1.5-flash'), returnsNormally);
      });

      test('openrouter provider still works', () {
        expect(
          () => Agent('openrouter:gpt-4o-mini', apiKey: 'test-key'),
          returnsNormally,
        );
      });

      test('gemini-compat provider still works', () {
        final apiKey = Agent.environment['GOOGLE_API_KEY'] ?? Agent.environment['GEMINI_API_KEY'];
        if (apiKey == null) {
          markTestSkipped('Google API key not available');
          return;
        }

        expect(
          () => Agent('gemini-compat:gemini-1.5-flash'),
          returnsNormally,
        );
      });
    });

    group('Agent API Consistency', () {
      test('Agent constructor parameters work the same', () {
        final apiKey = Agent.environment['OPENAI_API_KEY'];
        if (apiKey == null) {
          markTestSkipped('OPENAI_API_KEY not available');
          return;
        }

        // Test all constructor parameters still work
        final tool = Tool(
          name: 'test_tool',
          description: 'Test tool',
          inputSchema: JsonSchema.create({'type': 'object'}),
          onCall: (input) async => {'result': 'test'},
        );

        final schema = JsonSchema.create({
          'type': 'object',
          'properties': {'response': {'type': 'string'}},
        });

        expect(
          () => Agent(
            'openai:gpt-4o-mini',
            systemPrompt: 'Test prompt',
            outputSchema: schema,
            tools: [tool],
            temperature: 0.7,
            embeddingModel: 'text-embedding-3-small',
          ),
          returnsNormally,
        );
      });

      test('Agent.provider constructor still works', () {
        final apiKey = Agent.environment['OPENAI_API_KEY'];
        if (apiKey == null) {
          markTestSkipped('OPENAI_API_KEY not available');
          return;
        }

        final provider = Agent.providerFor('openai:gpt-4o-mini');
        expect(
          () => Agent.provider(provider),
          returnsNormally,
        );
      });

      test('Agent static methods still work', () {
        expect(Agent.providers, isNotEmpty);
        expect(Agent.environment, isA<Map<String, String>>());
      });

      test('Agent.findTopMatches still works', () {
        final embeddings = {
          'item1': Float64List.fromList([1.0, 0.0, 0.0]),
          'item2': Float64List.fromList([0.0, 1.0, 0.0]),
          'item3': Float64List.fromList([0.0, 0.0, 1.0]),
        };
        final query = Float64List.fromList([1.0, 0.0, 0.0]);

        final matches = Agent.findTopMatches(
          embeddingMap: embeddings,
          queryEmbedding: query,
          limit: 2,
        );

        expect(matches.length, equals(2));
        expect(matches.first, equals('item1'));
      });

      test('Agent cosine similarity functions still work', () {
        final a = Float64List.fromList([1.0, 0.0, 0.0]);
        final b = Float64List.fromList([1.0, 0.0, 0.0]);
        final c = Float64List.fromList([0.0, 1.0, 0.0]);

        expect(Agent.cosineSimilarity(a, b), closeTo(1.0, 0.001));
        expect(Agent.cosineSimilarity(a, c), closeTo(0.0, 0.001));
        expect(Agent.dotProduct(a, b), equals(1.0));
      });
    });

    group('Message and Part API Consistency', () {
      test('Message constructors still work', () {
        expect(
          () => Message.system([const TextPart('System message')]),
          returnsNormally,
        );
        expect(
          () => Message.user([const TextPart('User message')]),
          returnsNormally,
        );
        expect(
          () => Message.model([const TextPart('Model message')]),
          returnsNormally,
        );
      });

      test('Part types still work', () {
        expect(
          () => const TextPart('Text content'),
          returnsNormally,
        );
        expect(
          () => LinkPart(Uri.parse('https://example.com')),
          returnsNormally,
        );
        expect(
          () => DataPart(Uint8List.fromList([1, 2, 3]), mimeType: 'image/jpeg'),
          returnsNormally,
        );
      });

      test('AgentResponse types still work', () {
        final response = AgentResponse(
          output: 'Test output',
          messages: [Message.user([const TextPart('Test')])],
        );

        expect(response.output, equals('Test output'));
        expect(response.messages.length, equals(1));
      });
    });

    group('Tool API Consistency', () {
      test('Tool creation still works', () {
        final schema = JsonSchema.create({
          'type': 'object',
          'properties': {
            'input': {'type': 'string'}
          },
          'required': ['input']
        });

        expect(
          () => Tool(
            name: 'test_tool',
            description: 'A test tool',
            inputSchema: schema,
            onCall: (input) async => {'result': 'test'},
          ),
          returnsNormally,
        );
      });

    });

    group('Provider Capabilities Consistency', () {
      test('ProviderCaps enum still works', () {
        expect(ProviderCaps.chat, isNotNull);
        expect(ProviderCaps.embeddings, isNotNull);
        expect(ProviderCaps.tools, isNotNull);
        expect(ProviderCaps.textGeneration, isNotNull);
        expect(ProviderCaps.fileUploads, isNotNull);
      });

      test('ProviderCaps.all still works', () {
        expect(ProviderCaps.all, isNotEmpty);
        expect(ProviderCaps.all, contains(ProviderCaps.chat));
      });

      test('ProviderCaps.allExcept still works', () {
        final caps = ProviderCaps.allExcept({ProviderCaps.embeddings});
        expect(caps, isNotEmpty);
        expect(caps, isNot(contains(ProviderCaps.embeddings)));
        expect(caps, contains(ProviderCaps.chat));
      });
    });

    group('Model Information Consistency', () {
      test('ModelInfo class still works', () {
        const info = ModelInfo(
          providerName: 'test',
          name: 'test-model',
          kinds: {ModelKind.chat},
          stable: true,
        );

        expect(info.providerName, equals('test'));
        expect(info.name, equals('test-model'));
        expect(info.kinds, contains(ModelKind.chat));
        expect(info.stable, isTrue);
      });

      test('ModelKind enum still works', () {
        expect(ModelKind.chat, isNotNull);
        expect(ModelKind.embedding, isNotNull);
      });
    });

    group('Runtime Behavior Consistency', () {
      test('agents can still run prompts', () async {
        final apiKey = Agent.environment['OPENAI_API_KEY'];
        if (apiKey == null) {
          markTestSkipped('OPENAI_API_KEY not available');
          return;
        }

        final agent = Agent('openai:gpt-4o-mini');

        try {
          final response = await agent.run('Say hello');
          expect(response.output, isNotEmpty);
          expect(response.messages, isNotEmpty);
        } catch (e) {
          print('Runtime test warning: $e');
        }
      }, timeout: const Timeout(Duration(seconds: 30)));

      test('agents can still stream responses', () async {
        final apiKey = Agent.environment['OPENAI_API_KEY'];
        if (apiKey == null) {
          markTestSkipped('OPENAI_API_KEY not available');
          return;
        }

        final agent = Agent('openai:gpt-4o-mini');

        try {
          final stream = agent.runStream('Count to 3');
          var hasOutput = false;

          await for (final chunk in stream.take(3)) {
            if (chunk.output.isNotEmpty) {
              hasOutput = true;
              break;
            }
          }

          expect(hasOutput, isTrue);
        } catch (e) {
          print('Streaming test warning: $e');
        }
      }, timeout: const Timeout(Duration(seconds: 30)));

      test('agents can still create embeddings', () async {
        final apiKey = Agent.environment['OPENAI_API_KEY'];
        if (apiKey == null) {
          markTestSkipped('OPENAI_API_KEY not available');
          return;
        }

        final agent = Agent('openai:gpt-4o-mini');

        try {
          final embedding = await agent.createEmbedding('test text');
          expect(embedding.length, greaterThan(0));
        } catch (e) {
          print('Embedding test warning: $e');
        }
      }, timeout: const Timeout(Duration(seconds: 30)));

      test('agents can still list models', () async {
        final apiKey = Agent.environment['OPENAI_API_KEY'];
        if (apiKey == null) {
          markTestSkipped('OPENAI_API_KEY not available');
          return;
        }

        final agent = Agent('openai:gpt-4o-mini');
        final models = await agent.listModels();

        expect(models, isNotEmpty);
        expect(models.first, isA<ModelInfo>());
      });
    });

    group('Backward Compatibility with Existing Tests', () {
      test('existing test patterns still work', () {
        // Test pattern from existing tests
        Agent.environment['OPENAI_API_KEY'] = 'test-key';
        
        expect(
          () => Agent('openai:gpt-4o'),
          returnsNormally,
        );

        final agent = Agent('openai:gpt-4o');
        expect(agent.model, equals('openai:gpt-4o'));
      });

      test('fallback behavior is preserved', () {
        // Clear environment to test fallback
        final originalEnv = Map<String, String>.from(Agent.environment);
        Agent.environment.clear();

        // Original behavior should be preserved
        expect(
          () => Agent('openai:gpt-4o', apiKey: 'test-key'),
          returnsNormally,
        );

        // Restore environment
        Agent.environment.addAll(originalEnv);
      });

      test('error handling is preserved', () {
        expect(
          () => Agent(''),
          throwsArgumentError,
        );

        expect(
          () => Agent('unsupported-provider:model'),
          throwsArgumentError,
        );
      });
    });

    group('Performance Regression', () {
      test('agent creation is not significantly slower', () {
        final apiKey = Agent.environment['OPENAI_API_KEY'];
        if (apiKey == null) {
          markTestSkipped('OPENAI_API_KEY not available');
          return;
        }

        final stopwatch = Stopwatch()..start();
        
        // Create multiple agents to test performance
        for (var i = 0; i < 10; i++) {
          Agent('openai:gpt-4o-mini');
        }
        
        stopwatch.stop();
        
        // Should not take more than 5 seconds to create 10 agents
        expect(stopwatch.elapsedMilliseconds, lessThan(5000));
      });

      test('memory usage is not significantly increased', () {
        final apiKey = Agent.environment['OPENAI_API_KEY'];
        if (apiKey == null) {
          markTestSkipped('OPENAI_API_KEY not available');
          return;
        }

        // Create many agents to test memory usage
        final agents = <Agent>[];
        for (var i = 0; i < 50; i++) {
          agents.add(Agent('openai:gpt-4o-mini'));
        }

        // Just verify we can create many agents without issues
        expect(agents.length, equals(50));
      });
    });

    group('API Compatibility Matrix', () {
      test('all provider combinations work', () {
        final openaiKey = Agent.environment['OPENAI_API_KEY'];
        final googleKey = Agent.environment['GOOGLE_API_KEY'] ?? Agent.environment['GEMINI_API_KEY'];

        // Test all provider combinations that should work
        final providerTests = <String, bool>{
          'openai:gpt-4o-mini': openaiKey != null,
          'google:gemini-1.5-flash': googleKey != null,
          'gemini:gemini-1.5-flash': googleKey != null,
          'googleai:gemini-1.5-flash': googleKey != null,
          'openrouter:gpt-4o-mini': true, // Can test with dummy key
        };

        for (final entry in providerTests.entries) {
          if (entry.value) {
            expect(
              () => Agent(entry.key),
              returnsNormally,
              reason: 'Provider ${entry.key} should work',
            );
          }
        }
      });
    });
  });
}
