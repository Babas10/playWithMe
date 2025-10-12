import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/core/config/environment_config.dart';
import 'package:play_with_me/core/services/firebase_service.dart';

void main() {
  group('FirebaseService', () {
    setUp(() {
      // Reset Firebase state before each test
      if (FirebaseService.isInitialized) {
        FirebaseService.dispose();
      }
    });

    tearDown(() {
      // Clean up after each test
      if (FirebaseService.isInitialized) {
        FirebaseService.dispose();
      }
      // Reset to default environment
      EnvironmentConfig.setEnvironment(Environment.prod);
    });

    group('initialization', () {
      test('isInitialized returns false initially', () {
        expect(FirebaseService.isInitialized, isFalse);
      });

      test('app returns null when not initialized', () {
        expect(FirebaseService.app, isNull);
      });

      test('throws StateError when accessing firestore before initialization', () {
        expect(
          () => FirebaseService.firestore,
          throwsA(isA<StateError>()),
        );
      });

      test('throws StateError when accessing auth before initialization', () {
        expect(
          () => FirebaseService.auth,
          throwsA(isA<StateError>()),
        );
      });

      // Note: We can't actually test Firebase initialization in unit tests
      // without mocking Firebase, which is complex. This would be covered
      // in integration tests instead.
    });

    group('getConnectionInfo', () {
      test('returns correct information when not initialized', () {
        // Arrange
        EnvironmentConfig.setEnvironment(Environment.dev);

        // Act
        final info = FirebaseService.getConnectionInfo();

        // Assert
        expect(info['isInitialized'], isFalse);
        expect(info['environment'], equals('Development'));
        expect(info['projectId'], equals('playwithme-dev'));
        expect(info['appName'], isNull);
      });

      test('returns correct environment information for staging', () {
        // Arrange
        EnvironmentConfig.setEnvironment(Environment.stg);

        // Act
        final info = FirebaseService.getConnectionInfo();

        // Assert
        expect(info['environment'], equals('Staging'));
        expect(info['projectId'], equals('playwithme-stg'));
      });

      test('returns correct environment information for production', () {
        // Arrange
        EnvironmentConfig.setEnvironment(Environment.prod);

        // Act
        final info = FirebaseService.getConnectionInfo();

        // Assert
        expect(info['environment'], equals('Production'));
        expect(info['projectId'], equals('playwithme-prod'));
      });
    });

    group('testConnection', () {
      test('returns false when not initialized', () async {
        // Act
        final result = await FirebaseService.testConnection();

        // Assert
        expect(result, isFalse);
      });
    });

    group('dispose', () {
      test('sets isInitialized to false after dispose', () async {
        // Act
        await FirebaseService.dispose();

        // Assert
        expect(FirebaseService.isInitialized, isFalse);
        expect(FirebaseService.app, isNull);
      });
    });

    group('FirebaseInitializationException', () {
      test('creates exception with message', () {
        // Arrange
        const message = 'Test error message';

        // Act
        const exception = FirebaseInitializationException(message);

        // Assert
        expect(exception.message, equals(message));
        expect(exception.originalException, isNull);
        expect(exception.toString(), contains(message));
      });

      test('creates exception with message and original exception', () {
        // Arrange
        const message = 'Test error message';
        final originalError = Exception('Original error');

        // Act
        final exception = FirebaseInitializationException(
          message,
          originalException: originalError,
        );

        // Assert
        expect(exception.message, equals(message));
        expect(exception.originalException, equals(originalError));
        expect(exception.toString(), contains(message));
      });
    });

    group('environment consistency', () {
      test('connection info reflects current environment configuration', () {
        final environments = [
          (Environment.dev, 'Development', 'playwithme-dev'),
          (Environment.stg, 'Staging', 'playwithme-stg'),
          (Environment.prod, 'Production', 'playwithme-prod'),
        ];

        for (final (env, expectedName, expectedProjectId) in environments) {
          // Arrange
          EnvironmentConfig.setEnvironment(env);

          // Act
          final info = FirebaseService.getConnectionInfo();

          // Assert
          expect(info['environment'], equals(expectedName));
          expect(info['projectId'], equals(expectedProjectId));
        }
      });
    });
  });
}