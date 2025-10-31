import 'package:yad_app/config/app_config.dart';
import 'package:yad_app/core/network/network_service.dart';
import 'package:yad_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:yad_app/features/auth/data/datasources/auth_mock_datasource.dart';
import 'package:yad_app/features/auth/domain/models/user_model.dart';

/// Unified authentication datasource that switches between mock and real API
/// This allows easy toggling between development (mock) and production (real API) modes
class UnifiedAuthDataSource implements AuthRemoteDataSource {
  final NetworkService? networkService;
  late final MockAuthRemoteDataSource mockDataSource;

  UnifiedAuthDataSource({this.networkService}) {
    mockDataSource = MockAuthRemoteDataSource();
  }

  /// Returns true if using mock API, false if using real API
  bool get isMockMode => AppConfig.useMockApi;

  @override
  Future<UserModel> register({
    required String email,
    required String firstName,
    required String lastName,
    required String password,
  }) async {
    if (isMockMode) {
      return await mockDataSource.register(
        email: email,
        firstName: firstName,
        lastName: lastName,
        password: password,
      );
    } else {
      if (networkService == null) {
        throw Exception('NetworkService not initialized');
      }
      try {
        final response = await networkService!.post<Map<String, dynamic>>(
          '/users/register',
          data: {
            'email': email,
            'firstName': firstName,
            'lastName': lastName,
            'password': password,
          },
        );
        return UserModel.fromJson(response);
      } catch (e) {
        rethrow;
      }
    }
  }

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    if (isMockMode) {
      return await mockDataSource.login(
        email: email,
        password: password,
      );
    } else {
      if (networkService == null) {
        throw Exception('NetworkService not initialized');
      }
      try {
        final response = await networkService!.post<Map<String, dynamic>>(
          '/users/login',
          data: {
            'email': email,
            'password': password,
          },
        );
        return UserModel.fromJson(response);
      } catch (e) {
        rethrow;
      }
    }
  }

  @override
  Future<void> logout() async {
    if (isMockMode) {
      return await mockDataSource.logout();
    } else {
      if (networkService == null) {
        throw Exception('NetworkService not initialized');
      }
      networkService!.removeAuthToken();
    }
  }
}
