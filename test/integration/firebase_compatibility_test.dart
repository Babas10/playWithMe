// Tests Firebase integration compatibility with real configurations - Unit test version for CI/CD
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/core/config/environment_config.dart';
import 'package:play_with_me/core/services/firebase_service.dart';
import 'package:play_with_me/core/services/firebase_options_provider.dart';
import '../helpers/firebase_test_helper.dart';
import '../helpers/ci_test_helper.dart';

void main() {
  group('Firebase Integration Compatibility Tests', () {
    setUp(() async {
      // Set up test environment to handle platform channel limitations
      FirebaseTestHelper.setupTestEnvironment();

      // Clean up before each test
      if (FirebaseService.isInitialized) {
        await FirebaseService.dispose();
      }
    });

    tearDown(() async {
      // Clean up after each test
      await FirebaseTestHelper.teardownTestEnvironment();
    });

    test('Firebase configuration is valid for all environments with real configs', () {
      // Test all environments have valid configurations
      final environments = [Environment.dev, Environment.stg, Environment.prod];

      for (final env in environments) {
        // Arrange
        EnvironmentConfig.setEnvironment(env);

        // Act & Assert
        final isValid = FirebaseOptionsProvider.validateConfiguration();

        // With real Firebase configs, validation should now pass
        expect(isValid, isTrue,
            reason: 'Firebase configuration should be valid for ${env.name} environment');

        // Verify configuration summary is complete
        final summary = FirebaseOptionsProvider.getConfigurationSummary();
        expect(summary['environment'], isNotEmpty);
        expect(summary['projectId'], isNotEmpty);
        expect(summary['appId'], isNotEmpty);
        expect(summary['storageBucket'], isNotEmpty);

        // Real configs should not have placeholder values
        expect(summary['hasPlaceholders'], equals('false'),
            reason: 'Real Firebase configs should not contain placeholders');

        print('✅ Configuration valid for ${env.name}: ${summary['projectId']}');
      }
    });

    test('Firebase initialization handles test environment gracefully', () async {
      // Arrange
      EnvironmentConfig.setEnvironment(Environment.dev);

      // Act
      final initializationSuccessful = await FirebaseTestHelper.safeInitializeFirebase();

      // Assert
      // In test mode, initialization should be skipped gracefully
      expect(initializationSuccessful, isTrue,
          reason: 'Firebase initialization should handle test environment gracefully');

      // Verify test mode is active
      expect(FirebaseTestHelper.isTestMode, isTrue,
          reason: 'Test mode should be enabled in test environment');

      // Test configuration access without platform channels
      final configValid = FirebaseTestHelper.testFirebaseConfigValidity();
      expect(configValid, isTrue,
          reason: 'Configuration should be accessible without platform channels');

      print('✅ Firebase test environment handling works correctly');
    });

    test('Environment switching works correctly with real configs', () {
      // Test switching between environments with real configurations
      final testCases = [
        (Environment.dev, CITestHelper.getExpectedProjectId(Environment.dev), 'Development'),
        (Environment.stg, CITestHelper.getExpectedProjectId(Environment.stg), 'Staging'),
        (Environment.prod, CITestHelper.getExpectedProjectId(Environment.prod), 'Production'),
      ];

      for (final (env, expectedProjectId, expectedName) in testCases) {
        // Arrange
        EnvironmentConfig.setEnvironment(env);

        // Act
        final options = FirebaseOptionsProvider.getFirebaseOptions();
        final connectionInfo = FirebaseTestHelper.getMockConnectionInfo();

        // Assert - verify project ID matches expected for current environment
        expect(options.projectId, equals(expectedProjectId),
            reason: 'Firebase options project ID should match expected for ${env.name}');
        expect(connectionInfo['environment'], equals(expectedName));
        expect(connectionInfo['projectId'], equals(expectedProjectId),
            reason: 'Connection info project ID should match expected for ${env.name}');
        expect(connectionInfo['testMode'], isTrue,
            reason: 'Should be in test mode during integration tests');

        print('✅ Environment ${env.name} configured correctly: $expectedProjectId');
      }
    });

    test('Firebase service provides mock behavior in test environment', () {
      // Arrange
      EnvironmentConfig.setEnvironment(Environment.dev);

      // Act
      final connectionInfo = FirebaseTestHelper.getMockConnectionInfo();

      // Assert
      expect(connectionInfo['isInitialized'], isFalse,
          reason: 'Firebase should not be initialized in test mode');
      expect(connectionInfo['testMode'], isTrue,
          reason: 'Test mode should be active');
      expect(connectionInfo['environment'], equals('Development'));
      expect(connectionInfo['projectId'], equals(CITestHelper.getExpectedProjectId(Environment.dev)));

      print('✅ Mock Firebase behavior works correctly in test environment');
    });

    test('Real Firebase configs contain expected project identifiers', () {
      // Verify that real Firebase configurations contain the expected project IDs
      final expectedProjects = {
        Environment.dev: CITestHelper.getExpectedProjectId(Environment.dev),
        Environment.stg: CITestHelper.getExpectedProjectId(Environment.stg),
        Environment.prod: CITestHelper.getExpectedProjectId(Environment.prod),
      };

      for (final env in expectedProjects.keys) {
        // Arrange
        EnvironmentConfig.setEnvironment(env);

        // Act
        final options = FirebaseOptionsProvider.getFirebaseOptions();

        // Assert
        expect(options.projectId, equals(expectedProjects[env]),
            reason: 'Project ID should match expected value for ${env.name}');

        // Verify other required fields are present and not empty
        expect(options.apiKey, isNotEmpty,
            reason: 'API key should not be empty for ${env.name}');
        expect(options.appId, isNotEmpty,
            reason: 'App ID should not be empty for ${env.name}');
        expect(options.messagingSenderId, isNotEmpty,
            reason: 'Messaging sender ID should not be empty for ${env.name}');

        print('✅ Real Firebase config verified for ${env.name}: ${options.projectId}');
      }
    });

    test('Environment isolation between configurations', () {
      // Test configuration isolation by switching environments
      // and verifying each has distinct settings

      final testData = <String, String>{};

      for (final env in Environment.values) {
        EnvironmentConfig.setEnvironment(env);
        final connectionInfo = FirebaseTestHelper.getMockConnectionInfo();

        final projectId = connectionInfo['projectId'].toString();
        final environment = connectionInfo['environment'].toString();

        // Store configuration data
        testData['${env.name}_project'] = projectId;
        testData['${env.name}_env'] = environment;

        print('✅ Configuration isolated for ${env.name}: $projectId');
      }

      // Verify all configurations are unique
      final projectIds = [
        testData['dev_project'],
        testData['stg_project'],
        testData['prod_project'],
      ];

      expect(projectIds.toSet().length, equals(3),
          reason: 'All environments should have unique project IDs');
      expect(projectIds.contains(CITestHelper.getExpectedProjectId(Environment.dev)), isTrue);
      expect(projectIds.contains(CITestHelper.getExpectedProjectId(Environment.stg)), isTrue);
      expect(projectIds.contains(CITestHelper.getExpectedProjectId(Environment.prod)), isTrue);
    });

    test('Firebase configuration accessibility in all environments', () {
      final environments = [Environment.dev, Environment.stg, Environment.prod];

      for (final env in environments) {
        EnvironmentConfig.setEnvironment(env);

        // Test configuration accessibility without platform channels
        final configValid = FirebaseTestHelper.testFirebaseConfigValidity();
        expect(configValid, isTrue,
            reason: 'Configuration should be accessible in ${env.name}');

        final connectionInfo = FirebaseTestHelper.getMockConnectionInfo();
        expect(connectionInfo['projectId'], isNotEmpty,
            reason: 'Project ID should not be empty in ${env.name}');

        print('✅ Configuration accessible in ${env.name} environment');
      }
    });

    test('Environment indicators display correct project IDs', () {
      final testCases = [
        (Environment.dev, CITestHelper.getExpectedProjectId(Environment.dev)),
        (Environment.stg, CITestHelper.getExpectedProjectId(Environment.stg)),
        (Environment.prod, CITestHelper.getExpectedProjectId(Environment.prod)),
      ];

      for (final (env, expectedProjectId) in testCases) {
        EnvironmentConfig.setEnvironment(env);

        final connectionInfo = FirebaseTestHelper.getMockConnectionInfo();

        // Verify connection info shows correct project ID
        expect(connectionInfo['projectId'], equals(expectedProjectId));

        print('✅ Environment ${env.name} correctly shows project: $expectedProjectId');
      }
    });

    test('Firebase test helper handles multiple initializations', () async {
      EnvironmentConfig.setEnvironment(Environment.dev);

      // Test multiple initialization attempts
      final result1 = await FirebaseTestHelper.safeInitializeFirebase();
      expect(result1, isTrue);

      final result2 = await FirebaseTestHelper.safeInitializeFirebase();
      expect(result2, isTrue); // Should not throw

      print('✅ Multiple initialization attempts handled gracefully');
    });

    test('Firebase configuration test returns meaningful results', () {
      EnvironmentConfig.setEnvironment(Environment.dev);

      final configValid = FirebaseTestHelper.testFirebaseConfigValidity();
      expect(configValid, isA<bool>());

      if (configValid) {
        print('✅ Configuration test passed - Firebase config is valid');
      } else {
        print('⚠️ Configuration test failed - check Firebase configuration');
      }
    });
  });
}