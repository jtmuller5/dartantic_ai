import 'dart:convert';

import 'package:http/http.dart' as http;

import 'time_and_temp.dart';

Future<Map<String, dynamic>?> onTempCall(Map<String, dynamic> input) async {
  final tempInput = TempFunctionInput.fromJson(input);
  final location = tempInput.location;

  // First, geocode the location string to get coordinates
  final geocodeUrl = Uri.parse(
    'https://geocoding-api.open-meteo.com/v1/search?name=$location&count=1',
  );
  final geocodeResponse = await http.get(geocodeUrl);

  if (geocodeResponse.statusCode != 200) {
    throw Exception(
      'Geocoding failed: ${geocodeResponse.statusCode}: '
      '${geocodeResponse.body}',
    );
  }

  final geocodeData = jsonDecode(geocodeResponse.body);

  // ignore: avoid_dynamic_calls
  final results = geocodeData['results'] as List<dynamic>?;
  if (results == null || results.isEmpty) {
    throw Exception('Location not found: $location');
  }

  // ignore: avoid_dynamic_calls
  final latitude = results[0]['latitude'];

  // ignore: avoid_dynamic_calls
  final longitude = results[0]['longitude'];

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
