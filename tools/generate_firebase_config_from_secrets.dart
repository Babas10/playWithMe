#!/usr/bin/env dart

import 'dart:convert';
import 'dart:io';

/// Generates Firebase configuration Dart files from GitHub Secrets.
/// This script reads Firebase configuration from environment variables
/// set by GitHub Secrets, ensuring no sensitive data is committed to the repository.
void main(List<String> arguments) {
  if (arguments.isEmpty) {
    print('Usage: dart tools/generate_firebase_config_from_secrets.dart <environment>');
    print('Example: dart tools/generate_firebase_config_from_secrets.dart dev');
    print('Available environments: dev, stg, prod');
    exit(1);
  }

  final environment = arguments[0];
  if (!['dev', 'stg', 'prod'].contains(environment)) {
    print('Error: Invalid environment "$environment"');
    print('Available environments: dev, stg, prod');
    exit(1);
  }

  print('🔥 Generating Firebase configuration for $environment environment from secrets...');

  try {
    final config = _generateFirebaseConfig(environment);
    _writeConfigFile(environment, config);
    print('✅ Successfully generated lib/core/config/firebase_config_$environment.dart');
  } catch (e) {
    print('❌ Error generating Firebase configuration: $e');
    exit(1);
  }
}

/// Generates Firebase configuration using environment variables from GitHub Secrets
String _generateFirebaseConfig(String environment) {
  final projectData = _getProjectDataFromEnv(environment);

  return '''
// GENERATED FILE - DO NOT EDIT MANUALLY
// Generated from GitHub Secrets for $environment environment
// Run: dart tools/generate_firebase_config_from_secrets.dart $environment

import 'firebase_config_base.dart';

class FirebaseConfig${_capitalize(environment)} extends FirebaseConfigBase {
  @override
  String get projectId => '${projectData['projectId']}';

  @override
  String get storageBucket => '${projectData['storageBucket']}';

  @override
  String get androidAppId => '${projectData['androidAppId']}';

  @override
  String get iosAppId => '${projectData['iosAppId']}';

  @override
  String get apiKey => '${projectData['apiKey']}';

  @override
  String get messagingSenderId => '${projectData['messagingSenderId']}';

  @override
  String get androidPackageName => '${projectData['androidPackageName']}';

  @override
  String get iosBundleId => '${projectData['iosBundleId']}';

  @override
  String get environment => '$environment';

  @override
  String get displayName => '${_getDisplayName(environment)}';
}
''';
}

/// Gets the project data from environment variables (GitHub Secrets)
Map<String, String> _getProjectDataFromEnv(String environment) {
  final envPrefix = environment.toUpperCase();

  // Try to get values from environment variables
  final projectId = Platform.environment['FIREBASE_${envPrefix}_PROJECT_ID'];
  final storageBucket = Platform.environment['FIREBASE_${envPrefix}_STORAGE_BUCKET'];
  final androidAppId = Platform.environment['FIREBASE_${envPrefix}_ANDROID_APP_ID'];
  final iosAppId = Platform.environment['FIREBASE_${envPrefix}_IOS_APP_ID'];
  final apiKey = Platform.environment['FIREBASE_${envPrefix}_API_KEY'];
  final messagingSenderId = Platform.environment['FIREBASE_${envPrefix}_MESSAGING_SENDER_ID'];
  final androidPackageName = Platform.environment['FIREBASE_${envPrefix}_ANDROID_PACKAGE_NAME'];
  final iosBundleId = Platform.environment['FIREBASE_${envPrefix}_IOS_BUNDLE_ID'];

  // Validate that all required environment variables are present
  final missingVars = <String>[];
  if (projectId == null || projectId.isEmpty) missingVars.add('FIREBASE_${envPrefix}_PROJECT_ID');
  if (storageBucket == null || storageBucket.isEmpty) missingVars.add('FIREBASE_${envPrefix}_STORAGE_BUCKET');
  if (androidAppId == null || androidAppId.isEmpty) missingVars.add('FIREBASE_${envPrefix}_ANDROID_APP_ID');
  if (iosAppId == null || iosAppId.isEmpty) missingVars.add('FIREBASE_${envPrefix}_IOS_APP_ID');
  if (apiKey == null || apiKey.isEmpty) missingVars.add('FIREBASE_${envPrefix}_API_KEY');
  if (messagingSenderId == null || messagingSenderId.isEmpty) missingVars.add('FIREBASE_${envPrefix}_MESSAGING_SENDER_ID');
  if (androidPackageName == null || androidPackageName.isEmpty) missingVars.add('FIREBASE_${envPrefix}_ANDROID_PACKAGE_NAME');
  if (iosBundleId == null || iosBundleId.isEmpty) missingVars.add('FIREBASE_${envPrefix}_IOS_BUNDLE_ID');

  if (missingVars.isNotEmpty) {
    throw Exception(
      'Missing required environment variables for $environment environment:\n'
      '${missingVars.map((v) => '  - $v').join('\n')}\n\n'
      'Please ensure these GitHub Secrets are configured in your repository.'
    );
  }

  return {
    'projectId': projectId,
    'storageBucket': storageBucket,
    'androidAppId': androidAppId,
    'iosAppId': iosAppId,
    'apiKey': apiKey,
    'messagingSenderId': messagingSenderId,
    'androidPackageName': androidPackageName,
    'iosBundleId': iosBundleId,
  };
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