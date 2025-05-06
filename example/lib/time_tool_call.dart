import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'time_and_temp.dart';

Future<Map<String, dynamic>?> onTimeCall(Map<String, dynamic> input) async {
  // Initialize timezone data
  tz_data.initializeTimeZones();

  final timeInput = TimeFunctionInput.fromJson(input);
  final timeZoneName = timeInput.timeZoneName;

  // Get the timezone location
  final location = tz.getLocation(timeZoneName);

  // Get current time in the specified timezone
  final now = tz.TZDateTime.now(location);

  // Return the time as a DateTime object
  return TimeFunctionOutput(time: now).toJson();
}
