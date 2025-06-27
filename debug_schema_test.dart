import 'package:dartantic_ai/dartantic_ai.dart';

void main() async {
  print('Testing JSON Schema Configuration...');
  
  final outputSchema = <String, dynamic>{
    'type': 'object',
    'properties': {
      'town': {'type': 'string'},
      'country': {'type': 'string'},
    },
    'required': ['town', 'country'],
    'additionalProperties': false,
  };

  // Test 1: Schema with runStream (like working test)
  print('\n=== Test 1: Schema with runStream ===');
  final agent1 = Agent('openai', outputSchema: outputSchema.toSchema());
  final output1 = StringBuffer();
  await for (final chunk in agent1.runStream('The windy city in the US of A.')) {
    output1.write(chunk.output);
  }
  print('Result 1: $output1');
  
  // Test 2: Schema with run (intermediate)
  print('\n=== Test 2: Schema with run ===');
  final agent2 = Agent('openai', outputSchema: outputSchema.toSchema());
  final result2 = await agent2.run('The windy city in the US of A.');
  print('Result 2: ${result2.output}');
  
  // Test 3: Schema with outputFromJson but using run instead of runFor
  print('\n=== Test 3: Schema with outputFromJson but using run ===');
  final agent3 = Agent(
    'openai', 
    outputSchema: outputSchema.toSchema(),
    outputFromJson: (json) => {
      'town': json['town'] as String,
      'country': json['country'] as String,
    },
  );
  final result3 = await agent3.run('The windy city in the US of A.');
  print('Result 3: ${result3.output}');
}
