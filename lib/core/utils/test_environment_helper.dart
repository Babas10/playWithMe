// Environment detection helper for test execution control
class TestEnvironmentHelper {
  /// Check if tests are running in CI environment
  static bool get isCI {
    return const bool.fromEnvironment('CI', defaultValue: false) ||
           _hasGitHubActionsEnv() ||
           _hasCIEnvVar();
  }

  /// Check if tests are running locally (not in CI)
  static bool get isLocal => !isCI;

  /// Skip condition for Firebase integration tests that require live Firebase
  /// - Skips locally (faster development, no Firebase dependency)
  /// - Runs in CI (ensures production compatibility)
  static bool get skipFirebaseIntegrationLocally => isLocal;

  /// Skip condition for tests that should only run in CI
  static bool get skipCIOnlyTests => isLocal;

  /// Check for GitHub Actions environment variables
  static bool _hasGitHubActionsEnv() {
    return const String.fromEnvironment('GITHUB_ACTIONS') == 'true';
  }

  /// Check for common CI environment variables
  static bool _hasCIEnvVar() {
    // Check common CI environment variable names
    return const String.fromEnvironment('CONTINUOUS_INTEGRATION').isNotEmpty ||
           const String.fromEnvironment('GITLAB_CI').isNotEmpty ||
           const String.fromEnvironment('JENKINS_URL').isNotEmpty ||
           const String.fromEnvironment('BUILDKITE').isNotEmpty ||
           const String.fromEnvironment('CIRCLECI').isNotEmpty;
  }

  /// Get a descriptive message for why a test is being skipped
  static String getSkipMessage({
    required String testName,
    required String reason,
  }) {
    if (isCI) {
      return '$testName: Running in CI - $reason';
    } else {
      return '$testName: Skipped locally - $reason. Enable in CI for full validation.';
    }
  }
}