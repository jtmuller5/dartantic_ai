// ignore_for_file: avoid_print

import 'dart:io';

import 'package:dartantic_ai/dartantic_ai.dart';
import 'package:dartantic_interface/dartantic_interface.dart';

void main() async {
  print('=== Multi-turn Conversation Example ===\n');

  // Create an agent
  final agent = Agent('anthropic:claude-3-5-haiku-latest');

  // Start a conversation
  final messages = <ChatMessage>[];

  // First turn
  print('User: My name is Alice. Can you remember that?');
  var response = await agent.send(
    'My name is Alice. Can you remember that?',
    history: messages,
  );
  print('Assistant: ${response.output}\n');

  // Add user message and assistant response to history
  messages.add(
    const ChatMessage(
      role: ChatMessageRole.user,
      parts: [TextPart('My name is Alice. Can you remember that?')],
    ),
  );
  messages.add(
    ChatMessage(
      role: ChatMessageRole.model,
      parts: [TextPart(response.output)],
    ),
  );

  // Second turn
  print('User: What is my name?');
  response = await agent.send('What is my name?', history: messages);
  print('Assistant: ${response.output}\n');

  // Add to history
  messages.add(
    const ChatMessage(
      role: ChatMessageRole.user,
      parts: [TextPart('What is my name?')],
    ),
  );
  messages.add(
    ChatMessage(
      role: ChatMessageRole.model,
      parts: [TextPart(response.output)],
    ),
  );

  // Third turn with different provider
  print('=== Switching to OpenAI ===\n');
  final openaiAgent = Agent('openai:gpt-4o-mini');

  print('User: Can you tell me what we talked about?');
  response = await openaiAgent.send(
    'Can you tell me what we talked about?',
    history: messages,
  );
  print('Assistant: ${response.output}\n');

  // Example with system message
  print('=== Example with System Message (Google) ===\n');
  final googleAgent = Agent('google:gemini-2.0-flash');

  print('System: You are a helpful assistant who speaks like a pirate.');
  print('User: Tell me about the weather today.');
  response = await googleAgent.send(
    'Tell me about the weather today.',
    history: [
      ChatMessage.system(
        'You are a helpful assistant who speaks like a pirate.',
      ),
    ],
  );
  print('Assistant: ${response.output}\n');

  exit(0);
}
