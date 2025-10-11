import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/core/config/environment_config.dart';

void main() {
  group('EnvironmentConfig', () {
    tearDown(() {
      // Reset to default environment after each test
      EnvironmentConfig.setEnvironment(Environment.prod);
    });

    group('Environment Setting', () {
      test('should set and get development environment', () {
        EnvironmentConfig.setEnvironment(Environment.dev);

        expect(EnvironmentConfig.environment, Environment.dev);
        expect(EnvironmentConfig.isDevelopment, true);
        expect(EnvironmentConfig.isStaging, false);
        expect(EnvironmentConfig.isProduction, false);
      });

      test('should set and get staging environment', () {
        EnvironmentConfig.setEnvironment(Environment.stg);

        expect(EnvironmentConfig.environment, Environment.stg);
        expect(EnvironmentConfig.isDevelopment, false);
        expect(EnvironmentConfig.isStaging, true);
        expect(EnvironmentConfig.isProduction, false);
      });

      test('should set and get production environment', () {
        EnvironmentConfig.setEnvironment(Environment.prod);

        expect(EnvironmentConfig.environment, Environment.prod);
        expect(EnvironmentConfig.isDevelopment, false);
        expect(EnvironmentConfig.isStaging, false);
        expect(EnvironmentConfig.isProduction, true);
      });
    });

    group('Environment Names', () {
      test('should return correct environment name for development', () {
        EnvironmentConfig.setEnvironment(Environment.dev);
        expect(EnvironmentConfig.environmentName, 'Development');
      });

      test('should return correct environment name for staging', () {
        EnvironmentConfig.setEnvironment(Environment.stg);
        expect(EnvironmentConfig.environmentName, 'Staging');
      });

      test('should return correct environment name for production', () {
        EnvironmentConfig.setEnvironment(Environment.prod);
        expect(EnvironmentConfig.environmentName, 'Production');
      });
    });

    group('Firebase Project IDs', () {
      test('should return correct Firebase project ID for development', () {
        EnvironmentConfig.setEnvironment(Environment.dev);
        expect(EnvironmentConfig.firebaseProjectId, 'playwithme-dev');
      });

      test('should return correct Firebase project ID for staging', () {
        EnvironmentConfig.setEnvironment(Environment.stg);
        expect(EnvironmentConfig.firebaseProjectId, 'playwithme-stg');
      });

      test('should return correct Firebase project ID for production', () {
        EnvironmentConfig.setEnvironment(Environment.prod);
        expect(EnvironmentConfig.firebaseProjectId, 'playwithme-prod');
      });
    });

    group('App Suffixes', () {
      test('should return correct app suffix for development', () {
        EnvironmentConfig.setEnvironment(Environment.dev);
        expect(EnvironmentConfig.appSuffix, ' (Dev)');
      });

      test('should return correct app suffix for staging', () {
        EnvironmentConfig.setEnvironment(Environment.stg);
        expect(EnvironmentConfig.appSuffix, ' (Staging)');
      });

      test('should return empty app suffix for production', () {
        EnvironmentConfig.setEnvironment(Environment.prod);
        expect(EnvironmentConfig.appSuffix, '');
      });
    });

    group('Default Environment', () {
      test('should default to production environment', () {
        // Don't set any environment, should default to production
        expect(EnvironmentConfig.environment, Environment.prod);
        expect(EnvironmentConfig.isProduction, true);
        expect(EnvironmentConfig.environmentName, 'Production');
        expect(EnvironmentConfig.firebaseProjectId, 'playwithme-prod');
        expect(EnvironmentConfig.appSuffix, '');
      });
    });
  });
}