// Tests Firebase test helper functionality and ensures it works correctly
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/core/config/environment_config.dart';
import 'firebase_test_helper.dart';

void main() {
  group('FirebaseTestHelper', () {
    setUp(() {
      // Reset state before each test
      FirebaseTestHelper.disableTestMode();
    });

    tearDown(() {
      // Clean up after each test
      FirebaseTestHelper.disableTestMode();
    });

    test('enables and disables test mode correctly', () {
      // Initially disabled
      expect(FirebaseTestHelper.isTestMode, isFalse);

      // Enable test mode
      FirebaseTestHelper.enableTestMode();
      expect(FirebaseTestHelper.isTestMode, isTrue);

      // Disable test mode
      FirebaseTestHelper.disableTestMode();
      expect(FirebaseTestHelper.isTestMode, isFalse);
    });

    test('safeInitializeFirebase returns true in test mode', () async {
      // Arrange
      FirebaseTestHelper.enableTestMode();

      // Act
      final result = await FirebaseTestHelper.safeInitializeFirebase();

      // Assert
      expect(result, isTrue);
    });

    test('testFirebaseConfigValidity works for all environments', () {
      // Test all environments
      final environments = [Environment.dev, Environment.stg, Environment.prod];

      for (final env in environments) {
        // Arrange
        EnvironmentConfig.setEnvironment(env);

        // Act
        final isValid = FirebaseTestHelper.testFirebaseConfigValidity();

        // Assert
        expect(isValid, isTrue,
            reason: 'Configuration should be valid for ${env.name}');
      }
    });

    test('getMockConnectionInfo returns correct structure', () {
      // Arrange
      FirebaseTestHelper.enableTestMode();
      EnvironmentConfig.setEnvironment(Environment.dev);

      // Act
      final connectionInfo = FirebaseTestHelper.getMockConnectionInfo();

      // Assert
      expect(connectionInfo, isA<Map<String, dynamic>>());
      expect(connectionInfo['isInitialized'], isFalse);
      expect(connectionInfo['environment'], equals('Development'));
      expect(connectionInfo['projectId'], equals('playwithme-dev'));
      expect(connectionInfo['testMode'], isTrue);
    });

    test('getMockConnectionInfo reflects different environments', () {
      FirebaseTestHelper.enableTestMode();

      final testCases = [
        (Environment.dev, 'Development', 'playwithme-dev'),
        (Environment.stg, 'Staging', 'playwithme-stg'),
        (Environment.prod, 'Production', 'playwithme-prod'),
      ];

      for (final (env, expectedEnvName, expectedProjectId) in testCases) {
        // Arrange
        EnvironmentConfig.setEnvironment(env);

        // Act
        final connectionInfo = FirebaseTestHelper.getMockConnectionInfo();

        // Assert
        expect(connectionInfo['environment'], equals(expectedEnvName));
        expect(connectionInfo['projectId'], equals(expectedProjectId));
        expect(connectionInfo['testMode'], isTrue);
      }
    });

    test('setupTestEnvironment configures correctly', () {
      // Act
      FirebaseTestHelper.setupTestEnvironment();

      // Assert
      expect(FirebaseTestHelper.isTestMode, isTrue);
    });

    test('teardownTestEnvironment cleans up correctly', () async {
      // Arrange
      FirebaseTestHelper.enableTestMode();

      // Act
      await FirebaseTestHelper.teardownTestEnvironment();

      // Assert
      expect(FirebaseTestHelper.isTestMode, isFalse);
    });

    test('safeDispose handles cleanup gracefully', () async {
      // This should not throw regardless of test mode state
      FirebaseTestHelper.enableTestMode();
      await expectLater(
        FirebaseTestHelper.safeDispose(),
        completes,
      );

      FirebaseTestHelper.disableTestMode();
      await expectLater(
        FirebaseTestHelper.safeDispose(),
        completes,
      );
    });
  });
}