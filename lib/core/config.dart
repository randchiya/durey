// Environment configuration using dart-defines
class Config {
  // Access environment variables passed via --dart-define
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.example.com',
  );

  static const String apiKey = String.fromEnvironment(
    'API_KEY',
    defaultValue: '',
  );

  static const String appEnv = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'development',
  );

  // AdMob Configuration
  static const String admobAppIdAndroid = String.fromEnvironment(
    'ADMOB_APP_ID_ANDROID',
    defaultValue: '',
  );

  static const String admobAppIdIos = String.fromEnvironment(
    'ADMOB_APP_ID_IOS',
    defaultValue: '',
  );

  static const String admobBannerIdAndroid = String.fromEnvironment(
    'ADMOB_BANNER_ID_ANDROID',
    defaultValue: '',
  );

  static const String admobBannerIdIos = String.fromEnvironment(
    'ADMOB_BANNER_ID_IOS',
    defaultValue: '',
  );

  static bool get isProduction => appEnv == 'production';
  static bool get isDevelopment => appEnv == 'development';
}
