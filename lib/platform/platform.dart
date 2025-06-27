import 'dart:io' if (dart.library.html) 'dart:html' as platform_impl;

import '../src/agent/agent.dart';

/// Cross-platform environment variable access.
/// 
/// This module provides a unified interface for accessing environment variables
/// across different Dart platforms (Flutter, web, native).
class Platform {
  Platform._();
  
  /// Gets an environment variable value.
  /// 
  /// First checks Agent.environment, then falls back to system environment.
  /// On native platforms (Dart VM), this uses Platform.environment.
  /// On web platforms, this uses a fallback mechanism or returns null.
  /// 
  /// [key] - The environment variable name to retrieve
  /// 
  /// Returns the environment variable value, or null if not found
  static String? getEnv(String key) {
    // First check Agent.environment
    final agentValue = Agent.environment[key];
    if (agentValue != null && agentValue.isNotEmpty) {
      return agentValue;
    }
    
    try {
      // Then fall back to system environment (for native platforms)
      if (platform_impl.Platform.environment.isNotEmpty) {
        return platform_impl.Platform.environment[key];
      }
    } catch (e) {
      // Web platform or other environments where Platform.environment is not available
      // Return null and let the application handle missing keys
    }
    
    return null;
  }
}

/// Gets an environment variable value.
/// 
/// This is a convenience function that delegates to Platform.getEnv.
/// First checks Agent.environment, then falls back to system environment.
/// 
/// [key] - The environment variable name to retrieve
/// 
/// Returns the environment variable value, or null if not found
String? getEnv(String key) => Platform.getEnv(key);
