# Langchain Integration Documentation

This document describes the Langchain integration in dartantic_ai, including new features, backward compatibility, and migration guidance.

## Overview

The dartantic_ai library now includes optional Langchain integration that provides enhanced prompt execution capabilities while maintaining full backward compatibility with the existing API. This integration is transparent to users and does not require any changes to existing code.

## Key Features

### 1. Transparent Integration
- **Zero Breaking Changes**: All existing code continues to work without modification
- **Automatic Fallback**: If Langchain initialization fails, the library falls back to original implementations
- **Same API**: All Agent methods and properties work exactly the same

### 2. Enhanced Providers

#### Langchain-OpenAI Provider
```dart
// New langchain-enhanced provider
final agent = Agent('langchain-openai:gpt-4o');

// Original provider still works
final originalAgent = Agent('openai:gpt-4o');
```

**Supported Models:**
- `gpt-4o`
- `gpt-4o-mini` 
- `gpt-3.5-turbo`
- `text-embedding-3-small`
- `text-embedding-3-large`

#### Langchain-Google Provider
```dart
// New langchain-enhanced provider
final agent = Agent('langchain-google:gemini-2.0-flash');

// Original provider still works
final originalAgent = Agent('google:gemini-2.0-flash');
```

**Supported Models:**
- `gemini-2.0-flash`
- `gemini-1.5-pro`
- `gemini-1.5-flash`
- `text-embedding-004`

### 3. Enhanced Features Through Langchain

#### Advanced Prompt Templates
The Langchain integration provides enhanced system prompt handling and message processing:

```dart
final agent = Agent(
  'langchain-openai:gpt-4o',
  systemPrompt: 'You are a helpful assistant with enhanced capabilities.',
);
```

#### Improved Tool Calling
Tools are automatically converted for optimal Langchain execution:

```dart
final tool = Tool(
  name: 'calculator',
  description: 'Performs calculations',
  inputSchema: JsonSchema.create({
    'type': 'object',
    'properties': {
      'operation': {'type': 'string'},
      'a': {'type': 'number'},
      'b': {'type': 'number'},
    },
    'required': ['operation', 'a', 'b']
  }),
  onCall: (input) async {
    // Tool implementation
    return {'result': 42};
  },
);

final agent = Agent(
  'langchain-openai:gpt-4o',
  tools: [tool],
);
```

#### Enhanced Embeddings
Langchain provides improved embedding generation with consistent APIs:

```dart
final agent = Agent('langchain-openai:gpt-4o');
final embedding = await agent.createEmbedding('Your text here');
```

## API Compatibility

### Agent Creation
All existing Agent creation patterns continue to work:

```dart
// Simple model specification
final agent1 = Agent('openai:gpt-4o');

// With system prompt
final agent2 = Agent(
  'openai:gpt-4o',
  systemPrompt: 'You are helpful',
);

// With all options
final agent3 = Agent(
  'openai:gpt-4o',
  systemPrompt: 'System prompt',
  temperature: 0.7,
  tools: [tool],
  outputSchema: schema,
);

// Provider-based creation
final provider = Agent.providerFor('openai:gpt-4o');
final agent4 = Agent.provider(provider);
```

### Message Handling
All message types and operations remain the same:

```dart
final messages = [
  Message.system([TextPart('System message')]),
  Message.user([TextPart('User message')]),
  Message.model([TextPart('Model response')]),
];

final response = await agent.run('Prompt', messages: messages);
```

### Streaming
Streaming functionality is preserved:

```dart
final stream = agent.runStream('Your prompt');
await for (final chunk in stream) {
  print(chunk.output);
}
```

### Typed Responses
Typed response handling remains unchanged:

```dart
final response = await agent.runFor<MyType>('Prompt');
final typedOutput = response.output; // MyType instance
```

### Embeddings
Embedding generation API is preserved:

```dart
final embedding = await agent.createEmbedding('text');
final similarity = Agent.cosineSimilarity(embedding1, embedding2);
final matches = Agent.findTopMatches(
  embeddingMap: embeddings,
  queryEmbedding: query,
);
```

## Environment Configuration

### API Keys
The library supports both original and Langchain providers with the same environment variables:

```dart
// Set via environment variables
Agent.environment['OPENAI_API_KEY'] = 'your-openai-key';
Agent.environment['GOOGLE_API_KEY'] = 'your-google-key';
Agent.environment['GEMINI_API_KEY'] = 'your-gemini-key';

// Or pass directly
final agent = Agent('openai:gpt-4o', apiKey: 'your-key');
```

### Provider Selection
Choose between original and Langchain-enhanced providers:

```dart
// Original providers
final openaiOriginal = Agent('openai:gpt-4o');
final googleOriginal = Agent('google:gemini-2.0-flash');

// Langchain-enhanced providers
final openaiLangchain = Agent('langchain-openai:gpt-4o');
final googleLangchain = Agent('langchain-google:gemini-2.0-flash');
```

## Provider Capabilities

### All Providers Support
- **Chat**: Conversational interactions
- **Embeddings**: Vector generation for semantic search
- **Tool Calling**: Function execution with structured inputs
- **JSON Output**: Structured response generation
- **Streaming**: Real-time response streaming
- **Multi-Modal**: Support for text, images, and other media types

