// ignore_for_file: avoid_print, unreachable_from_main

import 'dart:io';

import 'package:dartantic_ai/dartantic_ai.dart';
import 'package:example/loc_time_temp.dart';
import 'package:example/temp_tool_call.dart';
import 'package:example/time_tool_call.dart';
import 'package:example/town_and_country.dart';

// Provider? get provider => GeminiProvider();
// Provider? get provider => OpenAiProvider();
Provider? get provider => null;

// String? get model => 'google';
String? get model => 'openai';
// String? get model => 'google:gemini-2.0-flash';
// String? get model => 'openai:gpt-4o';
// String? get model => null;

String get displayName => (provider ?? Agent.providerFor(model!)).displayName;

void main() async {
  await helloWorldExample();
  await outputTypeExampleWithJsonSchemaAndStringOutput();
  await outputTypeExampleWithJsonSchemaAndOutjectOutput();
  await outputTypeExampleWithSotiSchema();
  await toolExample();
  await toolExampleWithTypedOutput();
  exit(0);
}

Future<void> helloWorldExample() async {
  print('\nhelloWorldExample: $displayName');

  final agent = Agent(
    provider: provider,
    model: model,
    systemPrompt: 'Be concise, reply with one sentence.',
  );

  final result = await agent.run('Where does "hello world" come from?');
  print(result.output);
}

Future<void> outputTypeExampleWithJsonSchemaAndStringOutput() async {
  print('\noutputTypeExampleWithJsonSchemaAndStringOutput: $displayName');

  final tncSchema = <String, Object>{
    'type': 'object',
    'properties': {
      'town': {'type': 'string'},
      'country': {'type': 'string'},
    },
    'required': ['town', 'country'],
    'additionalProperties': false,
  };

  final agent = Agent(provider: provider, model: model, outputType: tncSchema);
  final result = await agent.run('The windy city in the US of A.');
  print(result.output);
}

Future<void> outputTypeExampleWithJsonSchemaAndOutjectOutput() async {
  print('\noutputTypeExampleWithJsonSchemaAndOutjectOutput: $displayName');

  final tncSchema = <String, Object>{
    'type': 'object',
    'properties': {
      'town': {'type': 'string'},
      'country': {'type': 'string'},
    },
    'required': ['town', 'country'],
    'additionalProperties': false,
  };

  final agent = Agent(
    provider: provider,
    model: model,
    outputType: tncSchema,
    outputFromJson: TownAndCountry.fromJson,
  );

  final result = await agent.runFor<TownAndCountry>(
    'The windy city in the US of A.',
  );

  print(result.output);
}

Future<void> outputTypeExampleWithSotiSchema() async {
  print('\noutputTypeExampleWithSotiSchema: $displayName');

  final agent = Agent(
    provider: provider,
    model: model,
    outputType: TownAndCountry.schemaMap,
    outputFromJson: TownAndCountry.fromJson,
  );

  final result = await agent.runFor<TownAndCountry>(
    'The windy city in the US of A.',
  );

  print(result.output);
}

Future<void> toolExample() async {
  print('\ntoolExample: $displayName');

  final agent = Agent(
    provider: provider,
    model: model,
    systemPrompt:
        'Be sure to include the name of the location in your response. Show '
        'the time as local time. Do not ask any follow up questions.',
    tools: [
      Tool(
        name: 'time',
        description: 'Get the current time in a given time zone',
        inputType: TimeFunctionInput.schemaMap,
        onCall: onTimeCall,
      ),
      Tool(
        name: 'temp',
        description: 'Get the current temperature in a given location',
        inputType: TempFunctionInput.schemaMap,
        onCall: onTempCall,
      ),
    ],
  );

  final result = await agent.run(
    'What is the time and temperature in New York City?',
  );

  print(result.output);
}

// NOTE: can the Agent handle tools+typed output itself even if the underlying
// models don't support it?
Future<void> toolExampleWithTypedOutput() async {
  print('\ntoolExampleWithTypedOutput: $displayName');

  final agent = Agent(
    provider: provider,
    model: model,
    systemPrompt:
        'Be sure to include the name of the location in your response. '
        'Show all dates and times in ISO 8601 format.',
    tools: [
      Tool(
        name: 'time',
        description: 'Get the current time in a given time zone',
        inputType: TimeFunctionInput.schemaMap,
        onCall: onTimeCall,
      ),
      Tool(
        name: 'temp',
        description: 'Get the current temperature in a given location',
        inputType: TempFunctionInput.schemaMap,
        onCall: onTempCall,
      ),
    ],
  );

  final result = await agent.run(
    'What is the time and temperature in New York City and Chicago?',
  );

  final agent2 = Agent(
    provider: provider,
    model: model,
    systemPrompt: "Translate the user's prompt into a tool call.",
    outputType: ListOfLocTimeTemps.schemaMap,
    outputFromJson: ListOfLocTimeTemps.fromJson,
  );

  final result2 = await agent2.runFor<ListOfLocTimeTemps>(result.output);
  print(result2.output);
}
