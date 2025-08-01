The dartantic_ai package implements a comprehensive structured logging
system using Dart's `logging` package. All logging follows a hierarchical naming
convention prefixed with `dartantic` to provide clear operational visibility and
debugging capabilities.

**Recommended Usage**: The package provides a simple `LoggingOptions` API
accessible via `Agent.loggingOptions` for easy configuration without needing to
understand Dart's logging internals.

## Logging Philosophy

### Design Principles

1. **Hierarchical Organization**: Logger names follow a domain-based hierarchy
   for easy filtering
2. **Operational Visibility**: Log important operations that affect user
   experience
3. **Debug Granularity**: Provide detailed information for troubleshooting
4. **Performance Awareness**: Log timing and resource usage for monitoring
5. **Error Context**: Include sufficient context for error diagnosis

### Logging Levels

- **`info`**: Important operations (agent creation, model instantiation, tool
  execution)
- **`fine`**: Detailed debug information (chunk processing, message conversion)
- **`warning`**: Errors, failures, and unexpected conditions
- **`severe`**: Critical failures that prevent operation

## Hierarchical Naming Convention

All loggers follow the pattern: `dartantic.{domain}.{subdomain}.{component}`

### Logger Hierarchy

```
dartantic
├── agent                           # Core agent operations
│   └── message                     # Agent message operations
├── orchestrator                    # Orchestration layer components
│   ├── default                     # DefaultStreamingOrchestrator
│   ├── typed-output                # TypedOutputStreamingOrchestrator
│   └── custom                      # Future custom orchestrators
├── executor                        # Tool execution components
│   ├── tool                        # ToolExecutor
│   └── parallel                    # Future ParallelToolExecutor
├── state                           # State management
│   └── streaming                   # StreamingState
├── providers                       # Unified provider implementations
│   ├── openai                      # OpenAI provider
│   ├── anthropic                   # Anthropic provider
│   ├── google                      # Google provider
│   ├── mistral                     # Mistral provider
│   ├── ollama                      # Ollama provider
│   └── cohere                      # Cohere provider
├── chat                            # Chat-related functionality
│   ├── models                      # Chat model implementations
│   │   ├── openai                  # OpenAI model
│   │   ├── anthropic               # Anthropic model
│   │   ├── google                  # Google model
│   │   ├── mistral                 # Mistral model
│   │   ├── ollama                  # Ollama model
│   │   └── cohere                  # Cohere model
│   └── mappers                     # Message format conversion
│       ├── openai                  # OpenAI message mappers
│       ├── anthropic               # Anthropic message mappers
│       ├── google                  # Google message mappers
│       ├── mistral                 # Mistral message mappers
│       ├── ollama                  # Ollama message mappers
│       └── cohere                  # Cohere message mappers
├── embeddings                      # Embeddings-related functionality
│   └── models                      # Embeddings model implementations
│       ├── openai                  # OpenAI embeddings
│       ├── google                  # Google embeddings
│       ├── mistral                 # Mistral embeddings
│       └── cohere                  # Cohere embeddings
├── tools                           # Tool execution and management
├── http                            # HTTP operations
│   └── retry                       # HTTP retry logic
└── language_models                 # Base language model functionality
```

### Logger Hierarchy Diagram

```mermaid
graph TD
    subgraph "dartantic"
        A[dartantic] --> B[agent]
        A --> C[orchestrator]
        A --> D[executor]
        A --> E[state]
        A --> F[providers]
        A --> G[chat]
        A --> H[embeddings]
        A --> I[tools]
        A --> J[http]
        A --> K[language_models]
        
        B --> B1[message]
        
        C --> C1[default]
        C --> C2[typed-output]
        C --> C3[custom]
        
        D --> D1[tool]
        D --> D2[parallel]
        
        E --> E1[streaming]
        
        F --> F1[openai]
        F --> F2[anthropic]
        F --> F3[google]
        F --> F4[mistral]
        F --> F5[ollama]
        F --> F6[cohere]
        
        G --> G1[models]
        G --> G2[mappers]
        
        G1 --> GM1[openai]
        G1 --> GM2[anthropic]
        G1 --> GM3[google]
        G1 --> GM4[mistral]
        G1 --> GM5[ollama]
        G1 --> GM6[cohere]
        
        G2 --> GMP1[openai]
        G2 --> GMP2[anthropic]
        G2 --> GMP3[google]
        G2 --> GMP4[mistral]
        G2 --> GMP5[ollama]
        G2 --> GMP6[cohere]
        
        H --> H1[models]
        
        H1 --> HM1[openai]
        H1 --> HM2[google]
        H1 --> HM3[mistral]
        H1 --> HM4[cohere]
        
        J --> J1[retry]
    end
    
    style A fill:#f9f,stroke:#333,stroke-width:2px
    style B fill:#bbf,stroke:#333,stroke-width:2px
    style C fill:#bfb,stroke:#333,stroke-width:2px
    style F fill:#fbf,stroke:#333,stroke-width:2px
```

