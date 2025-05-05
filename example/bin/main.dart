// ignore_for_file: avoid_print, unreachable_from_main

import 'dart:io';

import 'package:ack/ack.dart';
import 'package:dartantic_ai/dartantic_ai.dart';
import 'package:json_annotation/json_annotation.dart';

part 'main.g.dart';

// final provider = GeminiProvider();
final provider = OpenAiProvider();

// from https://ai.pydantic.dev/
void main() async {
  await helloWorldExample();
  await outputTypeExampleWithAck();
  await outputTypeExampleWithJsonSchema();
  // await outputTypeExampleWithSotiSchema();
  exit(0);
}

Future<void> helloWorldExample() async {
  print('\nhelloWorldExample: ${provider.displayName}');
  final agent = Agent(
    provider: provider,
    systemPrompt: 'Be concise, reply with one sentence.',
  );

  final result = await agent.run('Where does "hello world" come from?');
  print(result.output);
}

@JsonSerializable()
class TownAndCountry {
  TownAndCountry({required this.town, required this.country});

  factory TownAndCountry.fromJson(Map<String, dynamic> json) =>
      _$TownAndCountryFromJson(json);

  final String town;
  final String country;

  Map<String, dynamic> toJson() => _$TownAndCountryToJson(this);

  @override
  String toString() => 'TownAndCountry(town: $town, country: $country)';
}

Future<void> outputTypeExampleWithAck() async {
  print('\nschemaExampleWithAck: ${provider.displayName}');

  final tncSchema = Ack.object(
    {'town': Ack.string(), 'country': Ack.string()},
    required: ['town', 'country'],
  );

  final agent = Agent(
    provider: provider,
    outputType: tncSchema.toMap(),
    outputFromJson: TownAndCountry.fromJson,
  );

  final result = await agent.runFor<TownAndCountry>(
    'The windy city in the US of A.',
  );
  print(result.output);
}

Future<void> outputTypeExampleWithJsonSchema() async {
  print('\nschemaExampleWithJsonSchema: ${provider.displayName}');

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
    outputType: tncSchema,
    outputFromJson: TownAndCountry.fromJson,
  );

  final result = await agent.runFor<TownAndCountry>(
    'The windy city in the US of A.',
  );
  print(result.output);
}

// Future<void> outputTypeExampleWithSotiSchema() async {
//   print('\nschemaExampleWithSotiSchema: ${modelConfig.displayName}');

//   final agent = Agent(
//     modelConfig: modelConfig,
//     outputType: tncSchema,
//     instrument: true,
//   );

//   final result = await agent.run('The windy city in the US of A.');
//   print(result.output);
// }
