// Test helper for handling CI vs local environment differences
import 'dart:io';
import 'package:play_with_me/core/config/environment_config.dart';
import 'package:play_with_me/core/services/firebase_options_provider.dart';

/// Helper class for tests that need to adapt to CI vs local environments
class CITestHelper {
  static bool? _isCIEnvironment;

  /// Detects if we're running in a CI environment
  static bool get isCIEnvironment {
    _isCIEnvironment ??= _detectCIEnvironment();
    return _isCIEnvironment!;
  }

  /// Reset CI detection for testing
  static void resetCIDetection() {
    _isCIEnvironment = null;
  }

  /// Get expected project ID for the given environment
  /// - Both CI and local now use real Firebase project IDs
  static String getExpectedProjectId(Environment environment) {
    // Real project IDs used in both CI and local environments
    switch (environment) {
      case Environment.dev:
        return 'playwithme-dev';
      case Environment.stg:
        return 'playwithme-stg';
      case Environment.prod:
        return 'playwithme-prod';
    }
  }

  /// Get expected storage bucket for the given environment
  static String getExpectedStorageBucket(Environment environment) {
    final projectId = getExpectedProjectId(environment);
    return '$projectId.firebasestorage.app';
  }

  /// Get expected auth domain for the given environment
  static String getExpectedAuthDomain(Environment environment) {
    final projectId = getExpectedProjectId(environment);
    return '$projectId.firebaseapp.com';
  }

  /// Get expected project IDs map for all environments
  static Map<String, String> getExpectedProjectIds() {
    return {
      'dev': getExpectedProjectId(Environment.dev),
      'stg': getExpectedProjectId(Environment.stg),
      'prod': getExpectedProjectId(Environment.prod),
    };
  }

  /// Get the actual project ID from the current Firebase configuration
  static String getActualProjectId(Environment environment) {
    EnvironmentConfig.setEnvironment(environment);
    final options = FirebaseOptionsProvider.getFirebaseOptions();
    return options.projectId;
  }

  /// Verify that the current configuration matches expected values
  static bool isConfigurationCorrect(Environment environment) {
    final expectedProjectId = getExpectedProjectId(environment);
    final actualProjectId = getActualProjectId(environment);
    return expectedProjectId == actualProjectId;
  }

  /// Private method to detect CI environment
  static bool _detectCIEnvironment() {
    // Check common CI environment variables
    final ciIndicators = [
      'CI',                    // Generic CI indicator
      'GITHUB_ACTIONS',        // GitHub Actions
      'GITLAB_CI',             // GitLab CI
      'TRAVIS',                // Travis CI
      'CIRCLECI',              // CircleCI
      'JENKINS_URL',           // Jenkins
      'BUILDKITE',             // Buildkite
      'TF_BUILD',              // Azure DevOps
    ];

    // Check if any CI indicator is present
    for (final indicator in ciIndicators) {
      if (Platform.environment.containsKey(indicator)) {
        return true;
      }
    }

    // Additional check: if Firebase service account is configured, we're likely in CI
    try {
      if (Platform.environment.containsKey('GOOGLE_APPLICATION_CREDENTIALS')) {
        return true;
      }
    } catch (e) {
      // If environment check fails, fall back to other indicators
    }

    return false;
  }

  /// Get environment description for logging/debugging
  static String getEnvironmentDescription() {
    if (isCIEnvironment) {
      return 'CI Environment (using real Firebase configs)';
    } else {
      return 'Local Environment (using real Firebase configs)';
    }
  }
}