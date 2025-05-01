import 'dart:io';

import 'package:dartantic_ai/dartantic_ai.dart';

void main() async {
  final agent = GeminiAgent(
    apiKey: Platform.environment['GEMINI_API_KEY']!,
    model: 'gemini-2.0-flash',
    systemPrompt: 'Be concise, reply with one sentence.',
  );

  final result = await agent.generate('Where does "hello world" come from?');
  print(result.output);
}