## Logging Flow Diagram

```mermaid
flowchart TD
    A[User Code] --> B{Configure<br/>Logging?}
    
    B -->|Yes| C[Agent.loggingOptions]
    B -->|No| D[Default Settings<br/>Level.INFO, no filter]
    
    C --> E[LoggingOptions]
    D --> E
    
    E --> F[Configure Logger.root]
    
    F --> G[Set Level]
    F --> H[Add Listener]
    F --> I[Configure Filter]
    
    G --> J[Logger Instance]
    H --> J
    I --> J
    
    J --> K{Log Event}
    
    K -->|Meets Level| L{Matches Filter?}
    K -->|Below Level| M[Discard]
    
    L -->|Yes| N[Execute Handler]
    L -->|No| M
    
    N --> O[Output]
    
    style A fill:#f9f,stroke:#333,stroke-width:2px
    style E fill:#bbf,stroke:#333,stroke-width:2px
    style N fill:#bfb,stroke:#333,stroke-width:2px
    style M fill:#fbb,stroke:#333,stroke-width:2px
```

## LoggingOptions API

### Overview

The `LoggingOptions` class provides a simple, user-friendly way to configure
logging for all dartantic operations through the `Agent.loggingOptions`
property. This is the recommended approach for most users.

### Configuration Fields

- **`Level level`**: Minimum logging level (default: `Level.INFO`)
- **`String filter`**: Substring filter for logger names (default: `''` -
  matches all)
- **`void Function(LogRecord) onRecord`**: Custom log handler (default:
  formatted console output)

### Usage Patterns

```dart
// Simple level control
Agent.loggingOptions = LoggingOptions(level: Level.FINE);

// Provider filtering
Agent.loggingOptions = LoggingOptions(filter: 'openai');
Agent.loggingOptions = LoggingOptions(filter: 'anthropic');
Agent.loggingOptions = LoggingOptions(filter: 'chat');

// Orchestration layer filtering
Agent.loggingOptions = LoggingOptions(filter: 'orchestrator');
Agent.loggingOptions = LoggingOptions(filter: 'orchestrator.default');
Agent.loggingOptions = LoggingOptions(filter: 'executor.tool');

// Infrastructure layer filtering
Agent.loggingOptions = LoggingOptions(filter: 'state.streaming');

// Combine level and filtering
Agent.loggingOptions = LoggingOptions(
  level: Level.FINE,
  filter: 'http.retry',
);

// Custom handler integration
Agent.loggingOptions = LoggingOptions(
  onRecord: (record) => myCustomLogger.log(record.message),
);

// Production configuration
Agent.loggingOptions = LoggingOptions(
  level: Level.WARNING,
  filter: '',
  onRecord: (record) => productionLogger.error(record),
);
```

### Benefits of LoggingOptions

- **Simple API**: No need to understand Dart's logging internals
- **Automatic Setup**: Configures Logger.root automatically
- **Efficient Filtering**: Uses optimized substring matching
- **Subscription Management**: Handles listener lifecycle automatically
- **Non-nullable**: All fields have sensible defaults

## Implementation Details

### Logger Declaration Pattern

Each file declares a static logger following this pattern:

```dart
import 'package:logging/logging.dart';

class SomeClass {
  /// Logger for [domain].[subdomain].[component] operations.
  static final Logger _logger = Logger('dartantic.domain.subdomain.component');
}
```

### Common Logging Patterns

#### Agent Operations

```dart
// Agent creation
_logger.info('Creating agent with model: $model (provider: $providerName, chat model: $chatModelName, embeddings model: $embeddingsModelName)');

// Orchestrator selection
_logger.fine('Selected orchestrator: ${orchestrator.providerHint} for ${outputSchema != null ? 'typed' : 'standard'} output');

// State initialization
_logger.fine('Initializing streaming state with ${tools?.length ?? 0} tools');

// Embeddings operations
_logger.info('Executing embedQuery for ${query.length} character query');
_logger.info('Executing embedDocuments for ${texts.length} documents');
```

