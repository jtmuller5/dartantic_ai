# LangChain.dart Integration Setup

## Package Installation

The `langchain` package (version 0.7.8) has been successfully added to `pubspec.yaml` and installed.

### Dependencies Added
```yaml
dependencies:
  langchain: ^0.7.8
```

### Installed Packages
- `langchain: 0.7.8` - Main LangChain.dart package
- `langchain_core: 0.3.7` - Core abstractions and LCEL (automatically included)

## Available Components

### 1. Model I/O Components

#### Prompt Templates
- **PromptTemplate**: Create dynamic prompts with input variables
- **ChatPromptTemplate**: For chat-based interactions
- **MessagesPlaceholder**: For message history in chat templates

#### Output Parsers
- **StringOutputParser**: Parse LLM output as strings
- **JsonOutputParser**: Parse structured JSON responses
- **ListOutputParser**: Parse lists from LLM output

### 2. Document Processing

#### Document Handling
- **Document**: Represents a piece of content with metadata
- **TextLoader**: Load text from various sources
- **CSVLoader**: Load data from CSV files
- **JSONLoader**: Load structured JSON data

#### Text Splitting
- **RecursiveCharacterTextSplitter**: Intelligent text chunking
- **CharacterTextSplitter**: Simple character-based splitting
- **TokenTextSplitter**: Token-aware text splitting

### 3. Memory Components

#### Conversation Memory
- **ConversationBufferMemory**: Store entire conversation history
- **ConversationBufferWindowMemory**: Store limited conversation window
- **ConversationSummaryMemory**: Summarize conversation history
- **ConversationSummaryBufferMemory**: Hybrid approach

### 4. Chains and Orchestration

#### Basic Chains
- **LLMChain**: Basic LLM + prompt chain
- **SequentialChain**: Chain multiple components sequentially
- **TransformChain**: Transform data between chain steps

#### Specialized Chains
- **RetrievalQAChain**: Question-answering with retrieval
- **ConversationalRetrievalChain**: Conversational Q&A
- **SummarizationChain**: Document summarization

### 5. Retrieval Components

#### Vector Stores
- **MemoryVectorStore**: In-memory vector storage
- **ChromaVectorStore**: Chroma database integration (via langchain_chroma)
- **PineconeVectorStore**: Pinecone integration (via langchain_pinecone)
- **SupabaseVectorStore**: Supabase integration (via langchain_supabase)

#### Retrievers
- **VectorStoreRetriever**: Retrieve from vector stores
- **MultiQueryRetriever**: Multiple query variations
- **EnsembleRetriever**: Combine multiple retrievers

### 6. Agents and Tools

#### Agent Framework
- **Agent**: Autonomous decision-making entities
- **AgentExecutor**: Execute agent workflows
- **Tool**: Individual functions agents can use

#### Built-in Tools
- **CalculatorTool**: Mathematical calculations
- **WebSearchTool**: Web search capabilities
- **DatabaseTool**: Database queries

## Integration-Specific Packages

### LLM Providers
- **langchain_openai** (0.7.4): OpenAI integration (GPT-4, GPT-3.5, embeddings)
- **langchain_google** (latest): Google AI integration (Gemini, PaLM)
- **langchain_ollama** (0.3.3): Local LLM integration via Ollama
- **langchain_anthropic** (latest): Anthropic Claude integration
- **langchain_mistralai** (latest): Mistral AI integration

### Vector Databases
- **langchain_chroma**: Chroma vector database
- **langchain_pinecone**: Pinecone vector database
- **langchain_supabase**: Supabase vector database
- **langchain_firebase**: Firebase integration

### Community Integrations
- **langchain_community**: Additional integrations and tools

## Usage Examples

### Basic Prompt Template
```dart
import 'package:langchain/langchain.dart';

final prompt = PromptTemplate(
  inputVariables: {'topic', 'style'},
  template: 'Write a {style} article about {topic}',
);
```

### Document Processing
```dart
final document = Document(
  pageContent: 'Your content here',
  metadata: {'source': 'file.txt', 'author': 'John Doe'},
);

final splitter = RecursiveCharacterTextSplitter(
  chunkSize: 1000,
  chunkOverlap: 200,
);

final chunks = splitter.splitDocuments([document]);
```

### LLM Chain
```dart
final chain = LLMChain(
  llm: yourLLMInstance, // e.g., OpenAI, Ollama, etc.
  prompt: prompt,
  memory: ConversationBufferMemory(),
);
```

### Vector Store and Retrieval
```dart
final vectorStore = MemoryVectorStore(embeddings: yourEmbeddings);
final retriever = vectorStore.asRetriever();

final qaChain = RetrievalQAChain.fromLlm(
  llm: yourLLMInstance,
  retriever: retriever,
);
```

## LangChain Expression Language (LCEL)

LCEL allows you to compose chains declaratively:

```dart
final chain = prompt | llm | outputParser;
final result = await chain.invoke({'input': 'your input'});
```

## Next Steps

1. **Choose LLM Provider**: Install specific provider package (e.g., `langchain_openai`)
2. **Select Vector Store**: Choose vector database integration if needed
3. **Implement Chains**: Build your LLM application workflow
4. **Add Tools**: Integrate external tools and APIs as needed

## Documentation Resources

- **GitHub Repository**: https://github.com/davidmigloz/langchain_dart
- **Package Documentation**: https://pub.dev/packages/langchain
- **API Reference**: Available through pub.dev
- **Examples**: Check the repository's example directory

The langchain package provides a comprehensive framework for building LLM-powered applications in Dart/Flutter with modular, composable components.
