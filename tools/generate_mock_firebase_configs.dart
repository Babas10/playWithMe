#!/usr/bin/env dart

/// Generates mock Firebase configuration files for CI environments
/// This allows tests to compile and run without exposing real Firebase credentials
///
/// Usage: dart tools/generate_mock_firebase_configs.dart
///
/// Creates mock config files for dev and prod environments with fake but
/// structurally valid Firebase configuration data.

import 'dart:io';

void main() {
  print('🔧 Generating mock Firebase configurations for CI...');

  try {
    generateMockDevConfig();
    generateMockProdConfig();

    print('✅ Mock Firebase configurations generated successfully!');
    print('   - lib/core/config/firebase_config_dev.dart');
    print('   - lib/core/config/firebase_config_prod.dart');
    print('');
    print('🔒 Note: These are MOCK configurations for CI testing only.');
    print('   Real configurations are securely excluded from the repository.');
  } catch (e) {
    print('❌ Error generating mock configurations: $e');
    exit(1);
  }
}

void generateMockDevConfig() {
  final content = '''// MOCK FILE - FOR CI TESTING ONLY
// This is a mock Firebase configuration file generated for CI environments
// Real configurations are securely excluded from the repository

import 'firebase_config_base.dart';

class FirebaseConfigDev extends FirebaseConfigBase {
  @override
  String get projectId => 'mock-project-dev';

  @override
  String get storageBucket => 'mock-project-dev.firebasestorage.app';

  @override
  String get androidAppId => '1:123456789:android:abcdef123456789';

  @override
  String get iosAppId => '1:123456789:ios:abcdef123456789';

  @override
  String get apiKey => 'mock-api-key-for-ci-testing';

  @override
  String get messagingSenderId => '123456789';

  @override
  String get androidPackageName => 'org.gatherli.app.dev';

  @override
  String get iosBundleId => 'org.gatherli.app.dev';

  @override
  String get environment => 'dev';

  @override
  String get displayName => 'Gatherli (Mock Dev)';
}
''';

  final file = File('lib/core/config/firebase_config_dev.dart');
  file.writeAsStringSync(content);
}

void generateMockProdConfig() {
  final content = '''// MOCK FILE - FOR CI TESTING ONLY
// This is a mock Firebase configuration file generated for CI environments
// Real configurations are securely excluded from the repository

import 'firebase_config_base.dart';

class FirebaseConfigProd extends FirebaseConfigBase {
  @override
  String get projectId => 'mock-project-prod';

  @override
  String get storageBucket => 'mock-project-prod.firebasestorage.app';

  @override
  String get androidAppId => '1:123456789:android:proddef123456789';

  @override
  String get iosAppId => '1:123456789:ios:proddef123456789';

  @override
  String get apiKey => 'mock-api-key-for-ci-production';

  @override
  String get messagingSenderId => '123456789';

  @override
  String get androidPackageName => 'org.gatherli.app';

  @override
  String get iosBundleId => 'org.gatherli.app';

  @override
  String get environment => 'prod';

  @override
  String get displayName => 'Gatherli (Mock Production)';
}
''';

  final file = File('lib/core/config/firebase_config_prod.dart');
  file.writeAsStringSync(content);
}