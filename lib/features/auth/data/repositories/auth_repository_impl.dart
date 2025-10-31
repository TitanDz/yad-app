import 'package:yad_app/core/errors/failures.dart';
import 'package:yad_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:yad_app/features/auth/domain/models/user_model.dart';

abstract class AuthRepository {
  Future<UserModel> register({
    required String email,
    required String firstName,
    required String lastName,
    required String password,
  });

  Future<UserModel> login({
    required String email,
    required String password,
  });

  Future<void> logout();
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<UserModel> register({
    required String email,
    required String firstName,
    required String lastName,
    required String password,
  }) async {
    try {
      return await remoteDataSource.register(
        email: email,
        firstName: firstName,
        lastName: lastName,
        password: password,
      );
    } catch (e) {
      throw NetworkFailure(e.toString());
    }
  }

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      return await remoteDataSource.login(
        email: email,
        password: password,
      );
    } catch (e) {
      throw NetworkFailure(e.toString());
    }
  }

  @override
  Future<void> logout() async {
    try {
      await remoteDataSource.logout();
    } catch (e) {
      throw NetworkFailure(e.toString());
    }
  }
}
