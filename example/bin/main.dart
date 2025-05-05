// ignore_for_file: avoid_print, unreachable_from_main

import 'dart:io';

import 'package:ack/ack.dart';
import 'package:dartantic_ai/dartantic_ai.dart';
import 'package:json_annotation/json_annotation.dart';

part 'main.g.dart';

final provider = GeminiProvider();
// final provider = OpenAiProvider();

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
class MyModel {
  MyModel({required this.city, required this.country});

  factory MyModel.fromJson(Map<String, dynamic> json) =>
      _$MyModelFromJson(json);

  final String city;
  final String country;

  Map<String, dynamic> toJson() => _$MyModelToJson(this);

  @override
  String toString() => 'MyModel(city: $city, country: $country)';
}

Future<void> outputTypeExampleWithAck() async {
  print('\nschemaExampleWithAck: ${provider.displayName}');

  final myModelSchema = Ack.object(
    {'city': Ack.string(), 'country': Ack.string()},
    required: ['city', 'country'],
  );

  final agent = Agent(
    provider: provider,
    outputType: myModelSchema.toMap(),
    outputFromJson: MyModel.fromJson,
  );

  final result = await agent.runFor<MyModel>('The windy city in the US of A.');
  print(result.output);
}

Future<void> outputTypeExampleWithJsonSchema() async {
  print('\nschemaExampleWithJsonSchema: ${provider.displayName}');

  final myModelSchema = {
    'type': 'object',
    'properties': {
      'city': {'type': 'string'},
      'country': {'type': 'string'},
    },
    'required': ['city', 'country'],
    'additionalProperties': false,
  };

  final agent = Agent(
    provider: provider,
    outputType: myModelSchema,
    outputFromJson: MyModel.fromJson,
  );

  final result = await agent.runFor<MyModel>('The windy city in the US of A.');
  print(result.output);
}

// Future<void> outputTypeExampleWithSotiSchema() async {
//   print('\nschemaExampleWithSotiSchema: ${modelConfig.displayName}');

//   final agent = Agent(
//     modelConfig: modelConfig,
//     outputType: myModelSchema,
//     instrument: true,
//   );

//   final result = await agent.run('The windy city in the US of A.');
//   print(result.output);
//   print('');
// }
