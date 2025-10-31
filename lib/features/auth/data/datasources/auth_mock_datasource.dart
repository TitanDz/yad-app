import 'package:yad_app/features/auth/domain/models/user_model.dart';

/// Mock implementation of AuthRemoteDataSource
/// Simulates authentication without requiring a real backend
/// Useful for development, testing, and demo purposes
class MockAuthRemoteDataSource {
  /// Simulated delay for API calls (in milliseconds)
  /// Makes the mock feel more realistic
  static const int apiDelayMs = 1500;

  /// List of mock users for testing
  static final List<Map<String, String>> _mockUsers = [
    {
      'id': '1',
      'email': 'test@example.com',
      'firstName': 'Test',
      'lastName': 'User',
      'password': 'Password123',
    },
    {
      'id': '2',
      'email': 'demo@example.com',
      'firstName': 'Demo',
      'lastName': 'Account',
      'password': 'Demo12345',
    },
  ];

  /// Mock registration
  /// Creates a new mock user and returns it
  Future<UserModel> register({
    required String email,
    required String firstName,
    required String lastName,
    required String password,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: apiDelayMs));

    // Check if user already exists
    final userExists =
        _mockUsers.any((user) => user['email'] == email);
    if (userExists) {
      throw Exception('Email already exists');
    }

    // Create new mock user
    final newUser = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'password': password,
    };

    _mockUsers.add(newUser);

    return UserModel(
      id: newUser['id']!,
      email: newUser['email']!,
      firstName: newUser['firstName']!,
      lastName: newUser['lastName']!,
    );
  }

  /// Mock login
  /// Validates credentials against mock users
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: apiDelayMs));

    // Find user by email and password
    try {
      final user = _mockUsers.firstWhere(
        (u) => u['email'] == email && u['password'] == password,
      );

      return UserModel(
        id: user['id']!,
        email: user['email']!,
        firstName: user['firstName']!,
        lastName: user['lastName']!,
      );
    } catch (e) {
      throw Exception('Invalid email or password');
    }
  }

  /// Mock logout
  /// Simply clears any session data (in real app)
  Future<void> logout() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    // In a real app, would invalidate token on server
  }
}