#### Orchestrator Operations

```dart
// Initialization
_logger.fine('Initializing ${providerHint} orchestrator');

// Streaming coordination
_logger.fine('Starting model stream processing');
_logger.fine('Stream closed. Consolidated message has ${consolidatedMessage.parts.length} parts');

// Tool detection
_logger.info('Found ${toolCalls.length} tool calls to execute: ${toolCalls.map((t) => t.name).join(', ')}');

// Workflow completion
_logger.fine('Finalizing ${providerHint} orchestrator');
```

#### Tool Execution Operations

```dart
// Batch execution start
_logger.info('Executing batch of ${toolCalls.length} tools: ${toolCalls.map((t) => t.name).join(', ')}');

// Individual tool execution
_logger.fine('Executing tool: ${toolCall.name} with args: ${json.encode(toolCall.arguments ?? {})}');
_logger.info('Tool ${toolCall.name} executed successfully, result length: ${result.length}');
_logger.warning('Tool ${toolCall.name} execution failed: $error');
```

#### Model Creation and Disposal (Direct)

```dart
// Model creation now handled directly by providers
final chatModel = provider.createChatModel(name: 'gpt-4o');
final embeddingsModel = provider.createEmbeddingsModel(name: 'text-embedding-3-small');

// Resource cleanup in orchestration layer
try {
  // ... streaming operations
} finally {
  chatModel.dispose();
  embeddingsModel.dispose();
}
```

#### State Management Operations

```dart
// State transitions
_logger.fine('Resetting streaming state for new message');
_logger.fine('Accumulating message chunk: ${chunk.parts.length} parts');
_logger.fine('Consolidating accumulated message: ${accumulated.parts.length} parts');

// UX state tracking
_logger.fine('Setting newline prefix flag for next AI message');
_logger.fine('Clearing message chunk tracking state');
```

#### Model Operations

```dart
// Model creation
_logger.info('Creating OpenAI model: $modelName with ${tools?.length ?? 0} tools, temp: $temperature');

// Streaming operations
_logger.info('Starting OpenAI chat stream with ${messages.length} messages for model: $name');
_logger.fine('Received OpenAI stream chunk $chunkCount');
_logger.info('OpenAI chat stream completed after $chunkCount chunks');
```

#### HTTP Operations

```dart
// API calls
_logger.info('Fetching models from OpenAI API: $defaultBaseUrl/models');
_logger.warning('Failed to fetch models: HTTP ${response.statusCode}, body: ${response.body}');
_logger.info('Successfully fetched $modelCount models from OpenAI API');

// Retry logic
_logger.info('Rate limited (429), retrying attempt ${attempt + 1}/$maxRetries after ${delay.inMilliseconds}ms');
_logger.warning('Rate limit retry exhausted after $maxRetries attempts');
```

## Current Implementation Status

### ✅ Fully Implemented

- **LoggingOptions API** (NEW!)
  - Simple configuration via `Agent.loggingOptions`
  - Level, filtering, and custom handler support
  - Automatic subscription management
  - Non-nullable defaults for ease of use

- **Agent Operations** (`dartantic.agent`, `dartantic.agent.message`)
  - Agent creation and lifecycle
  - Tool execution and results  
  - Streaming operations
  - Error handling
  - LoggingOptions integration

- **Chat Providers** (`dartantic.chat.providers.*`)
  - OpenAI provider (`dartantic.chat.providers.openai`)
  - Anthropic provider (`dartantic.chat.providers.anthropic`)
  - Google provider (`dartantic.chat.providers.google`)
  - Mistral provider (`dartantic.chat.providers.mistral`)
  - Ollama provider (`dartantic.chat.providers.ollama`)
  - Cohere provider (`dartantic.chat.providers.cohere`)
  - Model creation and configuration
  - API calls and error handling
  - Model fetching operations

- **Chat Models** (`dartantic.chat.models.*`)
  - OpenAI model (`dartantic.chat.models.openai`)
  - Anthropic model (`dartantic.chat.models.anthropic`)
  - Google model (`dartantic.chat.models.google`)
  - Mistral model (`dartantic.chat.models.mistral`)
  - Ollama model (`dartantic.chat.models.ollama`)
  - Cohere model (inherits OpenAI logging)
  - Streaming operations
  - Chunk processing
  - Error handling

