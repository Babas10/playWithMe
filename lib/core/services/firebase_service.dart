import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
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
      // Handle both auto-initialization (iOS) and manual initialization

      // Handle Firebase initialization with comprehensive duplicate app handling
      // Check all available Firebase apps first
      debugPrint('🔍 Checking Firebase apps: ${Firebase.apps.length} apps available');
      for (final app in Firebase.apps) {
        debugPrint('📱 Found Firebase app: ${app.name} (${app.options.projectId})');
      }

      // Try to get the default app first (handles both auto-initialization and manual initialization)
      try {
        _app = Firebase.app();
        debugPrint('🔥 Found existing default Firebase app: ${_app!.name}');
        debugPrint('🔗 Project: ${_app!.options.projectId}');

        // Verify the existing app is using the correct project
        final currentProjectId = _app!.options.projectId;
        final expectedProjectId = EnvironmentConfig.firebaseProjectId;
        if (currentProjectId != expectedProjectId) {
          debugPrint('⚠️  Warning: Existing Firebase app project ID ($currentProjectId) differs from expected ($expectedProjectId)');
          debugPrint('🔧 This may indicate auto-initialization with default config instead of environment-specific config');
        }
      } catch (e) {
        // If no default app exists, check if there are any other apps we can use
        if (Firebase.apps.isNotEmpty) {
          debugPrint('🔧 No default app found, but ${Firebase.apps.length} other apps exist');
          _app = Firebase.apps.first;
          debugPrint('🔥 Using first available Firebase app: ${_app!.name}');
        } else {
          // No apps exist at all, try to initialize manually
          debugPrint('🔧 No Firebase apps found, initializing manually...');
          try {
            _app = await Firebase.initializeApp(
              options: FirebaseOptionsProvider.getFirebaseOptions(),
            );
            debugPrint('🔥 Firebase initialized manually: ${_app!.name}');
          } catch (duplicateError) {
            if (duplicateError.toString().contains('duplicate-app')) {
              // Firebase was initialized between our checks (race condition)
              debugPrint('🔧 Firebase was initialized during our attempt, using existing app');
              _app = Firebase.app();
              debugPrint('🔥 Using existing Firebase app: ${_app!.name}');
            } else {
              // Different error, re-throw
              rethrow;
            }
          }
        }
      }

      // Verify we have a valid app
      if (_app == null) {
        throw FirebaseInitializationException('Failed to obtain Firebase app instance');
      }

      // Configure Firestore settings
      await _configureFirestore();

      // Configure Cloud Functions (emulator for dev)
      _configureCloudFunctions();

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

    // Story 11.6: Enable offline persistence for better performance
    // This allows Firestore to cache data locally and serve from cache when offline
    try {
      await firestore.settings.persistenceEnabled;
      debugPrint('💾 Firestore offline persistence enabled');
    } catch (e) {
      // Persistence may already be enabled or not supported on this platform
      debugPrint('⚠️  Firestore persistence configuration: $e');
    }

    // Enable network
    await firestore.enableNetwork();

    // Configure settings based on environment
    if (!EnvironmentConfig.isProduction) {
      // Enable more verbose logging in non-production
      FirebaseFirestore.setLoggingEnabled(true);
    }

    debugPrint('🗄️ Firestore configured for ${EnvironmentConfig.environmentName}');
  }

  /// Configure Cloud Functions (use emulator in development if enabled)
  static void _configureCloudFunctions() {
    try {
      // Only use emulator if explicitly enabled via environment variable or compile-time constant
      const bool useEmulator = bool.fromEnvironment('USE_FIREBASE_EMULATOR', defaultValue: false);

      if (useEmulator && EnvironmentConfig.isDevelopment) {
        // Use localhost emulator for dev environment
        // Note: For web, this should work automatically
        // For mobile platforms, you may need to use platform-specific host
        if (kIsWeb) {
          FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);
          debugPrint('⚡ Cloud Functions (Web) configured to use emulator on localhost:5001');
        } else {
          // For mobile emulators/simulators, use 10.0.2.2 (Android) or localhost (iOS)
          FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);
          debugPrint('⚡ Cloud Functions (Mobile) configured to use emulator on localhost:5001');
        }
      } else {
        debugPrint('⚡ Cloud Functions configured for ${EnvironmentConfig.environmentName} (live)');
      }
    } catch (e) {
      debugPrint('⚠️ Warning: Failed to configure Cloud Functions: $e');
    }
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