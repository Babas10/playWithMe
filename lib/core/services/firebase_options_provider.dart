import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:play_with_me/core/config/environment_config.dart';
import 'package:play_with_me/core/config/firebase_config_dev.dart';
import 'package:play_with_me/core/config/firebase_config_stg.dart';
import 'package:play_with_me/core/config/firebase_config_prod.dart';

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
  static FirebaseOptions _getDevOptions() {
    final config = FirebaseConfigDev();
    return FirebaseOptions(
      apiKey: config.apiKey,
      appId: defaultTargetPlatform == TargetPlatform.android
          ? config.androidAppId
          : config.iosAppId,
      messagingSenderId: config.messagingSenderId,
      projectId: config.projectId,
      storageBucket: config.storageBucket,
      authDomain: '${config.projectId}.firebaseapp.com',
    );
  }

  /// Staging environment Firebase options
  static FirebaseOptions _getStagingOptions() {
    final config = FirebaseConfigStg();
    return FirebaseOptions(
      apiKey: config.apiKey,
      appId: defaultTargetPlatform == TargetPlatform.android
          ? config.androidAppId
          : config.iosAppId,
      messagingSenderId: config.messagingSenderId,
      projectId: config.projectId,
      storageBucket: config.storageBucket,
      authDomain: '${config.projectId}.firebaseapp.com',
    );
  }

  /// Production environment Firebase options
  static FirebaseOptions _getProdOptions() {
    final config = FirebaseConfigProd();
    return FirebaseOptions(
      apiKey: config.apiKey,
      appId: defaultTargetPlatform == TargetPlatform.android
          ? config.androidAppId
          : config.iosAppId,
      messagingSenderId: config.messagingSenderId,
      projectId: config.projectId,
      storageBucket: config.storageBucket,
      authDomain: '${config.projectId}.firebaseapp.com',
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