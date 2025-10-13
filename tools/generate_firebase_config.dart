#!/usr/bin/env dart

import 'dart:convert';
import 'dart:io';

/// Generates Firebase configuration Dart files from downloaded Firebase config files.
/// This script reads the actual google-services.json and GoogleService-Info.plist files
/// and generates type-safe Dart configuration classes.
void main(List<String> arguments) {
  if (arguments.isEmpty) {
    print('Usage: dart tools/generate_firebase_config.dart <environment>');
    print('Example: dart tools/generate_firebase_config.dart dev');
    print('Available environments: dev, stg, prod');
    exit(1);
  }

  final environment = arguments[0];
  if (!['dev', 'stg', 'prod'].contains(environment)) {
    print('Error: Invalid environment "$environment"');
    print('Available environments: dev, stg, prod');
    exit(1);
  }

  print('🔥 Generating Firebase configuration for $environment environment...');

  try {
    final config = _generateFirebaseConfig(environment);
    _writeConfigFile(environment, config);
    print('✅ Successfully generated lib/core/config/firebase_config_$environment.dart');
  } catch (e) {
    print('❌ Error generating Firebase configuration: $e');
    exit(1);
  }
}

/// Generates Firebase configuration from actual config files
String _generateFirebaseConfig(String environment) {
  final androidConfig = _readAndroidConfig(environment);
  final iosConfig = _readIosConfig(environment);

  return '''
// GENERATED FILE - DO NOT EDIT MANUALLY
// Generated from Firebase config files for $environment environment
// Run: dart tools/generate_firebase_config.dart $environment

import 'firebase_config_base.dart';

class FirebaseConfig${_capitalize(environment)} extends FirebaseConfigBase {
  @override
  String get projectId => '${androidConfig['project_info']['project_id']}';

  @override
  String get storageBucket => '${androidConfig['project_info']['storage_bucket']}';

  @override
  String get androidAppId => '${androidConfig['client'][0]['client_info']['mobilesdk_app_id']}';

  @override
  String get iosAppId => '${iosConfig['GOOGLE_APP_ID']}';

  @override
  String get apiKey => '${androidConfig['client'][0]['api_key'][0]['current_key']}';

  @override
  String get messagingSenderId => '${androidConfig['project_info']['project_number']}';

  @override
  String get androidPackageName => '${androidConfig['client'][0]['client_info']['android_client_info']['package_name']}';

  @override
  String get iosBundleId => '${iosConfig['BUNDLE_ID']}';

  @override
  String get environment => '$environment';

  @override
  String get displayName => '${_getDisplayName(environment)}';
}
''';
}

/// Reads and parses Android google-services.json file
Map<String, dynamic> _readAndroidConfig(String environment) {
  final file = File('android/app/src/$environment/google-services.json');

  if (!file.existsSync()) {
    throw Exception(
      'Android Firebase config file not found: ${file.path}\n'
      'Please download google-services.json from Firebase Console and place it at this location.'
    );
  }

  try {
    final content = file.readAsStringSync();
    return json.decode(content) as Map<String, dynamic>;
  } catch (e) {
    throw Exception('Failed to parse Android Firebase config: $e');
  }
}

/// Reads and parses iOS GoogleService-Info.plist file
Map<String, dynamic> _readIosConfig(String environment) {
  final file = File('ios/Runner/Firebase/$environment/GoogleService-Info.plist');

  if (!file.existsSync()) {
    throw Exception(
      'iOS Firebase config file not found: ${file.path}\n'
      'Please download GoogleService-Info.plist from Firebase Console and place it at this location.'
    );
  }

  try {
    return _parsePlist(file);
  } catch (e) {
    throw Exception('Failed to parse iOS Firebase config: $e');
  }
}

/// Simple plist parser for GoogleService-Info.plist
Map<String, dynamic> _parsePlist(File file) {
  final content = file.readAsStringSync();
  final config = <String, dynamic>{};

  // Extract key-value pairs from plist
  final keyPattern = RegExp(r'<key>([^<]+)</key>\s*<string>([^<]*)</string>');
  final boolPattern = RegExp(r'<key>([^<]+)</key>\s*<(true|false)/?>');

  for (final match in keyPattern.allMatches(content)) {
    config[match.group(1)!] = match.group(2)!;
  }

  for (final match in boolPattern.allMatches(content)) {
    config[match.group(1)!] = match.group(2)! == 'true';
  }

  return config;
}

/// Writes the generated config file
void _writeConfigFile(String environment, String content) {
  final configDir = Directory('lib/core/config');
  if (!configDir.existsSync()) {
    configDir.createSync(recursive: true);
  }

  final file = File('lib/core/config/firebase_config_$environment.dart');
  file.writeAsStringSync(content);
}

/// Capitalizes first letter of string
String _capitalize(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1);
}

/// Gets display name for environment
String _getDisplayName(String environment) {
  switch (environment) {
    case 'dev':
      return 'PlayWithMe (Development)';
    case 'stg':
      return 'PlayWithMe (Staging)';
    case 'prod':
      return 'PlayWithMe';
    default:
      return 'PlayWithMe ($environment)';
  }
}