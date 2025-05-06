// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'time_and_temp.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TimeFunctionInput _$TimeFunctionInputFromJson(Map<String, dynamic> json) =>
    TimeFunctionInput(
      timeZoneName: json['timeZoneName'] as String,
    );

Map<String, dynamic> _$TimeFunctionInputToJson(TimeFunctionInput instance) =>
    <String, dynamic>{
      'timeZoneName': instance.timeZoneName,
    };

TimeFunctionOutput _$TimeFunctionOutputFromJson(Map<String, dynamic> json) =>
    TimeFunctionOutput(
      time: DateTime.parse(json['time'] as String),
    );

Map<String, dynamic> _$TimeFunctionOutputToJson(TimeFunctionOutput instance) =>
    <String, dynamic>{
      'time': instance.time.toIso8601String(),
    };

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

const _$TimeFunctionInputSchemaMap = <String, dynamic>{
  r'$schema': r'https://json-schema.org/draft/2020-12/schema',
  r'type': r'object',
  r'properties': {
    r'timeZoneName': {
      r'type': r'string',
      r'description':
          r'/// The name of the time zone to get the time in (e.g. "America/New_York")'
    }
  },
  r'required': [r'timeZoneName'],
  r'$defs': {}
};

const _$TimeFunctionOutputSchemaMap = <String, dynamic>{
  r'$schema': r'https://json-schema.org/draft/2020-12/schema',
  r'type': r'object',
  r'properties': {
    r'time': {
      r'type': r'string',
      r'format': r'date-time',
      r'description': r'/// The time in the given time zone'
    }
  },
  r'required': [r'time'],
  r'$defs': {}
};

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
