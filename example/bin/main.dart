// ignore_for_file: avoid_print, unreachable_from_main

import 'dart:io';

import 'package:dartantic_ai/dartantic_ai.dart';
import 'package:example/town_and_country.dart';

// Provider? get provider => GeminiProvider();
// Provider? get provider => OpenAiProvider();
Provider? get provider => null;

String? get model => 'google-gla:gemini-2.0-flash';
// String? get model => 'openai:gpt-4o';
// String? get model => null;

String get displayName => provider?.displayName ?? model ?? 'ERROR';

void main() async {
  // examples from https://ai.pydantic.dev/
  await helloWorldExample();
  await outputTypeExampleWithJsonSchemaAndStringOutput();
  await outputTypeExampleWithJsonSchemaAndOutjectOutput();
  await outputTypeExampleWithSotiSchema();
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

  final tncSchema = {
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

  final tncSchema = {
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
