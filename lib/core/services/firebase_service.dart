import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:play_with_me/core/config/environment_config.dart';
import 'package:play_with_me/core/services/firebase_options_provider.dart';

class FirebaseService {
  static FirebaseApp? _app;
  static bool _isInitialized = false;

  /// Initialize Firebase for the current environment
  static Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('🔥 Firebase already initialized');
      return;
    }

    try {
      debugPrint('🔥 Initializing Firebase for ${EnvironmentConfig.environmentName}...');

      // Validate configuration before initialization
      if (!FirebaseOptionsProvider.validateConfiguration()) {
        debugPrint('⚠️  Proceeding with placeholder configuration for development');
      }

      // Initialize Firebase with environment-specific configuration
      _app = await Firebase.initializeApp(
        name: EnvironmentConfig.firebaseProjectId,
        options: FirebaseOptionsProvider.getFirebaseOptions(),
      );

      // Configure Firestore settings
      await _configureFirestore();

      _isInitialized = true;

      debugPrint('✅ Firebase initialized successfully');
      debugPrint('🔗 Connected to project: ${EnvironmentConfig.firebaseProjectId}');

    } catch (e, stackTrace) {
      debugPrint('❌ Firebase initialization failed: $e');
      debugPrint('Stack trace: $stackTrace');
      throw FirebaseInitializationException(
        'Failed to initialize Firebase: $e',
        originalException: e,
      );
    }
  }


  /// Configure Firestore settings for optimal performance
  static Future<void> _configureFirestore() async {
    final firestore = FirebaseFirestore.instance;

    // Enable offline persistence
    await firestore.enableNetwork();

    // Configure settings based on environment
    if (!EnvironmentConfig.isProduction) {
      // Enable more verbose logging in non-production
      FirebaseFirestore.setLoggingEnabled(true);
    }

    debugPrint('🗄️ Firestore configured for ${EnvironmentConfig.environmentName}');
  }


  /// Get the current Firebase app instance
  static FirebaseApp? get app => _app;

  /// Check if Firebase is initialized
  static bool get isInitialized => _isInitialized;

  /// Get Firestore instance
  static FirebaseFirestore get firestore {
    if (!_isInitialized) {
      throw StateError('Firebase not initialized. Call FirebaseService.initialize() first.');
    }
    return FirebaseFirestore.instance;
  }

  /// Get Firebase Auth instance
  static FirebaseAuth get auth {
    if (!_isInitialized) {
      throw StateError('Firebase not initialized. Call FirebaseService.initialize() first.');
    }
    return FirebaseAuth.instance;
  }

  /// Get connection status information
  static Map<String, dynamic> getConnectionInfo() {
    return {
      'isInitialized': _isInitialized,
      'environment': EnvironmentConfig.environmentName,
      'projectId': EnvironmentConfig.firebaseProjectId,
      'appName': _app?.name,
    };
  }

  /// Test Firebase connection by attempting to read from Firestore
  static Future<bool> testConnection() async {
    try {
      if (!_isInitialized) {
        return false;
      }

      // Try to read from a known collection to test connectivity
      await firestore
          .collection('users')
          .limit(1)
          .get(const GetOptions(source: Source.server));

      debugPrint('✅ Firebase connection test successful');
      return true;
    } catch (e) {
      debugPrint('❌ Firebase connection test failed: $e');
      return false;
    }
  }

  /// Dispose Firebase resources (mainly for testing)
  static Future<void> dispose() async {
    if (_app != null) {
      await _app!.delete();
      _app = null;
    }
    _isInitialized = false;
    debugPrint('🔥 Firebase disposed');
  }
}

/// Custom exception for Firebase initialization errors
class FirebaseInitializationException implements Exception {
  final String message;
  final dynamic originalException;

  const FirebaseInitializationException(
    this.message, {
    this.originalException,
  });

  @override
  String toString() {
    return 'FirebaseInitializationException: $message';
  }
}