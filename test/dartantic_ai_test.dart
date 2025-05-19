import 'package:dartantic_ai/dartantic_ai.dart';
import 'package:test/test.dart';

void main() {
  group('Dartantic AI Integration Tests', () {
    group('Agent.model constructor', () {
      test('Hello World Example', () async {
        final agent = Agent.model(
          'openai',
          systemPrompt: 'Be concise, reply with one sentence.',
        );

        final result = await agent.run('Where does "hello world" come from?');
        expect(result.output, isNotEmpty);
        expect(RegExp(r'\.').allMatches(result.output).length, equals(1));
      });

      test('JSON Schema String Output', () async {
        final outputSchema = <String, Object>{
          'type': 'object',
          'properties': {
            'town': {'type': 'string'},
            'country': {'type': 'string'},
          },
          'required': ['town', 'country'],
          'additionalProperties': false,
        };

        final agent = Agent.model('openai', outputType: outputSchema);
        final result = await agent.run('The windy city in the US of A.');
        expect(result.output, isNotEmpty);
        expect(result.output, contains('Chicago'));
      });

      test('JSON Schema Object Output', () async {
        final tncSchema = <String, Object>{
          'type': 'object',
          'properties': {
            'town': {'type': 'string'},
            'country': {'type': 'string'},
          },
          'required': ['town', 'country'],
          'additionalProperties': false,
        };

        final agent = Agent.model(
          'openai',
          outputType: tncSchema,
          outputFromJson:
              (json) => {
                'town': json['town'] as String,
                'country': json['country'] as String,
              },
        );

        final result = await agent.runFor<Map<String, String>>(
          'The windy city in the US of A.',
        );

        expect(result.output, isA<Map<String, String>>());
        expect(result.output['town'], isNotEmpty);
        expect(result.output['country'], isNotEmpty);
        expect(result.output['town'], equals('Chicago'));
        expect(
          result.output['country'],
          isIn(['USA', 'United States', 'United States of America']),
        );
      });

      test('Tool Usage Example', () async {
        final agent = Agent.model(
          'openai',
          systemPrompt:
              'Be sure to include the name of the location in your response. '
              'Show the time as local time. '
              'Do not ask any follow up questions.',
          tools: [
            Tool(
              name: 'time',
              description: 'Get the current time in a given time zone',
              inputType: {
                'type': 'object',
                'properties': {
                  'timeZoneName': {
                    'type': 'string',
                    'description':
                        'The name of the time zone (e.g. "America/New_York")',
                  },
                },
                'required': ['timeZoneName'],
              },
              onCall:
                  (input) async => {'time': DateTime.now().toIso8601String()},
            ),
            Tool(
              name: 'temp',
              description: 'Get the current temperature in a given location',
              inputType: {
                'type': 'object',
                'properties': {
                  'location': {
                    'type': 'string',
                    'description': 'The location to get temperature for',
                  },
                },
                'required': ['location'],
              },
              onCall: (input) async => {'temperature': 72}, // Mock temperature
            ),
          ],
        );

        final result = await agent.run(
          'What is the time and temperature in New York City?',
        );

        expect(result.output, isNotEmpty);
        expect(result.output, contains('New York'));
      });

      test('Gemini Integration', () async {
        final agent = Agent.model(
          'google:gemini-2.0-flash',
          outputType: {
            'type': 'object',
            'properties': {
              'town': {'type': 'string'},
              'country': {'type': 'string'},
            },
            'required': ['town', 'country'],
            'additionalProperties': false,
          },
          outputFromJson:
              (json) => {
                'town': json['town'] as String,
                'country': json['country'] as String,
              },
        );

        final result = await agent.runFor<Map<String, String>>(
          'The windy city in the US of A.',
        );

        expect(result.output, isA<Map<String, String>>());
        expect(result.output['town'], equals('Chicago'));
        expect(
          result.output['country'],
          isIn(['USA', 'United States', 'United States of America']),
        );
      });

      test('OpenAI Integration', () async {
        final agent = Agent.model(
          'openai:gpt-4o',
          outputType: {
            'type': 'object',
            'properties': {
              'town': {'type': 'string'},
              'country': {'type': 'string'},
            },
            'required': ['town', 'country'],
            'additionalProperties': false,
          },
          outputFromJson:
              (json) => {
                'town': json['town'] as String,
                'country': json['country'] as String,
              },
        );

        final result = await agent.runFor<Map<String, String>>(
          'The windy city in the US of A.',
        );

        expect(result.output, isA<Map<String, String>>());
        expect(result.output['town'], equals('Chicago'));
        expect(
          result.output['country'],
          isIn(['USA', 'United States', 'United States of America']),
        );
      });
    });

    group('Agent constructor with provider', () {
      test('OpenAI Provider Basic', () async {
        final agent = Agent(
          OpenAiProvider(),
          systemPrompt: 'Be concise, reply with one sentence.',
        );

        final result = await agent.run('Where does "hello world" come from?');
        expect(result.output, isNotEmpty);
        expect(RegExp(r'\.').allMatches(result.output).length, equals(1));
      });

      test('OpenAI Provider with Schema', () async {
        final agent = Agent(
          OpenAiProvider(),
          outputType: {
            'type': 'object',
            'properties': {
              'town': {'type': 'string'},
              'country': {'type': 'string'},
            },
            'required': ['town', 'country'],
            'additionalProperties': false,
          },
          outputFromJson:
              (json) => {
                'town': json['town'] as String,
                'country': json['country'] as String,
              },
        );

        final result = await agent.runFor<Map<String, String>>(
          'The windy city in the US of A.',
        );

        expect(result.output, isA<Map<String, String>>());
        expect(result.output['town'], equals('Chicago'));
        expect(
          result.output['country'],
          isIn(['USA', 'United States', 'United States of America']),
        );
      });

      test('Gemini Provider Basic', () async {
        final agent = Agent(
          GeminiProvider(),
          systemPrompt: 'Be concise, reply with one sentence.',
        );

        final result = await agent.run('Where does "hello world" come from?');
        expect(result.output, isNotEmpty);
        expect(RegExp(r'\.').allMatches(result.output).length, equals(1));
      });

      test('Gemini Provider with Schema', () async {
        final agent = Agent(
          GeminiProvider(),
          outputType: {
            'type': 'object',
            'properties': {
              'town': {'type': 'string'},
              'country': {'type': 'string'},
            },
            'required': ['town', 'country'],
            'additionalProperties': false,
          },
          outputFromJson:
              (json) => {
                'town': json['town'] as String,
                'country': json['country'] as String,
              },
        );

        final result = await agent.runFor<Map<String, String>>(
          'The windy city in the US of A.',
        );

        expect(result.output, isA<Map<String, String>>());
        expect(result.output['town'], equals('Chicago'));
        expect(
          result.output['country'],
          isIn(['USA', 'United States', 'United States of America']),
        );
      });

      test('Provider with Tools', () async {
        final agent = Agent(
          OpenAiProvider(),
          systemPrompt:
              'Be sure to include the name of the location in your response. '
              'Show the time as local time. '
              'Do not ask any follow up questions.',
          tools: [
            Tool(
              name: 'time',
              description: 'Get the current time in a given time zone',
              inputType: {
                'type': 'object',
                'properties': {
                  'timeZoneName': {
                    'type': 'string',
                    'description':
                        'The name of the time zone (e.g. "America/New_York")',
                  },
                },
                'required': ['timeZoneName'],
              },
              onCall:
                  (input) async => {'time': DateTime.now().toIso8601String()},
            ),
            Tool(
              name: 'temp',
              description: 'Get the current temperature in a given location',
              inputType: {
                'type': 'object',
                'properties': {
                  'location': {
                    'type': 'string',
                    'description': 'The location to get temperature for',
                  },
                },
                'required': ['location'],
              },
              // Mock temperature
              onCall: (input) async => {'temperature': 72},
            ),
          ],
        );

        final result = await agent.run(
          'What is the time and temperature in New York City?',
        );

        expect(result.output, isNotEmpty);
        expect(result.output, contains('New York'));
      });
    });
  });
}
