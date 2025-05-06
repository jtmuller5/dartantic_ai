# dartantic_ai
The [dartantic_ai package for Dart](https://pub.dev/packages/dartantic_ai) is
inspired by [the pydantic-ai package for Python](https://ai.pydantic.dev/) to
provide easy, typed access to LLM outputs and tool/function calls across
multiple LLMs.

## Alpha
Only supporting Gemini and OpenAI models via API keys in this limited release.

## Features
The following are the target features for this package:
- [x] Multi-Model Support
- [x] Create agents from model strings (e.g. `openai:gpt-4o`) or typed
  providers (e.g. `GoogleProvider()`)
- [x] Automatically check environment for API key if none is provided (not web
  compatible)
- [x] String output via `Agent.run`
- [x] Typed output via `Agent.runFor`
- [x] Define tools and their inputs/outputs easily
- [x] Automatically generate LLM-specific tool/output schemas
- [ ] Bring your own provider
- [ ] Execute tools with validated inputs
- [ ] Chains and Sequential Execution
- [ ] JSON Mode, Functions Mode, Flexible Decoding
- [ ] Simple Assistant/Agent loop utilities
- [ ] Per call usage statistics

## Usage

The following are some examples that work in the current build.

### Basic Agent Usage

The following shows simple agent usage.

```dart
void main() async {
  // Create an agent with a system prompt
  final agent = Agent(
    model: 'openai:gpt-4o'
    systemPrompt: 'Be concise, reply with one sentence.',
  );

  // Run the agent with a prompt
  final result = await agent.run('Where does "hello world" come from?');
  print(result.output); // Output: one sentence on the origin on "hello world"
}
```

### JSON Output with JSON Schema

The following example provides JSON output using a hand-written `schemaMap`
property, which configures the underlying LLM to response in JSON.


```dart
void main() async {
  // Define a JSON schema for structured output
  final townCountrySchema = {
    'type': 'object',
    'properties': {
      'town': {'type': 'string'},
      'country': {'type': 'string'},
    },
    'required': ['town', 'country'],
    'additionalProperties': false,
  };

  // Create an agent with the schema
  final agent = Agent(
    model: 'openai:gpt-4o'
    outputType: townCountrySchema,
  );

  // Get structured output as a JSON object
  final result = await agent.run('The windy city in the US of A.');
  print(result.output); // Output: {"town":"Chicago","country":"United States"}
}
```

### Manual Typed Output with Object Mapping

The following example provides typed output using automatic json decoding from a
hand-written `fromJson` method and a hand-written `schemaMap` property.


```dart
// Create a data class in your code
class TownAndCountry {
  final String town;
  final String country;
  
  TownAndCountry({required this.town, required this.country});
  
  factory TownAndCountry.fromJson(Map<String, dynamic> json) => TownAndCountry(
      town: json['town'],
      country: json['country'],
    );
  
  static Map<String, dynamic> get schemaMap => {
    'type': 'object',
    'properties': {
      'town': {'type': 'string'},
      'country': {'type': 'string'},
    },
    'required': ['town', 'country'],
    'additionalProperties': false,
  };
  
  @override
  String toString() => 'TownAndCountry(town: $town, country: $country)';
}

void main() async {
  // Use runFor with a type parameter for automatic conversion 
  final agent = Agent(
    model: 'openai:gpt-4o'
    outputType: TownAndCountry.schemaMap,
    outputFromJson: TownAndCountry.fromJson,
  );

  final result = await agent.runFor<TownAndCountry>(
    'The windy city in the US of A.',
  );

  print(result.output); // Output: TownAndCountry(town: Chicago, country: United States)
}
```

### Automatic Typed Output with Object Mapping

The following example provides typed output using
[json_serializable](https://pub.dev/packages/json_serializable) for automatic
json decoding and [soti_schema](https://pub.dev/packages/soti_schema) for
automatic Json Schema definition.

```dart
// Create a data class in your code
@SotiSchema()
@JsonSerializable()
class TownAndCountry {
  TownAndCountry({required this.town, required this.country});

  factory TownAndCountry.fromJson(Map<String, dynamic> json) =>
      _$TownAndCountryFromJson(json);

  final String town;
  final String country;

  Map<String, dynamic> toJson() => _$TownAndCountryToJson(this);

  @jsonSchema
  static Map<String, dynamic> get schemaMap => _$TownAndCountrySchemaMap;

  @override
  String toString() => 'TownAndCountry(town: $town, country: $country)';
}

void main() {
  // Use runFor with a type parameter for automatic conversion 
  final agent = Agent(
    model: 'openai:gpt-4o'
    outputType: TownAndCountry.schemaMap,
    outputFromJson: TownAndCountry.fromJson,
  );

  final result = await agent.runFor<TownAndCountry>(
    'The windy city in the US of A.',
  );

  print(result.output); // Output: TownAndCountry(town: Chicago, country: United States)
}
```
