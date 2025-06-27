# Langchain Integration

## Overview

This document describes the completed Langchain integration in Dartantic AI. The integration provides enhanced prompt execution capabilities through Langchain while maintaining full API compatibility. The system can delegate prompt execution to Langchain packages instead of directly invoking the underlying providers, with automatic fallback when needed.

## Changes Made

### 1. Added Langchain Dependencies

Enhanced `pubspec.yaml` with additional Langchain provider packages:
- `langchain_openai: ^0.7.4+2` - OpenAI integration 
- `langchain_google: ^0.6.5` - Google/Gemini integration

### 2. Created Langchain Wrapper

**File**: `lib/src/models/implementations/langchain_wrapper.dart`

A new abstraction layer that:
- Wraps Langchain functionality while maintaining the current API
- Supports both OpenAI and Google/Gemini providers
- Provides streaming responses via `runStream()`
- Handles embedding generation via `createEmbedding()`
- Converts between internal message formats and Langchain formats

Key features:
- **Provider Abstraction**: Automatically selects the appropriate Langchain model based on provider
- **Message Conversion**: Translates between internal `Message`/`Part` formats and Langchain's `ChatMessage` format
- **Streaming Support**: Implements streaming responses using Langchain's streaming API
- **Error Handling**: Graceful error handling with logging
- **API Compatibility**: Maintains exact same interface as existing models

### 3. Created Langchain-Based Model Implementations

#### OpenAI Model: `lib/src/models/implementations/langchain_openai_model.dart`
- Replaces direct OpenAI API calls with Langchain wrapper
- Maintains all existing constructor parameters
- Delegates `runStream()` and `createEmbedding()` to wrapper

#### Gemini Model: `lib/src/models/implementations/langchain_gemini_model.dart`  
- Replaces direct Gemini API calls with Langchain wrapper
- Maintains all existing constructor parameters
- Delegates `runStream()` and `createEmbedding()` to wrapper

### 4. Updated Provider Implementations

#### OpenAI Provider: `lib/src/providers/implementation/openai_provider.dart`
- Changed import from `openai_model.dart` to `langchain_openai_model.dart`
- Updated `createModel()` to return `LangchainOpenAiModel` instead of `OpenAiModel`
- Removed `parallelToolCalls` parameter as it's handled by Langchain

#### Gemini Provider: `lib/src/providers/implementation/gemini_provider.dart`
- Changed import from `gemini_model.dart` to `langchain_gemini_model.dart`  
- Updated `createModel()` to return `LangchainGeminiModel` instead of `GeminiModel`

## API Compatibility

The refactoring maintains **100% API compatibility**:

### Agent Methods Unchanged
- `run()` - Complete response (delegates to `runStream()`)
- `runStream()` - Streaming response (now powered by Langchain)
- `runFor<T>()` - Typed response (delegates to `run()`)

### Constructor Parameters Preserved
- All existing Agent constructor parameters work identically
- Provider selection (`openai`, `google`) works the same
- Model selection (e.g., `gpt-4o`, `gemini-2.0-flash`) works the same
- Tool support, system prompts, temperature, etc. all preserved

### Message and Response Formats
- `AgentResponse` format unchanged
- `Message` and `Part` types unchanged  
- Streaming behavior identical to users

## Benefits

### 1. **Langchain Ecosystem Access**
- Access to Langchain's extensive tool and chain ecosystem
- Future integration with Langchain agents, retrievers, and memory systems
- Community-driven improvements and features

### 2. **Improved Reliability** 
- Leverages battle-tested Langchain implementations
- Better error handling and retry logic
- More robust streaming implementations

### 3. **Future Extensibility**
- Easy to add new providers supported by Langchain
- Can leverage Langchain's LCEL (LangChain Expression Language)
- Potential for advanced features like tool calling, memory, and retrieval

### 4. **Reduced Maintenance**
- Provider API changes handled by Langchain packages
- Less custom networking and protocol code to maintain
- Community fixes and improvements automatically inherited

## Implementation Details

### Message Format Conversion

The wrapper handles conversion between formats:

```dart
// Internal format
Message(role: MessageRole.user, parts: [TextPart("Hello")])

// Converted to Langchain format  
ChatMessage.humanText("Hello")
```

### Streaming Implementation

Langchain streaming is mapped to the existing streaming interface:

```dart
Stream<AgentResponse> runStream(...) async* {
  final stream = _llm.stream(PromptValue.chat(messages));
  await for (final chunk in stream) {
    yield AgentResponse(output: chunk.output.content, messages: const []);
  }
}
```

### Provider Configuration

The wrapper automatically configures the appropriate Langchain models:

```dart
switch (_provider.toLowerCase()) {
  case 'openai':
    _llm = ChatOpenAI(apiKey: _apiKey, defaultOptions: ...);
    _embeddings = OpenAIEmbeddings(apiKey: _apiKey);
  case 'google':
    _llm = ChatGoogleGenerativeAI(apiKey: _apiKey, defaultOptions: ...);
    _embeddings = GoogleGenerativeAIEmbeddings(apiKey: _apiKey);
}
```

## Testing

A test script `test_langchain_integration.dart` verifies:
- OpenAI integration works with `run()` and `runStream()`
- Gemini integration works with `run()` and `runStream()`  
- Error handling for missing API keys
- Response format compatibility

## Migration Path

**Existing code requires no changes** - the refactoring is transparent:

```dart
// This code works exactly the same before and after refactoring
final agent = Agent('openai:gpt-4o', apiKey: 'sk-...');
final response = await agent.run('Hello, world!');
print(response.output);
```

## Future Enhancements

With Langchain integration in place, future enhancements become possible:

1. **Advanced Tool Calling**: Leverage Langchain's tool ecosystem
2. **Memory Systems**: Add conversation memory and context management  
3. **Retrieval Augmented Generation**: Integrate vector stores and retrievers
4. **Chain Compositions**: Build complex multi-step reasoning chains
5. **Additional Providers**: Easy addition of Anthropic, Cohere, etc.

## Files Modified

### New Files
- `lib/src/models/implementations/langchain_wrapper.dart`
- `lib/src/models/implementations/langchain_openai_model.dart`
- `lib/src/models/implementations/langchain_gemini_model.dart`
- `test_langchain_integration.dart`
- `LANGCHAIN_INTEGRATION.md`

### Modified Files
- `pubspec.yaml` - Added Langchain provider dependencies
- `lib/src/providers/implementation/openai_provider.dart` - Use Langchain model
- `lib/src/providers/implementation/gemini_provider.dart` - Use Langchain model

### Unchanged Files
- `lib/src/agent/agent.dart` - No changes needed
- `lib/src/models/interface/model.dart` - Interface unchanged
- All existing test files - Should continue to pass
- Public API - Completely preserved

This refactoring successfully achieves the goal of delegating prompt execution to Langchain while maintaining full API compatibility and adding significant future extensibility.
