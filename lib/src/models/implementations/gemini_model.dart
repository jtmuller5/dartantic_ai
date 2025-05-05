import 'package:google_generative_ai/google_generative_ai.dart';

import '../../agent/agent_response.dart';
import '../interface/model.dart';

class GeminiModel extends Model {
  GeminiModel({
    required String modelName,
    required String apiKey,
    Map<String, dynamic>? outputType,
    this.systemPrompt,
  }) : _model = GenerativeModel(
         apiKey: apiKey,
         model: modelName,
         generationConfig:
             outputType == null
                 ? null
                 : GenerationConfig(
                   responseMimeType: 'application/json',
                   responseSchema: _schemaObjectFrom(outputType),
                 ),
         systemInstruction:
             systemPrompt != null ? Content.text(systemPrompt) : null,
       );

  late final GenerativeModel _model;
  final String? systemPrompt;

  @override
  Future<AgentResponse> run(String prompt) async {
    final result = await _model.generateContent([Content.text(prompt)]);
    return AgentResponse(output: result.text ?? '');
  }

  static Schema _schemaObjectFrom(Map<String, dynamic> jsonSchema) {
    final type = _getSchemaType(jsonSchema['type']);

    return switch (type) {
      SchemaType.object => Schema.object(
        properties: _extractProperties(jsonSchema['properties'] ?? {}),
        requiredProperties: _extractRequiredProperties(jsonSchema['required']),
        description: jsonSchema['description'],
        nullable: jsonSchema['nullable'],
      ),
      SchemaType.array => Schema.array(
        items: _schemaObjectFrom(jsonSchema['items'] ?? {}),
        description: jsonSchema['description'],
        nullable: jsonSchema['nullable'],
      ),
      SchemaType.string when jsonSchema['enum'] != null => Schema.enumString(
        enumValues: List<String>.from(jsonSchema['enum']),
        description: jsonSchema['description'],
        nullable: jsonSchema['nullable'],
      ),
      SchemaType.string => Schema.string(
        description: jsonSchema['description'],
        nullable: jsonSchema['nullable'],
      ),
      SchemaType.number => Schema.number(
        description: jsonSchema['description'],
        nullable: jsonSchema['nullable'],
        format: jsonSchema['format'],
      ),
      SchemaType.integer => Schema.integer(
        description: jsonSchema['description'],
        nullable: jsonSchema['nullable'],
        format: jsonSchema['format'],
      ),
      SchemaType.boolean => Schema.boolean(
        description: jsonSchema['description'],
        nullable: jsonSchema['nullable'],
      ),
    };
  }

  static Map<String, Schema> _extractProperties(
    Map<String, dynamic> properties,
  ) {
    final result = <String, Schema>{};
    for (final entry in properties.entries) {
      result[entry.key] = _schemaObjectFrom(entry.value);
    }
    return result;
  }

  static List<String>? _extractRequiredProperties(dynamic required) {
    if (required == null) return null;
    return List<String>.from(required);
  }

  static SchemaType _getSchemaType(String? typeString) => switch (typeString
      ?.toLowerCase()) {
    'string' => SchemaType.string,
    'number' => SchemaType.number,
    'integer' => SchemaType.integer,
    'boolean' => SchemaType.boolean,
    'array' => SchemaType.array,
    'object' => SchemaType.object,
    _ => SchemaType.object, // Default to object if type is not specified
  };
}
