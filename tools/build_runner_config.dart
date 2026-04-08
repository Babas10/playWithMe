#!/usr/bin/env dart
// ignore_for_file: avoid_print

import 'dart:io';

/// Pre-build script that generates Firebase configuration files for the current flavor
/// This is called by the build system to ensure config files are available
void main(List<String> arguments) {
  // Get the flavor from environment or arguments
  String? flavor =
      Platform.environment['FLUTTER_BUILD_MODE'] ??
      Platform.environment['CONFIGURATION'];

  if (arguments.isNotEmpty) {
    flavor = arguments[0];
  }

  // Map build configurations to environments
  String? environment;
  if (flavor != null) {
    if (flavor.toLowerCase().contains('dev')) {
      environment = 'dev';
    } else if (flavor.toLowerCase().contains('prod')) {
      environment = 'prod';
    }
  }

  if (environment == null) {
    print('Warning: Could not determine environment from flavor "$flavor"');
    print('Skipping Firebase config generation.');
    return;
  }

  print('🔧 Pre-build: Generating Firebase config for $environment...');

  // Run the config generation
  final result = Process.runSync('dart', [
    'tools/generate_firebase_config.dart',
    environment,
  ], runInShell: true);

  if (result.exitCode == 0) {
    print('✅ Firebase config generation completed');
  } else {
    print('❌ Firebase config generation failed:');
    print(result.stdout);
    print(result.stderr);
    exit(1);
  }
}
