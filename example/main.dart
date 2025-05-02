// ignore_for_file: avoid_print, unreachable_from_main

import 'dart:io';

import 'package:dartantic_ai/dartantic_ai.dart';

final modelConfig = GeminiConfig();
// final modelConfig = OpenAiConfig();

// from https://ai.pydantic.dev/
void main() async {
  await helloWorldExample();
  // await toolsAndDependencyInjectionExample();
  // await modelExample();
  exit(0);
}

Future<void> helloWorldExample() async {
  print('helloWorldExample: ${modelConfig.displayName}');
  final agent = Agent(
    modelConfig: modelConfig,
    systemPrompt: 'Be concise, reply with one sentence.',
  );

  final result = await agent.run('Where does "hello world" come from?');
  print(result.output);
}

Future<void> toolsAndDependencyInjectionExample() async {
  print('toolsAndDependencyInjectionExample: ${modelConfig.displayName}');
  // TODO: https://ai.pydantic.dev/#tools-dependency-injection-example
}

class MyModel {
  MyModel({required this.city, required this.country});
  final String city;
  final String country;
}

Future<void> modelExample() async {
  print('modelExample: ${modelConfig.displayName}');
  // final agent = Agent(model, output_type: MyModel, instrument: true);
  // final result = await agent.runSync('The windy city in the US of A.');
  // print(result.output);
  // print(result.usage());
}
