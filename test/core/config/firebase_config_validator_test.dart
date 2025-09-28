import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/core/config/firebase_config_validator.dart';

void main() {
  group('FirebaseConfigValidator', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('firebase_config_test');
    });

    tearDown(() async {
      await tempDir.delete(recursive: true);
    });

    group('validateAndroidConfig', () {
      test('should validate correct Android configuration', () async {
        // Create a valid Android config
        final configFile = File('${tempDir.path}/google-services.json');
        final validConfig = {
          'project_info': {
            'project_id': 'playwithme-dev',
            'project_number': '123456789',
            'storage_bucket': 'playwithme-dev.firebasestorage.app',
          },
          'client': [
            {
              'client_info': {
                'mobilesdk_app_id': '1:123456789:android:abcdef123456',
                'android_client_info': {
                  'package_name': 'com.playwithme.play_with_me.dev',
                }
              },
              'api_key': [
                {
                  'current_key': 'AIzaSyRealApiKeyWithoutPlaceholder123456',
                }
              ]
            }
          ]
        };

        await configFile.writeAsString(jsonEncode(validConfig));

        final result = await FirebaseConfigValidator.validateAndroidConfig(
          'dev',
          configFile.path,
        );

        expect(result.isValid, isTrue);
        expect(result.errors, isEmpty);
        expect(result.warnings, isEmpty);
      });

      test('should detect project ID mismatch', () async {
        final configFile = File('${tempDir.path}/google-services.json');
        final invalidConfig = {
          'project_info': {
            'project_id': 'wrong-project-id',
          },
          'client': [
            {
              'client_info': {
                'android_client_info': {
                  'package_name': 'com.playwithme.play_with_me.dev',
                }
              },
              'api_key': [
                {'current_key': 'real-key'}
              ]
            }
          ]
        };

        await configFile.writeAsString(jsonEncode(invalidConfig));

        final result = await FirebaseConfigValidator.validateAndroidConfig(
          'dev',
          configFile.path,
        );

        expect(result.isValid, isFalse);
        expect(result.errors, contains(contains('Project ID mismatch')));
      });

      test('should detect bundle ID mismatch', () async {
        final configFile = File('${tempDir.path}/google-services.json');
        final invalidConfig = {
          'project_info': {
            'project_id': 'playwithme-dev',
          },
          'client': [
            {
              'client_info': {
                'android_client_info': {
                  'package_name': 'com.wrong.bundle.id',
                }
              },
              'api_key': [
                {'current_key': 'real-key'}
              ]
            }
          ]
        };

        await configFile.writeAsString(jsonEncode(invalidConfig));

        final result = await FirebaseConfigValidator.validateAndroidConfig(
          'dev',
          configFile.path,
        );

        expect(result.isValid, isFalse);
        expect(result.errors, contains(contains('Bundle ID mismatch')));
      });

      test('should detect placeholder API keys', () async {
        final configFile = File('${tempDir.path}/google-services.json');
        final configWithPlaceholder = {
          'project_info': {
            'project_id': 'playwithme-dev',
          },
          'client': [
            {
              'client_info': {
                'android_client_info': {
                  'package_name': 'com.playwithme.play_with_me.dev',
                }
              },
              'api_key': [
                {'current_key': 'AIzaSyDEV-placeholder-key-for-development'}
              ]
            }
          ]
        };

        await configFile.writeAsString(jsonEncode(configWithPlaceholder));

        final result = await FirebaseConfigValidator.validateAndroidConfig(
          'dev',
          configFile.path,
        );

        expect(result.isValid, isTrue); // Valid structure but has warnings
        expect(result.warnings, contains(contains('API key appears to be a placeholder')));
      });

      test('should handle missing config file', () async {
        final result = await FirebaseConfigValidator.validateAndroidConfig(
          'dev',
          '${tempDir.path}/nonexistent.json',
        );

        expect(result.isValid, isFalse);
        expect(result.errors, contains(contains('Config file not found')));
      });

      test('should handle invalid JSON', () async {
        final configFile = File('${tempDir.path}/invalid.json');
        await configFile.writeAsString('invalid json content');

        final result = await FirebaseConfigValidator.validateAndroidConfig(
          'dev',
          configFile.path,
        );

        expect(result.isValid, isFalse);
        expect(result.errors, contains(contains('Error parsing config file')));
      });
    });

    group('validateiOSConfig', () {
      test('should validate correct iOS configuration', () async {
        final configFile = File('${tempDir.path}/GoogleService-Info.plist');
        const validPlist = '''<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>API_KEY</key>
	<string>AIzaSyRealApiKeyWithoutPlaceholder123456</string>
	<key>PROJECT_ID</key>
	<string>playwithme-dev</string>
	<key>BUNDLE_ID</key>
	<string>com.playwithme.playWithMe.dev</string>
</dict>
</plist>''';

        await configFile.writeAsString(validPlist);

        final result = await FirebaseConfigValidator.validateiOSConfig(
          'dev',
          configFile.path,
        );

        expect(result.isValid, isTrue);
        expect(result.errors, isEmpty);
        expect(result.warnings, isEmpty);
      });

      test('should detect project ID mismatch in iOS config', () async {
        final configFile = File('${tempDir.path}/GoogleService-Info.plist');
        const invalidPlist = '''<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
	<key>PROJECT_ID</key>
	<string>wrong-project-id</string>
	<key>BUNDLE_ID</key>
	<string>com.playwithme.playWithMe.dev</string>
	<key>API_KEY</key>
	<string>real-key</string>
</dict>
</plist>''';

        await configFile.writeAsString(invalidPlist);

        final result = await FirebaseConfigValidator.validateiOSConfig(
          'dev',
          configFile.path,
        );

        expect(result.isValid, isFalse);
        expect(result.errors, contains(contains('Project ID mismatch')));
      });

      test('should detect bundle ID mismatch in iOS config', () async {
        final configFile = File('${tempDir.path}/GoogleService-Info.plist');
        const invalidPlist = '''<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
	<key>PROJECT_ID</key>
	<string>playwithme-dev</string>
	<key>BUNDLE_ID</key>
	<string>com.wrong.bundle.id</string>
	<key>API_KEY</key>
	<string>real-key</string>
</dict>
</plist>''';

        await configFile.writeAsString(invalidPlist);

        final result = await FirebaseConfigValidator.validateiOSConfig(
          'dev',
          configFile.path,
        );

        expect(result.isValid, isFalse);
        expect(result.errors, contains(contains('Bundle ID mismatch')));
      });

      test('should detect placeholder API keys in iOS config', () async {
        final configFile = File('${tempDir.path}/GoogleService-Info.plist');
        const placeholderPlist = '''<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
	<key>PROJECT_ID</key>
	<string>playwithme-dev</string>
	<key>BUNDLE_ID</key>
	<string>com.playwithme.playWithMe.dev</string>
	<key>API_KEY</key>
	<string>AIzaSyDEV-placeholder-key-for-development-ios</string>
</dict>
</plist>''';

        await configFile.writeAsString(placeholderPlist);

        final result = await FirebaseConfigValidator.validateiOSConfig(
          'dev',
          configFile.path,
        );

        expect(result.isValid, isTrue); // Valid structure but has warnings
        expect(result.warnings, contains(contains('API key appears to be a placeholder')));
      });
    });

    group('Expected Constants', () {
      test('should have correct expected bundle IDs for Android', () {
        expect(FirebaseConfigValidator.expectedAndroidBundleIds['dev'], 'com.playwithme.play_with_me.dev');
        expect(FirebaseConfigValidator.expectedAndroidBundleIds['stg'], 'com.playwithme.play_with_me.stg');
        expect(FirebaseConfigValidator.expectedAndroidBundleIds['prod'], 'com.playwithme.play_with_me');
      });

      test('should have correct expected bundle IDs for iOS', () {
        expect(FirebaseConfigValidator.expectediOSBundleIds['dev'], 'com.playwithme.playWithMe.dev');
        expect(FirebaseConfigValidator.expectediOSBundleIds['stg'], 'com.playwithme.playWithMe.stg');
        expect(FirebaseConfigValidator.expectediOSBundleIds['prod'], 'com.playwithme.playWithMe');
      });

      test('should have correct expected project IDs', () {
        expect(FirebaseConfigValidator.expectedProjectIds['dev'], 'playwithme-dev');
        expect(FirebaseConfigValidator.expectedProjectIds['stg'], 'playwithme-stg');
        expect(FirebaseConfigValidator.expectedProjectIds['prod'], 'playwithme-prod');
      });
    });

    group('ConfigValidationResult', () {
      test('should correctly identify when it has warnings', () {
        final resultWithWarnings = ConfigValidationResult(
          isValid: true,
          warnings: ['Some warning'],
        );

        final resultWithoutWarnings = ConfigValidationResult(
          isValid: true,
        );

        expect(resultWithWarnings.hasWarnings, isTrue);
        expect(resultWithoutWarnings.hasWarnings, isFalse);
      });
    });
  });
}