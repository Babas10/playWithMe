import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:play_with_me/core/config/environment_config.dart';

/// Provides Firebase options for different environments
/// This class acts as a bridge between environment configuration and Firebase initialization
class FirebaseOptionsProvider {
  /// Get Firebase options for the current environment
  static FirebaseOptions getFirebaseOptions() {
    final environment = EnvironmentConfig.environment;

    debugPrint('🔧 Getting Firebase options for ${environment.name} environment');

    switch (environment) {
      case Environment.dev:
        return _getDevOptions();
      case Environment.stg:
        return _getStagingOptions();
      case Environment.prod:
        return _getProdOptions();
    }
  }

  /// Development environment Firebase options
  /// These are placeholder values that should be replaced with real configuration
  static FirebaseOptions _getDevOptions() {
    return const FirebaseOptions(
      apiKey: 'dev-api-key-placeholder',
      appId: 'dev-app-id-placeholder',
      messagingSenderId: 'dev-sender-id-placeholder',
      projectId: 'playwithme-dev',
      storageBucket: 'playwithme-dev.appspot.com',
      authDomain: 'playwithme-dev.firebaseapp.com',
    );
  }

  /// Staging environment Firebase options
  /// These are placeholder values that should be replaced with real configuration
  static FirebaseOptions _getStagingOptions() {
    return const FirebaseOptions(
      apiKey: 'stg-api-key-placeholder',
      appId: 'stg-app-id-placeholder',
      messagingSenderId: 'stg-sender-id-placeholder',
      projectId: 'playwithme-stg',
      storageBucket: 'playwithme-stg.appspot.com',
      authDomain: 'playwithme-stg.firebaseapp.com',
    );
  }

  /// Production environment Firebase options
  /// These are placeholder values that should be replaced with real configuration
  static FirebaseOptions _getProdOptions() {
    return const FirebaseOptions(
      apiKey: 'prod-api-key-placeholder',
      appId: 'prod-app-id-placeholder',
      messagingSenderId: 'prod-sender-id-placeholder',
      projectId: 'playwithme-prod',
      storageBucket: 'playwithme-prod.appspot.com',
      authDomain: 'playwithme-prod.firebaseapp.com',
    );
  }

  /// Validate that Firebase options are properly configured
  /// This helps catch configuration issues early
  static bool validateConfiguration() {
    try {
      final options = getFirebaseOptions();

      // Check for placeholder values that should be replaced
      final placeholderChecks = [
        options.apiKey.contains('placeholder'),
        options.appId.contains('placeholder'),
        options.messagingSenderId.contains('placeholder'),
      ];

      if (placeholderChecks.any((isPlaceholder) => isPlaceholder)) {
        debugPrint('⚠️  Warning: Firebase configuration contains placeholder values');
        debugPrint('📋 Please replace placeholder values with real Firebase configuration');
        return false;
      }

      // Validate required fields are not empty
      if (options.projectId.isEmpty ||
          options.apiKey.isEmpty ||
          options.appId.isEmpty) {
        debugPrint('❌ Firebase configuration validation failed: Required fields are empty');
        return false;
      }

      debugPrint('✅ Firebase configuration validation passed');
      return true;

    } catch (e) {
      debugPrint('❌ Firebase configuration validation failed: $e');
      return false;
    }
  }

  /// Get a summary of the current Firebase configuration
  static Map<String, String> getConfigurationSummary() {
    final options = getFirebaseOptions();

    return {
      'environment': EnvironmentConfig.environmentName,
      'projectId': options.projectId,
      'appId': options.appId,
      'storageBucket': options.storageBucket ?? 'Not set',
      'authDomain': options.authDomain ?? 'Not set',
      'hasPlaceholders': _hasPlaceholderValues(options).toString(),
    };
  }

  /// Check if the configuration has placeholder values
  static bool _hasPlaceholderValues(FirebaseOptions options) {
    return options.apiKey.contains('placeholder') ||
           options.appId.contains('placeholder') ||
           options.messagingSenderId.contains('placeholder');
  }
}