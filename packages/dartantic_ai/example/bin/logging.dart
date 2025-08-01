// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:dartantic_ai/dartantic_ai.dart';
import 'package:logging/logging.dart';

void main() async {
  await defaultLogging();
  await levelFiltering();
  await providerFiltering();
  await customHandlers();
  exit(0);
}

Future<void> defaultLogging() async {
  print('\nDefault Logging');
  print('-' * 30);

  // Enable default logging - shows INFO level and above
  Agent.loggingOptions = const LoggingOptions();

  print('Creating an agent with default logging...');
  final agent = Agent('openai:gpt-4o-mini');

  print('Running a simple conversation...');
  final result = await agent.send('Hello! Just say hi back.');

  print('Response: ${result.output}');
}

Future<void> levelFiltering() async {
  print('\nLevel Filtering');
  print('-' * 30);

  // First, show FINE level for detailed debugging
  print('Setting level to FINE for detailed debugging...');
  Agent.loggingOptions = LoggingOptions(
    level: Level.FINE,
    onRecord:
        (record) => print(
          '[${record.level.name}] ${record.loggerName}: ${record.message}',
        ),
  );

  final agent = Agent('openai:gpt-3.5-turbo');
  await agent.send('Quick test');

  // Now show WARNING level for production
  print('\nSetting level to WARNING for production...');
  Agent.loggingOptions = LoggingOptions(
    level: Level.WARNING,
    onRecord:
        (record) => print(
          '[${record.level.name}] ${record.loggerName}: ${record.message}',
        ),
  );

  // This should show no logs (no warnings/errors expected)
  await agent.send('Another test');
  print("(No warnings/errors - that's good!)");
}

Future<void> providerFiltering() async {
  print('\nProvider Filtering');
  print('-' * 30);

  // Filter to only OpenAI operations
  print('Filtering to only OpenAI operations...');
  Agent.loggingOptions = LoggingOptions(
    filter: 'openai',
    onRecord:
        (record) => print('OpenAI: ${record.loggerName} - ${record.message}'),
  );

  final openaiAgent = Agent('openai:gpt-4o-mini');
  await openaiAgent.send('Test OpenAI');

  // Filter to agent operations only
  print('\nFiltering to only Agent operations...');
  Agent.loggingOptions = LoggingOptions(
    filter: 'agent',
    onRecord:
        (record) => print('Agent: ${record.loggerName} - ${record.message}'),
  );

  final agentForAgentLogs = Agent('openai:gpt-3.5-turbo');
  await agentForAgentLogs.send('Test agent logging');
}

Future<void> customHandlers() async {
  print('\nCustom Handlers');
  print('-' * 30);

  // Colored console output
  Agent.loggingOptions = LoggingOptions(
    onRecord: (record) {
      final color = _getColorForLevel(record.level);
      final component = record.loggerName.split('.').last;
      print('$color[$component] ${record.message}\x1B[0m');
    },
  );

  print('Using custom colored logging...');
  final agent = Agent('openai:gpt-4o-mini');
  await agent.send('Show me colors!');

  // JSON structured logging
  print('\nUsing JSONL structured logging...');
  Agent.loggingOptions = LoggingOptions(
    onRecord: (record) {
      print(
        jsonEncode({
          'timestamp': DateTime.now().toIso8601String(),
          'level': record.level.name,
          'logger': record.loggerName,
          'message': record.message,
          'component': record.loggerName.split('.').last,
        }),
      );
    },
  );

  await agent.send('Show me JSON!');
}

// Helper functions for custom logging

String _getColorForLevel(Level level) {
  switch (level.name) {
    case 'FINE':
      return '\x1B[36m'; // Cyan
    case 'INFO':
      return '\x1B[32m'; // Green
    case 'WARNING':
      return '\x1B[33m'; // Yellow
    case 'SEVERE':
      return '\x1B[31m'; // Red
    default:
      return '\x1B[37m'; // White
  }
}
