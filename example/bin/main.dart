// ignore_for_file: avoid_print, unreachable_from_main

import 'package:dartantic_ai/dartantic_ai.dart';

void main() async {
  final agent = Agent.model(
    'openai',
    systemPrompt: 'Be concise, reply with one sentence.',
  );

  final result = await agent.run('Where does "hello world" come from?');
  print(result.output);
}
