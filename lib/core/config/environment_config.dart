enum Environment {
  dev,
  stg,
  prod,
}

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
      case Environment.stg:
        return 'Staging';
      case Environment.prod:
        return 'Production';
    }
  }

  static String get firebaseProjectId {
    switch (_environment) {
      case Environment.dev:
        return 'playwithme-dev';
      case Environment.stg:
        return 'playwithme-stg';
      case Environment.prod:
        return 'playwithme-prod';
    }
  }

  static bool get isDevelopment => _environment == Environment.dev;
  static bool get isStaging => _environment == Environment.stg;
  static bool get isProduction => _environment == Environment.prod;

  static String get appSuffix {
    switch (_environment) {
      case Environment.dev:
        return ' (Dev)';
      case Environment.stg:
        return ' (Staging)';
      case Environment.prod:
        return '';
    }
  }
}