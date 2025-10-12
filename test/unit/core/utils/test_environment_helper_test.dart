// Verifies TestEnvironmentHelper correctly detects CI vs local environments
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/core/utils/test_environment_helper.dart';

void main() {
  group('TestEnvironmentHelper', () {
    test('detects local environment by default', () {
      // In default test environment, should be detected as local
      expect(TestEnvironmentHelper.isLocal, isTrue);
      expect(TestEnvironmentHelper.isCI, isFalse);
    });

    test('provides correct skip conditions for local environment', () {
      // Firebase integration tests should be skipped locally
      expect(TestEnvironmentHelper.skipFirebaseIntegrationLocally, isTrue);
      expect(TestEnvironmentHelper.skipCIOnlyTests, isTrue);
    });

    test('generates appropriate skip messages for local environment', () {
      final message = TestEnvironmentHelper.getSkipMessage(
        testName: 'Firebase Integration Tests',
        reason: 'requires live Firebase configuration',
      );

      expect(message, contains('Skipped locally'));
      expect(message, contains('Firebase Integration Tests'));
      expect(message, contains('requires live Firebase configuration'));
      expect(message, contains('Enable in CI for full validation'));
    });

    test('skip message format is consistent', () {
      final message = TestEnvironmentHelper.getSkipMessage(
        testName: 'Test Name',
        reason: 'test reason',
      );

      // Should follow format: "Test Name: Skipped locally - test reason. Enable in CI for full validation."
      expect(message, startsWith('Test Name: Skipped locally - test reason'));
      expect(message, endsWith('Enable in CI for full validation.'));
    });
  });
}