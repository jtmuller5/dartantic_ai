// ignore_for_file: avoid_print, unreachable_from_main

import 'package:dartantic_ai/dartantic_ai.dart';

void main() async {
  await helloWorldExample(GeminiConfig());
  await helloWorldExample(OpenAiConfig());
  // await helloWorldExample(OpenAiConfig(model: 'gemini-2.0-flash'));
  // await helloWorldExample();
  // await toolsAndDependencyInjectionExample();
  // await modelExample();
}

Future<void> helloWorldExample(ModelConfig modelConfig) async {
  print('helloWorldExample: ${modelConfig.displayName}');
  final agent = Agent(
    modelConfig: modelConfig,
    systemPrompt: 'Be concise, reply with one sentence.',
  );

  final result = await agent.generate('Where does "hello world" come from?');
  print(result.output);
}

Future<void> toolsAndDependencyInjectionExample() async {
  // TODO: https://ai.pydantic.dev/#hello-world-example
}

class MyModel {
  MyModel({required this.city, required this.country});
  final String city;
  final String country;
}

Future<void> modelExample() async {
  // final agent = Agent(model, output_type: MyModel, instrument: true);
  // final result = await agent.runSync('The windy city in the US of A.');
  // print(result.output);
  // print(result.usage());
}
