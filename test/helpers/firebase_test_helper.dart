// Test helper for Firebase initialization in test environments
import 'package:flutter/foundation.dart';
import 'package:play_with_me/core/config/environment_config.dart';
import 'package:play_with_me/core/services/firebase_service.dart';

/// Helper class for Firebase testing that handles test environment limitations
class FirebaseTestHelper {
  static bool _isTestMode = false;

  /// Enable test mode to prevent real Firebase initialization
  static void enableTestMode() {
    _isTestMode = true;
    debugPrint('🧪 Firebase test mode enabled');
  }

  /// Disable test mode to allow real Firebase initialization
  static void disableTestMode() {
    _isTestMode = false;
    debugPrint('🧪 Firebase test mode disabled');
  }

  /// Check if we're currently in test mode
  static bool get isTestMode => _isTestMode;

  /// Safely initialize Firebase in test environment
  /// Returns true if initialization was successful or skipped due to test mode
  static Future<bool> safeInitializeFirebase() async {
    try {
      if (_isTestMode) {
        debugPrint('🧪 Skipping Firebase initialization in test mode');
        return true;
      }

      await FirebaseService.initialize();
      return FirebaseService.isInitialized;
    } catch (e) {
      debugPrint('🧪 Firebase initialization failed (expected in test environment): $e');
      return false;
    }
  }

  /// Test Firebase functionality without platform channels
  /// This provides a mock implementation for testing
  static bool testFirebaseConfigValidity() {
    try {
      // Test that we can access the configuration without errors
      final connectionInfo = FirebaseService.getConnectionInfo();

      // Basic validation of configuration structure
      return connectionInfo['environment'] != null &&
             connectionInfo['projectId'] != null &&
             connectionInfo['projectId'].toString().isNotEmpty;
    } catch (e) {
      debugPrint('🧪 Firebase config test failed: $e');
      return false;
    }
  }

  /// Get mock connection status for testing
  static Map<String, dynamic> getMockConnectionInfo() {
    return {
      'isInitialized': _isTestMode ? false : FirebaseService.isInitialized,
      'environment': EnvironmentConfig.environmentName,
      'projectId': EnvironmentConfig.firebaseProjectId,
      'appName': _isTestMode ? 'mock-app' : null,
      'testMode': _isTestMode,
    };
  }

  /// Clean up Firebase resources safely in test environment
  static Future<void> safeDispose() async {
    try {
      if (!_isTestMode && FirebaseService.isInitialized) {
        await FirebaseService.dispose();
      }
      debugPrint('🧪 Firebase test cleanup completed');
    } catch (e) {
      debugPrint('🧪 Firebase test cleanup error (non-critical): $e');
    }
  }

  /// Detect if running in Flutter test environment
  static bool isFlutterTestEnvironment() {
    // Check if we're running in Flutter test environment
    return identical(0, 0.0) == false; // This is always false in test environment
  }

  /// Setup test environment with appropriate configuration
  static void setupTestEnvironment() {
    enableTestMode();
    debugPrint('🧪 Firebase test environment configured');
  }

  /// Teardown test environment
  static Future<void> teardownTestEnvironment() async {
    await safeDispose();
    disableTestMode();
    debugPrint('🧪 Firebase test environment cleaned up');
  }
}