import 'package:equatable/equatable.dart';
import 'package:yad_app/features/auth/domain/models/user_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final UserModel user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthFailure extends AuthState {
  final String message;

  const AuthFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthRegistrationSuccess extends AuthState {
  final UserModel user;

  const AuthRegistrationSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthLoginSuccess extends AuthState {
  final UserModel user;
  final String email;

  const AuthLoginSuccess(this.user, this.email);

  @override
  List<Object?> get props => [user, email];
}
