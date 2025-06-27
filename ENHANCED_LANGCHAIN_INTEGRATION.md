# Enhanced Langchain Integration for System Prompts and Tool Calling

## Overview

This document describes the enhanced Langchain integration in Dartantic AI that incorporates Langchain's capabilities for handling system prompts and tool executions. The integration preserves the original `_ensureSystemPromptMessage` logic while leveraging Langchain's prompt chaining mechanisms and agent executor for improved tool calling.

## Key Features

### 1. Enhanced System Prompt Handling

The integration provides superior system prompt handling through:

- **Langchain Prompt Templates**: Uses `ChatPromptTemplate` for consistent system prompt injection
- **Preserved Logic**: Maintains the original `_ensureSystemPromptMessage` functionality as a fallback
- **Dual Approach**: Langchain wrapper handles system prompts internally, while direct models use the original logic

#### Implementation Details

```dart
/// Initialize prompt template with system prompt handling
void _initializePromptTemplate() {
  if (_systemPrompt != null && _systemPrompt!.isNotEmpty) {
    // Create a prompt template that ensures system prompt is always included
    _promptTemplate = ChatPromptTemplate.fromMessages([
      SystemChatMessagePromptTemplate.fromTemplate(_systemPrompt!),
      MessagesPlaceholder(variableName: 'messages'),
    ]);
  } else {
    // Simple template without system prompt
    _promptTemplate = ChatPromptTemplate.fromMessages([
      MessagesPlaceholder(variableName: 'messages'),
    ]);
  }
}
```

### 2. Advanced Tool Calling with Agent Executor

The integration leverages Langchain's agent executor for sophisticated tool calling:

- **Agent-Based Execution**: Uses `createToolCallingAgent` for enhanced tool management
- **Tool Conversion**: Automatically converts Dartantic tools to Langchain tools
- **Fallback Support**: Falls back to direct LLM execution when tools are unavailable

#### Tool Conversion Process

```dart
/// Convert dartantic Tool to Langchain Tool
Tool _convertToLangchainTool(dartantic_tool.Tool darTool) {
  return Tool.fromFunction(
    name: darTool.name,
    description: darTool.description ?? 'A tool function',
    inputJsonSchema: darTool.inputSchema?.toJson() as Map<String, dynamic>? ?? {},
    func: (input) async {
      try {
        final result = await darTool.onCall(input as Map<String, dynamic>);
        return result.toString();
      } on Exception catch (e) {
        log.severe('[LangchainWrapper] Tool execution error: $e');
        return 'Error executing tool: $e';
      }
    },
  );
}
```

### 3. Intelligent Execution Routing

The enhanced wrapper intelligently routes execution based on available capabilities:

```dart
Stream<AgentResponse> runStream({
  required String prompt,
  required Iterable<Message> messages,
  required Iterable<Part> attachments,
}) async* {
  try {
    // Ensure system prompt is properly handled
    final messagesWithSystem = _ensureSystemPromptMessage(messages);
    
    // Route based on available tools and agent executor
    if (_langchainTools != null && _langchainTools!.isNotEmpty && _agentExecutor != null) {
      yield* _streamAgentResponse(messagesWithSystem, prompt, attachments);
    } else {
      yield* _streamLLMResponseWithTemplate(messagesWithSystem, prompt, attachments);
    }
  } on Exception catch (e) {
    // Error handling...
  }
}
```

## Architecture Components

### 1. LangchainWrapper Class

The core wrapper class that provides enhanced functionality:

- **Provider Abstraction**: Supports OpenAI and Google/Gemini providers
- **Prompt Template Management**: Handles system prompt injection via templates
- **Agent Executor**: Manages tool calling through Langchain agents
- **Fallback Logic**: Preserves original `_ensureSystemPromptMessage` behavior

### 2. Agent Class Enhancements

The Agent class has been enhanced to:

- **Automatic Wrapper Detection**: Uses Langchain wrapper when available
- **Conditional System Prompt Handling**: Delegates to wrapper or uses original logic
- **Environment-Based Initialization**: Automatically configures API keys from environment

### 3. Execution Paths

The integration provides multiple execution paths:

1. **Agent-Based (with tools)**: Uses Langchain's AgentExecutor for tool calling
2. **Template-Based (no tools)**: Uses ChatPromptTemplate for enhanced prompting
3. **Fallback (original)**: Uses direct model execution with original logic

## Benefits

