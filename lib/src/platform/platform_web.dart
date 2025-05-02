String getEnv(String key) {
  throw Exception('Environment variable $key is not supported on the web');
}
