/// Base class for Firebase configuration
/// This provides a type-safe interface for Firebase settings across environments
abstract class FirebaseConfigBase {
  /// Firebase project ID
  String get projectId;

  /// Firebase storage bucket URL
  String get storageBucket;

  /// Android app ID from Firebase
  String get androidAppId;

  /// iOS app ID from Firebase
  String get iosAppId;

  /// Firebase API key
  String get apiKey;

  /// Firebase messaging sender ID (project number)
  String get messagingSenderId;

  /// Android package name
  String get androidPackageName;

  /// iOS bundle identifier
  String get iosBundleId;

  /// Environment name (dev, stg, prod)
  String get environment;

  /// Display name for the app in this environment
  String get displayName;

  /// Whether this is a production environment
  bool get isProduction => environment == 'prod';

  /// Whether this is a development environment
  bool get isDevelopment => environment == 'dev';

  /// Whether this is a staging environment
  bool get isStaging => environment == 'stg';

  @override
  String toString() {
    return 'FirebaseConfig($environment: $projectId)';
  }