import 'package:yad_app/features/auth/domain/models/user_model.dart';

/// Mock implementation of AuthRemoteDataSource
/// Simulates authentication without requiring a real backend
/// Useful for development, testing, and demo purposes
class MockAuthRemoteDataSource {
  /// Simulated delay for API calls (in milliseconds)
  /// Makes the mock feel more realistic
  static const int apiDelayMs = 1500;

  /// List of mock users for testing
  /// Each user simulates a different real-world scenario
  static final List<Map<String, String>> _mockUsers = [
    // Primary test user
    {
      'id': '1',
      'email': 'test@example.com',
      'firstName': 'Test',
      'lastName': 'User',
      'password': 'Password123',
    },
    // Secondary demo account
    {
      'id': '2',
      'email': 'demo@example.com',
      'firstName': 'Demo',
      'lastName': 'Account',
      'password': 'Demo12345',
    },
    // Additional test users for minyan formation testing
    // These accounts correspond to the mock active users
    {
      'id': '3',
      'email': 'david@example.com',
      'firstName': 'David',
      'lastName': 'Cohen',
      'password': 'David123!',
    },
    {
      'id': '4',
      'email': 'rachel@example.com',
      'firstName': 'Rachel',
      'lastName': 'Silverstein',
      'password': 'Rachel123!',
    },
    {
      'id': '5',
      'email': 'michael@example.com',
      'firstName': 'Michael',
      'lastName': 'Rothstein',
      'password': 'Michael123!',
    },
    {
      'id': '6',
      'email': 'sarah@example.com',
      'firstName': 'Sarah',
      'lastName': 'Goldstein',
      'password': 'Sarah123!',
    },
    {
      'id': '7',
      'email': 'aaron@example.com',
      'firstName': 'Aaron',
      'lastName': 'Blum',
      'password': 'Aaron123!',
    },
    {
      'id': '8',
      'email': 'miriam@example.com',
      'firstName': 'Miriam',
      'lastName': 'Levy',
      'password': 'Miriam123!',
    },
    {
      'id': '9',
      'email': 'eli@example.com',
      'firstName': 'Eli',
      'lastName': 'Kellerman',
      'password': 'Eli123!',
    },
    {
      'id': '10',
      'email': 'hannah@example.com',
      'firstName': 'Hannah',
      'lastName': 'Steinberg',
      'password': 'Hannah123!',
    },
    {
      'id': '11',
      'email': 'jacob@example.com',
      'firstName': 'Jacob',
      'lastName': 'Mendelson',
      'password': 'Jacob123!',
    },
    {
      'id': '12',
      'email': 'leah@example.com',
      'firstName': 'Leah',
      'lastName': 'Feldman',
      'password': 'Leah123!',
    },
    {
      'id': '13',
      'email': 'joseph@example.com',
      'firstName': 'Joseph',
      'lastName': 'Lowenthal',
      'password': 'Joseph123!',
    },
    {
      'id': '14',
      'email': 'ruth@example.com',
      'firstName': 'Ruth',
      'lastName': 'Goldman',
      'password': 'Ruth123!',
    },
    {
      'id': '15',
      'email': 'samuel@example.com',
      'firstName': 'Samuel',
      'lastName': 'Friedman',
      'password': 'Samuel123!',
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

  /// Get all available test users (for debugging/testing)
  static List<Map<String, String>> getAllTestUsers() => _mockUsers;

  /// Get a test user by email
  static Map<String, String>? getTestUserByEmail(String email) {
    try {
      return _mockUsers.firstWhere((u) => u['email'] == email);
    } catch (e) {
      return null;
    }
  }

  /// Get a test user by ID
  static Map<String, String>? getTestUserById(String id) {
    try {
      return _mockUsers.firstWhere((u) => u['id'] == id);
    } catch (e) {
      return null;
    }
  }
}