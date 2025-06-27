# API Key Configuration Migration Guide

## Overview

The API key configuration system has been refactored to provide better security and prevent cross-provider key usage issues. This guide explains the changes and how to migrate your code.

## What Changed

### Before (Deprecated)
```dart
// Global environment map - insecure and prone to cross-provider contamination
Agent.environment['OPENAI_API_KEY'] = 'sk-your-openai-key';
Agent.environment['GEMINI_API_KEY'] = 'your-gemini-key';

final agent = Agent('openai:gpt-4o');
```

### After (Secure)
```dart
// Provider-specific, validated API key management
import 'package:dartantic_ai/src/providers/interface/secure_api_key_manager.dart';

final keyManager = SecureApiKeyManager.instance;
keyManager.setApiKeyByName('openai', 'sk-your-openai-key');
keyManager.setApiKeyByName('google', 'your-gemini-key');

final agent = Agent('openai:gpt-4o');
```

## Key Benefits

### 1. **Cross-Provider Isolation**
The new system prevents accidental key usage across providers:

```dart
// This will now throw a validation error:
keyManager.setApiKeyByName('google', 'sk-openai-key'); // ❌ OpenAI key for Google
```

### 2. **API Key Format Validation**
Keys are validated against their provider's expected format:

```dart
// ✅ Valid
keyManager.setApiKeyByName('openai', 'sk-test123');
keyManager.setApiKeyByName('anthropic', 'sk-ant-test123');
keyManager.setApiKeyByName('openrouter', 'sk-or-test123');
keyManager.setApiKeyByName('huggingface', 'hf_test123');

// ❌ Invalid - will throw ArgumentError
keyManager.setApiKeyByName('openai', 'invalid-format');
```

### 3. **Provider Alias Support**
The system handles provider aliases automatically:

```dart
// These are equivalent:
keyManager.setApiKeyByName('google', 'your-key');
keyManager.setApiKeyByName('gemini', 'your-key');
keyManager.setApiKeyByName('googleai', 'your-key');
```

## Migration Steps

### Step 1: Replace Agent.environment Usage

**Old Code:**
```dart
Agent.environment['OPENAI_API_KEY'] = openaiKey;
Agent.environment['GEMINI_API_KEY'] = geminiKey;
```

**New Code:**
```dart
final keyManager = SecureApiKeyManager.instance;
keyManager.setApiKeyByName('openai', openaiKey);
keyManager.setApiKeyByName('google', geminiKey);
```

### Step 2: Update Test Setup

**Old Test Code:**
```dart
setUp(() {
  Agent.environment['OPENAI_API_KEY'] = 'test-key';
});

tearDown(() {
  Agent.environment.clear();
});
```

**New Test Code:**
```dart
setUp(() {
  SecureApiKeyManager.instance.setApiKeyByName('openai', 'sk-test-key');
});

tearDown(() {
  SecureApiKeyManager.instance.clearAllKeys();
});
```

### Step 3: Handle Environment Variables

The new system still supports environment variables as a fallback:

```dart
// Environment variables are automatically loaded:
// OPENAI_API_KEY=sk-your-key
// GEMINI_API_KEY=your-gemini-key

final agent = Agent('openai:gpt-4o'); // Will use OPENAI_API_KEY automatically
```

For explicit environment handling:
```dart
import 'dart:io';

final openaiKey = Platform.environment['OPENAI_API_KEY'];
if (openaiKey != null) {
  SecureApiKeyManager.instance.setApiKeyByName('openai', openaiKey);
}
```

## Supported Providers

The secure API key manager supports these providers with format validation:

| Provider | Environment Variable | Key Format | Example |
|----------|---------------------|------------|---------|
| OpenAI | `OPENAI_API_KEY` | `sk-*` | `sk-test123` |
| Google/Gemini | `GEMINI_API_KEY`, `GOOGLE_API_KEY` | Not `sk-*` | `AIza...` |
| OpenRouter | `OPENROUTER_API_KEY` | `sk-or-*` | `sk-or-test123` |
| Anthropic | `ANTHROPIC_API_KEY` | `sk-ant-*` | `sk-ant-test123` |
| Azure OpenAI | `AZURE_OPENAI_API_KEY` | Not `sk-*` | Custom format |
| Cohere | `COHERE_API_KEY` | Not `sk-*` | Custom format |
| HuggingFace | `HUGGINGFACE_API_KEY` | `hf_*` | `hf_test123` |

## Backward Compatibility

The old `Agent.environment` map is still supported but deprecated. It will:

1. Show deprecation warnings when used
2. Automatically delegate to the secure key manager
3. Validate keys when possible
4. Continue working for existing code

Example of deprecation warning:
```
DEPRECATION WARNING: setting Agent.environment['OPENAI_API_KEY'] is deprecated. 
Use SecureApiKeyManager.instance.setApiKeyByName('openai', value) instead 
for better security and cross-provider isolation.
```

## Error Handling

The new system provides detailed error messages for common issues:

