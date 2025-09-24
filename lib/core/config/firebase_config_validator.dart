import 'dart:convert';
import 'dart:io';

/// Validates Firebase configuration files for different environments
class FirebaseConfigValidator {
  /// Expected bundle IDs for Android configurations
  static const Map<String, String> expectedAndroidBundleIds = {
    'dev': 'com.playwithme.play_with_me.dev',
    'stg': 'com.playwithme.play_with_me.stg',
    'prod': 'com.playwithme.play_with_me',
  };

  /// Expected bundle IDs for iOS configurations
  static const Map<String, String> expectediOSBundleIds = {
    'dev': 'com.playwithme.playWithMe.dev',
    'stg': 'com.playwithme.playWithMe.stg',
    'prod': 'com.playwithme.playWithMe',
  };

  /// Expected Firebase project IDs
  static const Map<String, String> expectedProjectIds = {
    'dev': 'playwithme-dev',
    'stg': 'playwithme-stg',
    'prod': 'playwithme-prod',
  };

  /// Validates an Android google-services.json configuration
  static Future<ConfigValidationResult> validateAndroidConfig(
    String environment,
    String configPath,
  ) async {
    final file = File(configPath);

    if (!await file.exists()) {
      return ConfigValidationResult(
        isValid: false,
        errors: ['Config file not found: $configPath'],
      );
    }

    try {
      final content = await file.readAsString();
      final config = jsonDecode(content) as Map<String, dynamic>;

      final errors = <String>[];
      final warnings = <String>[];

      // Validate project ID
      final projectId = config['project_info']?['project_id'] as String?;
      final expectedProjectId = expectedProjectIds[environment];
      if (projectId != expectedProjectId) {
        errors.add('Project ID mismatch: expected "$expectedProjectId", found "$projectId"');
      }

      // Validate bundle ID
      final clients = config['client'] as List<dynamic>?;
      if (clients?.isNotEmpty == true) {
        final firstClient = clients!.first as Map<String, dynamic>;
        final bundleId = firstClient['client_info']?['android_client_info']?['package_name'] as String?;
        final expectedBundleId = expectedAndroidBundleIds[environment];

        if (bundleId != expectedBundleId) {
          errors.add('Bundle ID mismatch: expected "$expectedBundleId", found "$bundleId"');
        }

        // Check for placeholder API keys
        final apiKeys = firstClient['api_key'] as List<dynamic>?;
        if (apiKeys?.isNotEmpty == true) {
          final apiKey = (apiKeys!.first as Map<String, dynamic>)['current_key'] as String?;
          if (apiKey?.contains('placeholder') == true ||
              apiKey?.contains('DEV') == true ||
              apiKey?.contains('STG') == true ||
              apiKey?.contains('PROD') == true) {
            warnings.add('API key appears to be a placeholder');
          }
        }
      } else {
        errors.add('No client configuration found');
      }

      return ConfigValidationResult(
        isValid: errors.isEmpty,
        errors: errors,
        warnings: warnings,
      );

    } catch (e) {
      return ConfigValidationResult(
        isValid: false,
        errors: ['Error parsing config file: $e'],
      );
    }
  }

  /// Validates an iOS GoogleService-Info.plist configuration
  static Future<ConfigValidationResult> validateiOSConfig(
    String environment,
    String configPath,
  ) async {
    final file = File(configPath);

    if (!await file.exists()) {
      return ConfigValidationResult(
        isValid: false,
        errors: ['Config file not found: $configPath'],
      );
    }

    try {
      final content = await file.readAsString();
      final errors = <String>[];
      final warnings = <String>[];

      // Simple plist parsing using RegExp
      final projectIdMatch = RegExp(r'<key>PROJECT_ID</key>\s*<string>([^<]+)</string>').firstMatch(content);
      final bundleIdMatch = RegExp(r'<key>BUNDLE_ID</key>\s*<string>([^<]+)</string>').firstMatch(content);
      final apiKeyMatch = RegExp(r'<key>API_KEY</key>\s*<string>([^<]+)</string>').firstMatch(content);

      // Validate project ID
      final projectId = projectIdMatch?.group(1);
      final expectedProjectId = expectedProjectIds[environment];
      if (projectId != expectedProjectId) {
        errors.add('Project ID mismatch: expected "$expectedProjectId", found "$projectId"');
      }

      // Validate bundle ID
      final bundleId = bundleIdMatch?.group(1);
      final expectedBundleId = expectediOSBundleIds[environment];
      if (bundleId != expectedBundleId) {
        errors.add('Bundle ID mismatch: expected "$expectedBundleId", found "$bundleId"');
      }

      // Check for placeholder API keys
      final apiKey = apiKeyMatch?.group(1);
      if (apiKey?.contains('placeholder') == true ||
          apiKey?.contains('DEV') == true ||
          apiKey?.contains('STG') == true ||
          apiKey?.contains('PROD') == true) {
        warnings.add('API key appears to be a placeholder');
      }

      return ConfigValidationResult(
        isValid: errors.isEmpty,
        errors: errors,
        warnings: warnings,
      );

    } catch (e) {
      return ConfigValidationResult(
        isValid: false,
        errors: ['Error parsing config file: $e'],
      );
    }
  }

  /// Validates all Firebase configurations for all environments
  static Future<Map<String, ConfigValidationResult>> validateAllConfigs() async {
    final results = <String, ConfigValidationResult>{};
    const environments = ['dev', 'stg', 'prod'];

    for (final env in environments) {
      // Validate Android config
      final androidResult = await validateAndroidConfig(
        env,
        'android/app/src/$env/google-services.json',
      );
      results['android_$env'] = androidResult;

      // Validate iOS config
      final iosResult = await validateiOSConfig(
        env,
        'ios/Runner/Firebase/$env/GoogleService-Info.plist',
      );
      results['ios_$env'] = iosResult;
    }

    return results;
  }
}

/// Result of a Firebase configuration validation
class ConfigValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;

  const ConfigValidationResult({
    required this.isValid,
    this.errors = const [],
    this.warnings = const [],
  });

  bool get hasWarnings => warnings.isNotEmpty;
}