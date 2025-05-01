// ignore_for_file: avoid_print

import 'dart:io';

import 'package:dartantic_ai/dartantic_ai.dart';

void main() async {
  await helloWorldExample();
}

String getEnv(String key) {
  final value = Platform.environment[key];
  if (value == null || value.isEmpty) {
    throw Exception('Environment variable $key is not set');
  }
  return value;
}

Future<void> helloWorldExample() async {
  final agent = GeminiAgent(
    apiKey: getEnv('GEMINI_API_KEY'),
    model: 'gemini-2.0-flash',
    systemPrompt: 'Be concise, reply with one sentence.',
  );

  final result = await agent.generate('Where does "hello world" come from?');
  print(result.output);
}

Future<void> toolsAndDependencyInjectionExample() async {
  // TODO: https://ai.pydantic.dev/#hello-world-example
}