### Invalid Key Format
```dart
// Throws: ArgumentError: OpenAI API keys must start with "sk-". Received key starting with "inv..."
keyManager.setApiKeyByName('openai', 'invalid-key');
```

### Cross-Provider Key Usage
```dart
// Throws: ArgumentError: Google/Gemini API keys should not start with "sk-" (that's an OpenAI format)
keyManager.setApiKeyByName('google', 'sk-openai-key');
```

### Unsupported Provider
```dart
// Throws: ArgumentError: Unsupported provider: unknown-provider
keyManager.setApiKeyByName('unknown-provider', 'some-key');
```

## Configuration Validation

Check your configuration for issues:

```dart
final keyManager = SecureApiKeyManager.instance;

// List configured providers
final configured = keyManager.getConfiguredProviders();
print('Configured providers: $configured');

// Validate configuration
final issues = keyManager.validateConfiguration();
if (issues.isNotEmpty) {
  print('Configuration issues:');
  for (final issue in issues) {
    print('  - $issue');
  }
}
```

## Best Practices

### 1. **Set Keys Early**
Configure API keys at application startup:

```dart
void main() {
  // Configure API keys first
  _configureApiKeys();
  
  // Then start your application
  runApp(MyApp());
}

void _configureApiKeys() {
  final keyManager = SecureApiKeyManager.instance;
  
  // Load from environment or secure storage
  final openaiKey = Platform.environment['OPENAI_API_KEY'];
  if (openaiKey != null) {
    keyManager.setApiKeyByName('openai', openaiKey);
  }
}
```

### 2. **Use Provider Names Consistently**
Stick to canonical provider names:

```dart
// ✅ Preferred
keyManager.setApiKeyByName('openai', key);
keyManager.setApiKeyByName('google', key);
keyManager.setApiKeyByName('anthropic', key);

// ⚠️ Works but less clear
keyManager.setApiKeyByName('gemini', key);
keyManager.setApiKeyByName('claude', key);
```

### 3. **Clear Keys in Tests**
Always clean up API keys in tests:

```dart
tearDown(() {
  SecureApiKeyManager.instance.clearAllKeys();
});
```

### 4. **Handle Missing Keys Gracefully**
Check for key availability before creating agents:

```dart
final keyManager = SecureApiKeyManager.instance;
final openaiKey = keyManager.getApiKeyByName('openai');

if (openaiKey == null) {
  throw Exception('OpenAI API key not configured');
}

final agent = Agent('openai:gpt-4o');
```

## Security Considerations

### 1. **Key Isolation**
Each provider can only access its own API keys, preventing accidental cross-usage.

### 2. **Format Validation**
Keys are validated against expected formats to catch configuration errors early.

### 3. **No Global State Pollution**
The secure manager isolates keys from the global environment map.

### 4. **Clear Error Messages**
Validation failures provide specific guidance on fixing issues.

## Troubleshooting

### Issue: "Unsupported provider" Error
**Solution:** Check that you're using a supported provider name. See the provider table above.

### Issue: "Invalid API key format" Error
**Solution:** Verify your API key format matches the provider's expected format.

### Issue: "Cross-provider key usage" Error
**Solution:** Ensure you're not trying to use one provider's key with another provider.

### Issue: Deprecation Warnings
**Solution:** Migrate from `Agent.environment` to `SecureApiKeyManager.instance`.

## Complete Migration Example

**Before:**
```dart
import 'dart:io';
import 'package:dartantic_ai/dartantic_ai.dart';

void main() async {
  // Old insecure approach
  Agent.environment['OPENAI_API_KEY'] = Platform.environment['OPENAI_API_KEY']!;
  Agent.environment['GEMINI_API_KEY'] = Platform.environment['GEMINI_API_KEY']!;
  
  final openaiAgent = Agent('openai:gpt-4o');
  final geminiAgent = Agent('google:gemini-2.0-flash');
  
  // Use agents...
}
```

**After:**
```dart
import 'dart:io';
import 'package:dartantic_ai/dartantic_ai.dart';
import 'package:dartantic_ai/src/providers/interface/secure_api_key_manager.dart';

void main() async {
  // New secure approach
  final keyManager = SecureApiKeyManager.instance;
  
  final openaiKey = Platform.environment['OPENAI_API_KEY'];
  if (openaiKey != null) {
    keyManager.setApiKeyByName('openai', openaiKey);
  }
  
  final geminiKey = Platform.environment['GEMINI_API_KEY'];
  if (geminiKey != null) {
    keyManager.setApiKeyByName('google', geminiKey);
  }
  
  // Validate configuration
  final issues = keyManager.validateConfiguration();
  if (issues.isNotEmpty) {
    print('API key configuration issues: $issues');
    return;
  }
  
  final openaiAgent = Agent('openai:gpt-4o');
  final geminiAgent = Agent('google:gemini-2.0-flash');
  
  // Use agents...
}
```

This migration provides better security, clearer error messages, and prevents common configuration mistakes while maintaining backward compatibility.