### Capability Checking
```dart
final agent = Agent('langchain-openai:gpt-4o');
print('Chat support: ${agent.caps.contains(ProviderCaps.chat)}');
print('Tool calling: ${agent.caps.contains(ProviderCaps.toolCalling)}');
print('Embeddings: ${agent.caps.contains(ProviderCaps.embeddings)}');
```

## Error Handling and Fallback

### Graceful Degradation
The library handles errors gracefully:

```dart
// If Langchain initialization fails, falls back to original implementation
final agent = Agent('langchain-openai:gpt-4o'); // May use original OpenAI

// Explicit error handling
try {
  final response = await agent.run('Your prompt');
} catch (e) {
  print('Error: $e');
  // Handle error appropriately
}
```

### Missing Dependencies
If Langchain dependencies are not available, the library automatically falls back to original providers without breaking functionality.

## Migration Guide

### For Existing Users
**No migration required!** All existing code continues to work without changes.

### To Use Enhanced Features
Simply change provider names to access Langchain enhancements:

```dart
// Before
final agent = Agent('openai:gpt-4o');

// After (optional upgrade)
final agent = Agent('langchain-openai:gpt-4o');
```

### Best Practices
1. **Test Both Providers**: Compare original and Langchain providers for your use case
2. **Monitor Performance**: Langchain may have different performance characteristics
3. **Handle Errors**: Implement proper error handling for network issues
4. **API Key Management**: Use secure methods to manage API keys

## Examples

### Basic Chat with Enhanced Provider
```dart
import 'package:dartantic_ai/dartantic_ai.dart';

void main() async {
  final agent = Agent(
    'langchain-openai:gpt-4o-mini',
    systemPrompt: 'You are a helpful assistant.',
  );

  final response = await agent.run('Explain quantum computing');
  print(response.output);
}
```

### Tool Calling with Langchain
```dart
import 'package:dartantic_ai/dartantic_ai.dart';
import 'package:json_schema/json_schema.dart';

void main() async {
  final calculator = Tool(
    name: 'calculator',
    description: 'Performs arithmetic operations',
    inputSchema: JsonSchema.create({
      'type': 'object',
      'properties': {
        'operation': {'type': 'string'},
        'a': {'type': 'number'},
        'b': {'type': 'number'},
      },
      'required': ['operation', 'a', 'b']
    }),
    onCall: (input) async {
      final op = input['operation'] as String;
      final a = (input['a'] as num).toDouble();
      final b = (input['b'] as num).toDouble();
      
      switch (op) {
        case 'add': return {'result': a + b};
        case 'multiply': return {'result': a * b};
        default: return {'error': 'Unknown operation'};
      }
    },
  );

  final agent = Agent(
    'langchain-openai:gpt-4o-mini',
    tools: [calculator],
    systemPrompt: 'Use the calculator tool for math operations.',
  );

  final response = await agent.run('What is 15 * 7?');
  print(response.output);
}
```

### Cross-Provider Usage
```dart
import 'package:dartantic_ai/dartantic_ai.dart';

void main() async {
  // Use different providers for different tasks
  final openaiAgent = Agent('langchain-openai:gpt-4o-mini');
  final googleAgent = Agent('langchain-google:gemini-1.5-flash');

  // OpenAI for creative writing
  final story = await openaiAgent.run('Write a short story about AI');
  
  // Google for factual questions
  final facts = await googleAgent.run('What are the benefits of renewable energy?');
  
  print('Story: ${story.output}');
  print('Facts: ${facts.output}');
}
```

## Troubleshooting

### Common Issues

#### 1. API Key Not Found
```
Error: OpenAI API key is required. Set the OPENAI_API_KEY environment variable or provide it explicitly.
```
**Solution**: Set the appropriate API key in `Agent.environment` or pass it directly to the Agent constructor.

#### 2. Network Connectivity
**Symptoms**: Timeouts or connection errors
**Solution**: Implement retry logic and proper timeout handling in your application.

#### 3. Model Not Available
**Symptoms**: Model not found errors
**Solution**: Check the model name and ensure it's supported by the provider.

### Performance Optimization

#### 1. Provider Selection
- Use Langchain providers for advanced features
- Use original providers for simple use cases or better performance

#### 2. Concurrent Requests
```dart
// Handle multiple requests efficiently
final futures = prompts.map((prompt) => agent.run(prompt));
final responses = await Future.wait(futures);
```

#### 3. Streaming for Long Responses
```dart
// Use streaming for better user experience
final stream = agent.runStream(longPrompt);
await for (final chunk in stream) {
  // Process chunk immediately
  updateUI(chunk.output);
}
```

## Future Enhancements

### Planned Features
1. **Advanced Agent Executors**: Full Langchain agent workflow support
2. **Memory Management**: Conversation memory and context handling
3. **Custom Chains**: Support for complex multi-step operations
4. **Vector Stores**: Integration with vector databases
5. **Document Processing**: Enhanced document parsing and analysis

### Feedback and Contributions
We welcome feedback and contributions to improve the Langchain integration. Please:
1. Report issues on GitHub
2. Suggest new features via discussions
3. Contribute code through pull requests
4. Share usage examples and best practices

## Conclusion

The Langchain integration provides powerful enhancements while maintaining full backward compatibility. Whether you're an existing user or new to dartantic_ai, you can take advantage of these features without changing your existing code.

For questions, issues, or contributions, please visit our [GitHub repository](https://github.com/csells/dartantic_ai).