- **Message Mappers** (`dartantic.chat.mappers.*`)
  - OpenAI mappers (`dartantic.chat.mappers.openai`)
  - Anthropic mappers (`dartantic.chat.mappers.anthropic`)
  - Google mappers (`dartantic.chat.mappers.google`)
  - Mistral mappers (`dartantic.chat.mappers.mistral`)
  - Ollama mappers (`dartantic.chat.mappers.ollama`)
  - Message format conversion
  - Tool processing
  - Stream event handling

- **Embeddings** (`dartantic.embeddings.*`)
  - All embedding providers (`dartantic.embeddings.providers.*`)
    - OpenAI, Google, Mistral, Cohere providers
    - Model creation and configuration
    - Model fetching operations
  - All embedding models (`dartantic.embeddings.models.*`)
    - OpenAI, Google, Mistral, Cohere models
    - Query operations (individual and batch)
    - API request/response logging
    - Token usage and performance metrics

- **Tools** (`dartantic.tools`)
  - Tool registration and validation
  - Schema processing and parameter validation
  - Tool invocation and execution
  - Error handling and logging

- **HTTP Operations** (`dartantic.http.retry`)
  - Retry logic with exponential backoff
  - Rate limit handling
  - Request recreation

- **Language Models Base** (`dartantic.language_models`)
  - Base data structures (usage tracking, finish reasons)
  - No operational logging needed (data classes only)

## Usage Examples

### Quick Start with LoggingOptions (Recommended)

```dart
import 'package:dartantic_ai/dartantic_ai.dart';

void main() async {
  // Simple setup - just enable logging with defaults
  Agent.loggingOptions = LoggingOptions();

  // Create agent - will generate logs
  final agent = Agent('openai:gpt-4o');
  
  // Run conversation - will generate detailed logs
  final result = await agent.send('Hello!');
  
  // Embeddings operations also generate logs
  final embedding = await agent.embedQuery('search text');
}
```

### Advanced LoggingOptions Configuration

```dart
import 'package:logging/logging.dart';
import 'package:dartantic_ai/dartantic_ai.dart';

void main() async {
  // Filter to only see OpenAI-related logs
  Agent.loggingOptions = LoggingOptions(
    filter: 'openai',
    level: Level.FINE,
  );

  // Or integrate with your existing logging system
  Agent.loggingOptions = LoggingOptions(
    level: Level.INFO,
    onRecord: (record) {
      myAppLogger.log(
        level: record.level.name,
        message: record.message,
        component: record.loggerName,
      );
    },
  );

  final agent = Agent('openai:gpt-4o');
}
```

### Manual Logging Setup (Advanced Users)

```dart
import 'package:logging/logging.dart';
import 'package:dartantic_ai/dartantic_ai.dart';

void main() async {
  // Manual setup for full control
  Logger.root.level = Level.ALL;
  
  Logger.root.onRecord.listen((record) {
    print('[${record.loggerName}] ${record.level}: ${record.message}');
  });

  final agent = Agent('openai:gpt-4o');
}
```

### Common LoggingOptions Patterns

```dart
// Basic filtering examples
Agent.loggingOptions = LoggingOptions(filter: 'openai');     // Only OpenAI
Agent.loggingOptions = LoggingOptions(filter: 'anthropic');  // Only Anthropic  
Agent.loggingOptions = LoggingOptions(filter: 'chat');       // All chat operations
Agent.loggingOptions = LoggingOptions(filter: 'embeddings'); // All embeddings operations
Agent.loggingOptions = LoggingOptions(filter: 'providers');  // All provider operations
Agent.loggingOptions = LoggingOptions(filter: 'http');       // HTTP operations
Agent.loggingOptions = LoggingOptions(filter: 'agent');      // Agent operations

// Level examples
Agent.loggingOptions = LoggingOptions(level: Level.FINE);    // Detailed debug
Agent.loggingOptions = LoggingOptions(level: Level.WARNING); // Errors only

// Combined filtering
Agent.loggingOptions = LoggingOptions(
  level: Level.FINE,
  filter: 'openai',
);
```

### Advanced Manual Configuration

```dart
// Direct logger control (for advanced users)
Logger('dartantic.agent').level = Level.INFO;
Logger('dartantic.http.retry').level = Level.INFO;  
Logger('dartantic.providers.openai').level = Level.FINE;
Logger('dartantic.chat.models.openai').level = Level.FINE;
Logger('dartantic.embeddings.models.openai').level = Level.FINE;
```

### Production Logging

