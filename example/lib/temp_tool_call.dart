import 'dart:convert';

import 'package:http/http.dart' as http;

import 'time_and_temp.dart';

Future<Map<String, dynamic>?> onTempCall(Map<String, dynamic> input) async {
  final tempInput = TempFunctionInput.fromJson(input);
  final location = tempInput.location;

  // Use Nominatim API (OpenStreetMap) for better geocoding of vague place names
  final encodedLocation = Uri.encodeComponent(location);
  final geocodeUrl = Uri.parse(
    'https://nominatim.openstreetmap.org/search?q=$encodedLocation&format=json&limit=1',
  );

  // Add a user agent header as required by Nominatim's usage policy
  final geocodeResponse = await http.get(
    geocodeUrl,
    headers: {'User-Agent': 'DartanticAI/1.0'},
  );

  if (geocodeResponse.statusCode != 200) {
    throw Exception(
      'Geocoding failed: ${geocodeResponse.statusCode}: '
      '${geocodeResponse.body}',
    );
  }

  final geocodeData = jsonDecode(geocodeResponse.body) as List<dynamic>;

  if (geocodeData.isEmpty) {
    throw Exception('Location not found: $location');
  }

  // Extract latitude and longitude from the first result

  // ignore: avoid_dynamic_calls
  final latitude = double.parse(geocodeData[0]['lat'] as String);
  // ignore: avoid_dynamic_calls
  final longitude = double.parse(geocodeData[0]['lon'] as String);

  // Open-Meteo API doesn't require an API key
  final weatherUrl = Uri.parse(
    'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&current=temperature_2m&temperature_unit=fahrenheit',
  );

  final weatherResponse = await http.get(weatherUrl);

  if (weatherResponse.statusCode != 200) {
    throw Exception(
      'Weather API failed: ${weatherResponse.statusCode}: '
      '${weatherResponse.body}',
    );
  }

  final weatherData = jsonDecode(weatherResponse.body);

  // Extract temperature in Fahrenheit
  // ignore: avoid_dynamic_calls
  final temperature = weatherData['current']['temperature_2m'] as double;

  return TempFunctionOutput(temperature: temperature).toJson();
}