### 1. **Enhanced Reliability**
- Leverages Langchain's battle-tested implementations
- Better error handling and retry logic
- More robust tool calling mechanisms

### 2. **Improved System Prompt Handling**
- Consistent system prompt injection across providers
- Template-based approach for better prompt engineering
- Fallback to original logic ensures compatibility

### 3. **Advanced Tool Capabilities**
- Access to Langchain's extensive tool ecosystem
- Agent-based tool execution with better context management
- Support for complex multi-tool interactions

### 4. **Future Extensibility**
- Easy integration with Langchain's LCEL (LangChain Expression Language)
- Potential for memory systems and retrieval augmented generation
- Community-driven improvements and features

## Usage Examples

### Basic System Prompt Usage

```dart
final agent = Agent(
  'openai:gpt-4o',
  apiKey: 'your-api-key',
  systemPrompt: 'You are a helpful assistant that responds concisely.',
);

final response = await agent.run('What is the capital of France?');
// System prompt is automatically handled via Langchain templates
```

### Tool Calling with Enhanced Integration

```dart
final calculatorTool = Tool(
  name: 'calculator',
  description: 'Performs mathematical calculations',
  inputSchema: JsonSchema.create({...}),
  onCall: (input) async {
    // Tool implementation
    return {'result': calculation};
  },
);

final agent = Agent(
  'openai:gpt-4o',
  apiKey: 'your-api-key',
  systemPrompt: 'You have access to a calculator tool.',
  tools: [calculatorTool],
);

final response = await agent.run('What is 15 + 27?');
// Uses Langchain's agent executor for sophisticated tool calling
```

## Configuration

### Environment Variables

The enhanced integration supports automatic API key configuration:

```dart
// Set environment variables for automatic detection
Agent.environment['OPENAI_API_KEY'] = 'your-openai-key';
Agent.environment['GOOGLE_API_KEY'] = 'your-google-key';

// Agent will automatically use Langchain wrapper when keys are available
final agent = Agent('openai:gpt-4o', systemPrompt: 'Be helpful');
```

### Manual Configuration

```dart
final agent = Agent(
  'openai:gpt-4o',
  apiKey: 'explicit-api-key',
  systemPrompt: 'Custom system prompt',
  tools: [tool1, tool2],
  temperature: 0.7,
);
```

## Testing

A comprehensive test suite verifies the enhanced functionality:

```bash
dart run test_enhanced_langchain_integration.dart
```

The test suite covers:
- System prompt handling with streaming and non-streaming execution
- Tool calling with single and multiple tools
- Complex multi-tool interactions
- Error handling and fallback scenarios

## Migration

### Existing Code Compatibility

**No changes required** - the enhanced integration is fully backward compatible:

```dart
// This code works identically before and after enhancement
final agent = Agent('openai:gpt-4o', apiKey: 'sk-...');
final response = await agent.run('Hello, world!');
```

### Opting Into Enhanced Features

Enhanced features are automatically enabled when:
1. Valid API keys are available in the environment
2. Langchain dependencies are properly installed
3. The provider supports Langchain integration (OpenAI, Google)

## Error Handling

The integration includes comprehensive error handling:

- **Graceful Fallback**: Falls back to original implementation if Langchain fails
- **Detailed Logging**: Provides detailed error information for debugging
- **Tool Execution Safety**: Catches and logs tool execution errors

## Future Enhancements

With this enhanced integration, future capabilities become possible:

1. **Memory Systems**: Conversation memory and context management
2. **RAG Integration**: Vector stores and retrievers for knowledge augmentation
3. **Chain Compositions**: Complex multi-step reasoning chains
4. **Additional Providers**: Easy addition of Anthropic, Cohere, etc.
5. **Advanced Prompting**: LCEL-based prompt engineering

## Files Modified

### Enhanced Files
- `lib/src/models/implementations/langchain_wrapper.dart` - Core enhancement with prompt templates and agent executor
- `lib/src/agent/agent.dart` - Enhanced to use Langchain wrapper intelligently

### New Files
- `test_enhanced_langchain_integration.dart` - Comprehensive test suite
- `ENHANCED_LANGCHAIN_INTEGRATION.md` - This documentation

### Dependencies
- All existing Langchain dependencies remain
- No additional dependencies required

This enhanced integration successfully incorporates Langchain's capabilities for system prompts and tool executions while preserving all existing functionality and maintaining full API compatibility.
