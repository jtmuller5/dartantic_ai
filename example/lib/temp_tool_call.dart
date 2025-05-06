import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';
import 'package:soti_schema/annotations.dart';

part 'temp_tool_call.g.dart';

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

/// Use free, API-key-free services to look up the weather for a given location.
Future<Map<String, dynamic>> onTempCall(Map<String, dynamic> input) async {
  // parse the JSON input into a type-safe object
  final tempInput = TempFunctionInput.fromJson(input);

  // Use Nominatim API (OpenStreetMap) for better geocoding of vague place names
  final geocodeUrl = Uri.parse(
    'https://nominatim.openstreetmap.org/search?q=${tempInput.location}&format=json&limit=1',
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
    throw Exception('Location not found: ${tempInput.location}');
  }

  // ignore: avoid_dynamic_calls
  final lat = double.parse(geocodeData[0]['lat'] as String);

  // ignore: avoid_dynamic_calls
  final long = double.parse(geocodeData[0]['lon'] as String);

  // Use Open-Meteo API for weather data given a latitude and longitude
  final weatherUrl = Uri.parse(
    'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$long&current=temperature_2m&temperature_unit=fahrenheit',
  );

  final weatherResponse = await http.get(weatherUrl);
  if (weatherResponse.statusCode != 200) {
    throw Exception(
      'Weather API failed: ${weatherResponse.statusCode}: '
      '${weatherResponse.body}',
    );
  }

  final weatherData = jsonDecode(weatherResponse.body);

  // ignore: avoid_dynamic_calls
  final temperature = weatherData['current']['temperature_2m'] as double;

  // return a JSON map directly as output
  return {'temperature': temperature};
}
