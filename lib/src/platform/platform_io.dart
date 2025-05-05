import 'dart:io';

/// Gets the value of an environment variable.
///
/// Retrieves the value of the environment variable with the given [key].
/// Throws an exception if the variable is not set or is empty.
String getEnv(String key) {
  final value = Platform.environment[key] ?? '';
  if (value.isEmpty) {
    throw Exception('Environment variable $key is not set');
  }
  return value;
}
