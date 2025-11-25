class AppConstants {
  static const String appName = 'The10th';
  static const String appVersion = '1.0.0';

  // API Constants
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://localhost:8080/api/v1',
  );

  // Storage Keys
  static const String userAuthToken = 'user_auth_token';
  static const String userPreferences = 'user_preferences';
  static const String cachedUserData = 'cached_user_data';

  // Timing
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration debounceDelay = Duration(milliseconds: 500);

  // Validation - Password Requirements
  static const int minPasswordLength = 8;
  static const int minPasswordLengthBasic = 6;
  static const int minUserNameLength = 3;
  static const int minFirstNameLength = 2;
  static const int minLastNameLength = 2;

  // Regular Expressions
  static const String emailPattern =
      r'^[a-zA-Z0-9.!#$%&*+/=?^_{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$';
}
