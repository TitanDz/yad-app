/// Application configuration class
/// Allows switching between mock and real API modes
class AppConfig {
  /// Whether to use mock API for authentication
  /// Set to true for development/testing without backend
  /// Set to false to use real backend API
  static const bool useMockApi = true;

  /// Whether to enable detailed logging
  static const bool enableLogging = true;

  /// Mock user credentials for testing
  /// Email: test@example.com
  /// Password: Password123
  static const String mockUserEmail = 'test@example.com';
  static const String mockUserPassword = 'Password123';
}
