// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'temp_tool_call.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TempFunctionInput _$TempFunctionInputFromJson(Map<String, dynamic> json) =>
    TempFunctionInput(
      location: json['location'] as String,
    );

Map<String, dynamic> _$TempFunctionInputToJson(TempFunctionInput instance) =>
    <String, dynamic>{
      'location': instance.location,
    };

TempFunctionOutput _$TempFunctionOutputFromJson(Map<String, dynamic> json) =>
    TempFunctionOutput(
      temperature: (json['temperature'] as num).toDouble(),
    );

Map<String, dynamic> _$TempFunctionOutputToJson(TempFunctionOutput instance) =>
    <String, dynamic>{
      'temperature': instance.temperature,
    };

// **************************************************************************
// SotiSchemaGenerator
// **************************************************************************

const _$TempFunctionInputSchemaMap = <String, dynamic>{
  r'$schema': r'https://json-schema.org/draft/2020-12/schema',
  r'type': r'object',
  r'properties': {
    r'location': {
      r'type': r'string',
      r'description':
          r'/// The location to get the temperature in (e.g. "New York, NY")'
    }
  },
  r'required': [r'location'],
  r'$defs': {}
};

const _$TempFunctionOutputSchemaMap = <String, dynamic>{
  r'$schema': r'https://json-schema.org/draft/2020-12/schema',
  r'type': r'object',
  r'properties': {
    r'temperature': {
      r'type': r'number',
      r'description': r'/// The temperature in degrees Fahrenheit'
    }
  },
  r'required': [r'temperature'],
  r'$defs': {}
};
