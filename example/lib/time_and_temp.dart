import 'package:json_annotation/json_annotation.dart';
import 'package:soti_schema/annotations.dart';

part 'time_and_temp.g.dart';

@SotiSchema()
@JsonSerializable()
class TimeFunctionInput {
  TimeFunctionInput({required this.timeZoneName});

  /// The name of the time zone to get the time in (e.g. "America/New_York")
  final String timeZoneName;

  static TimeFunctionInput fromJson(Map<String, dynamic> json) =>
      _$TimeFunctionInputFromJson(json);

  @jsonSchema
  static Map<String, dynamic> get schemaMap => _$TimeFunctionInputSchemaMap;
}

@SotiSchema()
@JsonSerializable()
class TimeFunctionOutput {
  TimeFunctionOutput({required this.time});

  /// The time in the given time zone
  final DateTime time;

  Map<String, dynamic> toJson() => _$TimeFunctionOutputToJson(this);

  @jsonSchema
  static Map<String, dynamic> get schemaMap => _$TimeFunctionOutputSchemaMap;
}

@SotiSchema()
@JsonSerializable()
class TempFunctionInput {
  TempFunctionInput({required this.location});

  /// The location to get the temperature in (e.g. "New York, NY")
  final String location;

  static TempFunctionInput fromJson(Map<String, dynamic> json) =>
      _$TempFunctionInputFromJson(json);

  @jsonSchema
  static Map<String, dynamic> get schemaMap => _$TempFunctionInputSchemaMap;
}

@SotiSchema()
@JsonSerializable()
class TempFunctionOutput {
  TempFunctionOutput({required this.temperature});

  /// The temperature in degrees Fahrenheit
  final double temperature;

  Map<String, dynamic> toJson() => _$TempFunctionOutputToJson(this);

  @jsonSchema
  static Map<String, dynamic> get schemaMap => _$TempFunctionOutputSchemaMap;
}
