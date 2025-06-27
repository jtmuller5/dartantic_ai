// ignore_for_file: avoid_print

import 'dart:io';

import 'package:dartantic_ai/dartantic_ai.dart';
import 'package:example/temp_tool_call.dart';
import 'package:example/time_tool_call.dart';

void main() async {
  await toolExample();
  await toolExampleWithTypedOutput();
  await multiStepToolExample();
  exit(0);
}

Future<void> toolExample() async {
  print('toolExample');

  final agent = Agent(
    'openai',
    systemPrompt:
        'Be sure to include the name of the location in your response. Show '
        'the time as local time. Do not ask any follow up questions.',
    tools: [
      Tool(
        name: 'time',
        description: 'Get the current time in a given time zone',
        inputSchema: TimeFunctionInput.schemaMap.toSchema(),
        onCall: onTimeCall,
      ),
      Tool(
        name: 'temp',
        description: 'Get the current temperature in a given location',
        inputSchema: TempFunctionInput.schemaMap.toSchema(),
        onCall: onTempCall,
      ),
    ],
  );

  await agent
      .runStream('What is the time and temperature in New York City?')
      .map((event) => stdout.write(event.output))
      .drain();
  print('');
}

Future<void> toolExampleWithTypedOutput() async {
  print('\ntoolExampleWithTypedOutput');

  final agent = Agent(
    'openai',
    systemPrompt:
        'Be sure to include the name of the location in your response. '
        'Show all dates and times in ISO 8601 format.',
    tools: [
      Tool(
        name: 'time',
        description: 'Get the current time in a given time zone',
        inputSchema: TimeFunctionInput.schemaMap.toSchema(),
        onCall: onTimeCall,
      ),
      Tool(
        name: 'temp',
        description: 'Get the current temperature in a given location',
        inputSchema: TempFunctionInput.schemaMap.toSchema(),
        onCall: onTempCall,
      ),
    ],
  );

  await agent
      .runStream(
        'What is the time and temperature in New York City and Chicago?',
      )
      .map((event) => stdout.write(event.output))
      .drain();
  print('');
}

Future<void> multiStepToolExample() async {
  print('\nmultiStepToolExample - Autonomous Tool Chaining');

  final agent = Agent(
    'openai',
    systemPrompt:
        'You are a helpful assistant that can chain tools together to solve complex problems. '
        'When asked to find events, first get the current time, then search for events on that date.',
    tools: [
      Tool(
        name: 'get_current_time',
        description: 'Get the current date and time',
        onCall: (args) async {
          print('🕐 Tool called: get_current_time');
          return {
            'datetime': DateTime.now().toIso8601String(),
            'date': DateTime.now().toIso8601String().split('T')[0],
          };
        },
      ),
      Tool(
        name: 'find_events',
        description: 'Find events for a specific date',
        inputSchema: {
          'type': 'object',
          'properties': {
            'date': {
              'type': 'string',
              'description': 'Date to search for events (YYYY-MM-DD format)',
            },
          },
          'required': ['date'],
        }.toSchema(),
        onCall: (args) async {
          print('📅 Tool called: find_events with date: ${args['date']}');
          return {
            'events': [
              {'title': 'Team Meeting', 'time': '10:00 AM', 'location': 'Conference Room A'},
              {'title': 'Lunch with Client', 'time': '12:30 PM', 'location': 'Downtown Cafe'},
              {'title': 'Project Review', 'time': '3:00 PM', 'location': 'Online'},
            ],
          };
        },
      ),
      Tool(
        name: 'get_weather',
        description: 'Get weather information for event planning',
        inputSchema: {
          'type': 'object',
          'properties': {
            'location': {
              'type': 'string',
              'description': 'Location to get weather for',
            },
          },
          'required': ['location'],
        }.toSchema(),
        onCall: (args) async {
          print('🌤️ Tool called: get_weather for: ${args['location']}');
          return {
            'temperature': '72°F',
            'condition': 'Partly cloudy',
            'humidity': '45%',
          };
        },
      ),
    ],
  );

  print('\nAsking agent: "What events do I have today and what\'s the weather like?"\n');
  
  await agent
      .runStream('What events do I have today and what\'s the weather like?')
      .map((event) => stdout.write(event.output))
      .drain();
  
  print('\n\n✨ Notice how the agent autonomously:');
  print('   1. Called get_current_time to find today\'s date');
  print('   2. Used that date to call find_events');
  print('   3. Called get_weather for planning context');
  print('   4. Provided a comprehensive response combining all results');
  print('');
}
