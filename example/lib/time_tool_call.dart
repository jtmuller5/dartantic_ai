import 'package:json_annotation/json_annotation.dart';
import 'package:soti_schema/annotations.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

part 'time_tool_call.g.dart';

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

@JsonSerializable()
class TimeFunctionOutput {
  TimeFunctionOutput({required this.time});

  /// The time in the given time zone
  final DateTime time;

  Map<String, dynamic> toJson() => _$TimeFunctionOutputToJson(this);
}

/// Use the timezone package to get the current time in a given timezone.
Future<Map<String, dynamic>?> onTimeCall(Map<String, dynamic> input) async {
  // parse the JSON input into a type-safe object
  final timeInput = TimeFunctionInput.fromJson(input);

  tz_data.initializeTimeZones();
  final location = tz.getLocation(timeInput.timeZoneName);
  final now = tz.TZDateTime.now(location);

  // construct a type-safe object, then translate to JSON to return
  return TimeFunctionOutput(time: now).toJson();
}
