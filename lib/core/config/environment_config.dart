enum Environment { dev, prod }

class EnvironmentConfig {
  static Environment _environment = Environment.prod;

  static Environment get environment => _environment;

  static void setEnvironment(Environment env) {
    _environment = env;
  }

  static String get environmentName {
    switch (_environment) {
      case Environment.dev:
        return 'Development';
      case Environment.prod:
        return 'Production';
    }
  }

  static String get firebaseProjectId {
    switch (_environment) {
      case Environment.dev:
        return 'gatherli-dev';
      case Environment.prod:
        return 'gatherli-prod';
    }
  }

  static bool get isDevelopment => _environment == Environment.dev;
  static bool get isProduction => _environment == Environment.prod;

  static String get appSuffix {
    switch (_environment) {
      case Environment.dev:
        return ' (Dev)';
      case Environment.prod:
        return '';
    }
  }
}
