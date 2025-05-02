import 'dart:io';

String getEnv(String key) {
  final value = Platform.environment[key] ?? '';
  if (value.isEmpty) {
    throw Exception('Environment variable $key is not set');
  }
  return value;
}
