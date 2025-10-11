import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/core/config/environment_config.dart';
import 'package:play_with_me/core/services/firebase_options_provider.dart';
import '../helpers/ci_test_helper.dart';

void main() {
  group('FirebaseOptionsProvider',
    skip: !CITestHelper.isCIEnvironment
      ? 'CI-only tests - run only in GitHub Actions with real Firebase configs'
      : null, () {
    tearDown(() {
      // Reset to default environment after each test
      EnvironmentConfig.setEnvironment(Environment.prod);
    });

    group('getFirebaseOptions', () {
      test('returns dev options when environment is dev', () {
        // Arrange
        EnvironmentConfig.setEnvironment(Environment.dev);

        // Act
        final options = FirebaseOptionsProvider.getFirebaseOptions();

        // Assert
        expect(options.projectId, equals(CITestHelper.getExpectedProjectId(Environment.dev)));
        expect(options.storageBucket, equals(CITestHelper.getExpectedStorageBucket(Environment.dev)));
        expect(options.authDomain, equals(CITestHelper.getExpectedAuthDomain(Environment.dev)));
      });

      test('returns staging options when environment is stg', () {
        // Arrange
        EnvironmentConfig.setEnvironment(Environment.stg);

        // Act
        final options = FirebaseOptionsProvider.getFirebaseOptions();

        // Assert
        expect(options.projectId, equals(CITestHelper.getExpectedProjectId(Environment.stg)));
        expect(options.storageBucket, equals(CITestHelper.getExpectedStorageBucket(Environment.stg)));
        expect(options.authDomain, equals(CITestHelper.getExpectedAuthDomain(Environment.stg)));
      });

      test('returns prod options when environment is prod', () {
        // Arrange
        EnvironmentConfig.setEnvironment(Environment.prod);

        // Act
        final options = FirebaseOptionsProvider.getFirebaseOptions();

        // Assert
        expect(options.projectId, equals(CITestHelper.getExpectedProjectId(Environment.prod)));
        expect(options.storageBucket, equals(CITestHelper.getExpectedStorageBucket(Environment.prod)));
        expect(options.authDomain, equals(CITestHelper.getExpectedAuthDomain(Environment.prod)));
      });
    });

    group('validateConfiguration', () {
      test('returns true when configuration has valid values', () {
        // Arrange
        EnvironmentConfig.setEnvironment(Environment.dev);

        // Act
        final isValid = FirebaseOptionsProvider.validateConfiguration();

        // Assert
        expect(isValid, isTrue);
      });

      test('detects valid configuration values correctly', () {
        // Arrange
        EnvironmentConfig.setEnvironment(Environment.dev);

        // Act
        final options = FirebaseOptionsProvider.getFirebaseOptions();

        // Assert
        expect(options.apiKey.contains('placeholder'), isFalse);
        expect(options.appId.contains('placeholder'), isFalse);
        expect(options.messagingSenderId.contains('placeholder'), isFalse);
      });
    });

    group('getConfigurationSummary', () {
      test('returns correct summary for dev environment', () {
        // Arrange
        EnvironmentConfig.setEnvironment(Environment.dev);

        // Act
        final summary = FirebaseOptionsProvider.getConfigurationSummary();

        // Assert
        expect(summary['environment'], equals('Development'));
        expect(summary['projectId'], equals(CITestHelper.getExpectedProjectId(Environment.dev)));
        expect(summary['hasPlaceholders'], equals('false'));
        expect(summary['storageBucket'], equals(CITestHelper.getExpectedStorageBucket(Environment.dev)));
      });

      test('returns correct summary for staging environment', () {
        // Arrange
        EnvironmentConfig.setEnvironment(Environment.stg);

        // Act
        final summary = FirebaseOptionsProvider.getConfigurationSummary();

        // Assert
        expect(summary['environment'], equals('Staging'));
        expect(summary['projectId'], equals(CITestHelper.getExpectedProjectId(Environment.stg)));
        expect(summary['hasPlaceholders'], equals('false'));
        expect(summary['storageBucket'], equals(CITestHelper.getExpectedStorageBucket(Environment.stg)));
      });

      test('returns correct summary for production environment', () {
        // Arrange
        EnvironmentConfig.setEnvironment(Environment.prod);

        // Act
        final summary = FirebaseOptionsProvider.getConfigurationSummary();

        // Assert
        expect(summary['environment'], equals('Production'));
        expect(summary['projectId'], equals(CITestHelper.getExpectedProjectId(Environment.prod)));
        expect(summary['hasPlaceholders'], equals('false'));
        expect(summary['storageBucket'], equals(CITestHelper.getExpectedStorageBucket(Environment.prod)));
      });
    });

    group('Firebase options consistency', () {
      test('all environments have consistent structure', () {
        final environments = [Environment.dev, Environment.stg, Environment.prod];

        for (final env in environments) {
          EnvironmentConfig.setEnvironment(env);
          final options = FirebaseOptionsProvider.getFirebaseOptions();

          // Assert all required fields are present and not empty
          expect(options.projectId, isNotEmpty);
          expect(options.apiKey, isNotEmpty);
          expect(options.appId, isNotEmpty);
          expect(options.messagingSenderId, isNotEmpty);
          expect(options.storageBucket, isNotEmpty);
        }
      });

      test('each environment has unique project identifiers', () {
        // Get options for all environments
        EnvironmentConfig.setEnvironment(Environment.dev);
        final devOptions = FirebaseOptionsProvider.getFirebaseOptions();

        EnvironmentConfig.setEnvironment(Environment.stg);
        final stgOptions = FirebaseOptionsProvider.getFirebaseOptions();

        EnvironmentConfig.setEnvironment(Environment.prod);
        final prodOptions = FirebaseOptionsProvider.getFirebaseOptions();

        // Assert all project IDs are unique
        final projectIds = [
          devOptions.projectId,
          stgOptions.projectId,
          prodOptions.projectId,
        ];
        expect(projectIds.toSet().length, equals(3));
      });
    });
  });
}