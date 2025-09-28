import '../environment/environment_config.dart';
import 'firebase_config_base.dart';

/// Factory for creating the appropriate Firebase configuration based on the environment
class FirebaseConfigFactory {
  /// Gets the Firebase configuration for the current environment
  static FirebaseConfigBase getConfig() {
    switch (EnvironmentConfig.environment) {
      case Environment.dev:
        return _getDevConfig();
      case Environment.stg:
        return _getStagingConfig();
      case Environment.prod:
        return _getProductionConfig();
    }
  }

  static FirebaseConfigBase _getDevConfig() {
    try {
      // Import will be available after running: dart tools/generate_firebase_config.dart dev
      // ignore: depend_on_referenced_packages
      final config = _loadGeneratedConfig('dev');
      return config;
    } catch (e) {
      throw Exception(
        'Development Firebase configuration not found!\n'
        'Please run: dart tools/generate_firebase_config.dart dev\n'
        'Make sure you have placed google-services.json and GoogleService-Info.plist files in the correct locations.\n'
        'Error: $e'
      );
    }
  }

  static FirebaseConfigBase _getStagingConfig() {
    try {
      // Import will be available after running: dart tools/generate_firebase_config.dart stg
      final config = _loadGeneratedConfig('stg');
      return config;
    } catch (e) {
      throw Exception(
        'Staging Firebase configuration not found!\n'
        'Please run: dart tools/generate_firebase_config.dart stg\n'
        'Make sure you have placed google-services.json and GoogleService-Info.plist files in the correct locations.\n'
        'Error: $e'
      );
    }
  }

  static FirebaseConfigBase _getProductionConfig() {
    try {
      // Import will be available after running: dart tools/generate_firebase_config.dart prod
      final config = _loadGeneratedConfig('prod');
      return config;
    } catch (e) {
      throw Exception(
        'Production Firebase configuration not found!\n'
        'Please run: dart tools/generate_firebase_config.dart prod\n'
        'Make sure you have placed google-services.json and GoogleService-Info.plist files in the correct locations.\n'
        'Error: $e'
      );
    }
  }

  /// Loads the generated configuration for the specified environment
  static FirebaseConfigBase _loadGeneratedConfig(String environment) {
    // This will be dynamically imported based on generated files
    // The actual implementation will depend on the generated config classes
    throw Exception('Generated config for $environment not found. Run the config generation tool first.');
  }
}