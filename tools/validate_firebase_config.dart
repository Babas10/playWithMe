#!/usr/bin/env dart

import 'dart:convert';
import 'dart:io';

/// Validates Firebase configuration files for all environments
///
/// This script checks that:
/// 1. All required config files exist
/// 2. Config files contain valid JSON/plist format
/// 3. Bundle IDs match the expected flavor configuration
/// 4. Project IDs match the expected Firebase projects
/// 5. No placeholder values remain in the config files

void main() async {
  print('🔥 Firebase Configuration Validator');
  print('=====================================\n');

  var allValid = true;

  // Validate Android configurations
  print('📱 Validating Android configurations...');
  allValid &= await validateAndroidConfigs();

  // Validate iOS configurations
  print('\n🍎 Validating iOS configurations...');
  allValid &= await validateiOSConfigs();

  // Summary
  print('\n' + '=' * 50);
  if (allValid) {
    print('✅ All Firebase configurations are valid!');
    print('You can proceed with building and testing your flavors.');
    exit(0);
  } else {
    print('❌ Some Firebase configurations have issues.');
    print('Please review the errors above and fix them before proceeding.');
    exit(1);
  }
}

Future<bool> validateAndroidConfigs() async {
  var valid = true;
  const environments = ['dev', 'prod'];
  const expectedBundleIds = {
    'dev': 'com.gatherli.app.dev',
    'prod': 'com.gatherli.app',
  };
  const expectedProjectIds = {
    'dev': 'gatherli-dev',
    'prod': 'gatherli-prod',
  };

  for (final env in environments) {
    final configPath = 'android/app/src/$env/google-services.json';
    final file = File(configPath);

    print('  Checking $env environment...');

    if (!await file.exists()) {
      print('    ❌ Config file not found: $configPath');
      valid = false;
      continue;
    }

    try {
      final content = await file.readAsString();
      final config = jsonDecode(content) as Map<String, dynamic>;

      // Validate project ID
      final projectId = config['project_info']?['project_id'] as String?;
      if (projectId != expectedProjectIds[env]) {
        print('    ❌ Project ID mismatch: expected "${expectedProjectIds[env]}", found "$projectId"');
        valid = false;
      } else {
        print('    ✅ Project ID correct: $projectId');
      }

      // Validate bundle ID
      final clients = config['client'] as List<dynamic>?;
      if (clients?.isNotEmpty == true) {
        final firstClient = clients!.first as Map<String, dynamic>;
        final bundleId = firstClient['client_info']?['android_client_info']?['package_name'] as String?;

        if (bundleId != expectedBundleIds[env]) {
          print('    ❌ Bundle ID mismatch: expected "${expectedBundleIds[env]}", found "$bundleId"');
          valid = false;
        } else {
          print('    ✅ Bundle ID correct: $bundleId');
        }

        // Check for placeholder API keys
        final apiKeys = firstClient['api_key'] as List<dynamic>?;
        if (apiKeys?.isNotEmpty == true) {
          final apiKey = (apiKeys!.first as Map<String, dynamic>)['current_key'] as String?;
          if (apiKey?.contains('placeholder') == true || apiKey?.contains('DEV') == true ||
              apiKey?.contains('STG') == true || apiKey?.contains('PROD') == true) {
            print('    ⚠️  Warning: API key appears to be a placeholder: ${apiKey?.substring(0, 20)}...');
          } else {
            print('    ✅ API key appears to be real');
          }
        }
      } else {
        print('    ❌ No client configuration found');
        valid = false;
      }

    } catch (e) {
      print('    ❌ Error parsing config file: $e');
      valid = false;
    }
  }

  return valid;
}

Future<bool> validateiOSConfigs() async {
  var valid = true;
  const environments = ['dev', 'prod'];
  const expectedBundleIds = {
    'dev': 'com.gatherli.app.dev',
    'prod': 'com.gatherli.app',
  };
  const expectedProjectIds = {
    'dev': 'gatherli-dev',
    'prod': 'gatherli-prod',
  };

  for (final env in environments) {
    final configPath = 'ios/Runner/Firebase/$env/GoogleService-Info.plist';
    final file = File(configPath);

    print('  Checking $env environment...');

    if (!await file.exists()) {
      print('    ❌ Config file not found: $configPath');
      valid = false;
      continue;
    }

    try {
      final content = await file.readAsString();

      // Simple plist parsing (looking for key-value pairs)
      final projectIdMatch = RegExp(r'<key>PROJECT_ID</key>\s*<string>([^<]+)</string>').firstMatch(content);
      final bundleIdMatch = RegExp(r'<key>BUNDLE_ID</key>\s*<string>([^<]+)</string>').firstMatch(content);
      final apiKeyMatch = RegExp(r'<key>API_KEY</key>\s*<string>([^<]+)</string>').firstMatch(content);

      // Validate project ID
      final projectId = projectIdMatch?.group(1);
      if (projectId != expectedProjectIds[env]) {
        print('    ❌ Project ID mismatch: expected "${expectedProjectIds[env]}", found "$projectId"');
        valid = false;
      } else {
        print('    ✅ Project ID correct: $projectId');
      }

      // Validate bundle ID
      final bundleId = bundleIdMatch?.group(1);
      if (bundleId != expectedBundleIds[env]) {
        print('    ❌ Bundle ID mismatch: expected "${expectedBundleIds[env]}", found "$bundleId"');
        valid = false;
      } else {
        print('    ✅ Bundle ID correct: $bundleId');
      }

      // Check for placeholder API keys
      final apiKey = apiKeyMatch?.group(1);
      if (apiKey?.contains('placeholder') == true || apiKey?.contains('DEV') == true ||
          apiKey?.contains('STG') == true || apiKey?.contains('PROD') == true) {
        print('    ⚠️  Warning: API key appears to be a placeholder: ${apiKey?.substring(0, 20)}...');
      } else {
        print('    ✅ API key appears to be real');
      }

    } catch (e) {
      print('    ❌ Error parsing config file: $e');
      valid = false;
    }
  }

  return valid;
}