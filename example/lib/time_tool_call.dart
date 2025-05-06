import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'time_and_temp.dart';

/// Use the timezone package to get the current time in a given timezone.
Future<Map<String, Object?>?> onTimeCall(Map<String, Object?> input) async {
  // parse the JSON input into a type-safe object
  final timeInput = TimeFunctionInput.fromJson(input);

  tz_data.initializeTimeZones();
  final location = tz.getLocation(timeInput.timeZoneName);
  final now = tz.TZDateTime.now(location);

  // construct a type-safe object, then translate to JSON to return
  return TimeFunctionOutput(time: now).toJson();
}