```dart
// Production setup with LoggingOptions
Agent.loggingOptions = LoggingOptions(
  level: Level.WARNING, // Only errors and warnings
  onRecord: (record) {
    // Send to error monitoring
    if (record.level >= Level.SEVERE) {
      errorMonitoring.captureException(record.message);
    }
    
    // Send to application logs
    structuredLogger.log({
      'level': record.level.name,
      'logger': record.loggerName,
      'message': record.message,
      'timestamp': record.time.toIso8601String(),
    });
  },
);

// Or manual production setup
Logger.root.level = Level.INFO;
Logger.root.onRecord.listen((record) {
  if (record.level >= Level.WARNING) {
    errorMonitoring.captureException(record.message);
  }
  
  structuredLogger.log({
    'level': record.level.name,
    'logger': record.loggerName,
    'message': record.message,
    'timestamp': record.time.toIso8601String(),
  });
});
```

## Benefits

### Operational Visibility

- **Request Flow**: Track requests from agent creation through model execution
- **Performance Monitoring**: Identify slow operations and bottlenecks
- **Usage Patterns**: Monitor which models and tools are used most frequently
- **Error Rates**: Track failure rates by provider and operation type

### Debugging Capabilities

- **Message Tracing**: Follow messages through conversion and processing
- **Tool Execution**: Debug tool calls, arguments, and results
- **Streaming Analysis**: Monitor streaming chunk processing and accumulation
- **Provider Issues**: Isolate problems to specific providers or models

### Monitoring Integration

- **Hierarchical Filtering**: Enable/disable logging by domain or component
- **Structured Data**: Easy integration with log aggregation systems
- **Performance Metrics**: Extract timing and usage data for dashboards
- **Alerting**: Set up alerts based on error rates or performance thresholds

## Best Practices

### For Contributors

1. **Follow Naming Convention**: Always use the hierarchical `dartantic.*`
   pattern
2. **Log Key Operations**: Agent creation, model calls, tool execution, HTTP
   requests
3. **Include Context**: Provider names, model names, message counts, tool names
4. **Use Appropriate Levels**: `info` for operations, `fine` for details,
   `warning` for errors
5. **Avoid Sensitive Data**: Never log API keys, user content, or personal
   information

### For Users

#### Recommended Approach: Use LoggingOptions

1. **Start Simple**: `Agent.loggingOptions = LoggingOptions()` for default setup
2. **Filter by Provider**: Use `filter: 'openai'` or `filter: 'anthropic'` to
   focus
3. **Adjust Level**: Use `level: Level.FINE` for debugging, `Level.WARNING` for
   production
4. **Custom Integration**: Use `onRecord` callback for your logging system
5. **Iterate**: Start broad, then narrow down with filters as needed

#### Advanced Users: Manual Configuration

1. **Direct Logger Control**: Configure `Logger('dartantic.specific.component')`
2. **Performance Tracking**: Use `FINE` level temporarily for analysis
3. **Production Setup**: Implement log rotation and retention policies
4. **Monitoring Integration**: Set up alerts based on error rates

## LoggingOptions Summary

### Quick Reference

```dart
import 'package:dartantic_ai/dartantic_ai.dart';

// Enable default logging
Agent.loggingOptions = LoggingOptions();

// Common patterns
Agent.loggingOptions = LoggingOptions(filter: 'openai');              // OpenAI only
Agent.loggingOptions = LoggingOptions(level: Level.FINE);             // Debug level
Agent.loggingOptions = LoggingOptions(level: Level.WARNING);          // Errors only
Agent.loggingOptions = LoggingOptions(filter: 'chat', level: Level.FINE); // Chat debug

// Production integration
Agent.loggingOptions = LoggingOptions(
  level: Level.INFO,
  onRecord: (record) => myProductionLogger.log(record),
);
```

### Key Features

- ✅ **Simple API**: Single property assignment configures everything
- ✅ **Substring Filtering**: Easy provider/component filtering
- ✅ **Non-nullable Defaults**: Works out of the box
- ✅ **Custom Handlers**: Integrate with any logging system
- ✅ **Automatic Management**: Handles subscription lifecycle
- ✅ **Performance Optimized**: Efficient filtering and level checking

## Future Enhancements

- **Structured Logging**: Add support for structured log data (JSON format)
- **Performance Metrics**: Built-in timing and performance measurement
- **Sampling**: Implement log sampling for high-volume production environments
- **Integration Helpers**: Pre-built integrations with popular monitoring
  services
- **Log Correlation**: Add request/conversation IDs for tracing across
  operations
- **Multi-Filter Support**: Allow multiple filter patterns (e.g., `['openai',
  'anthropic']`)
- **Async Handlers**: Support for async onRecord callbacks
