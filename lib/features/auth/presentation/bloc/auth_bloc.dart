import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yad_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:yad_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:yad_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:yad_app/config/service_locator.dart';
import 'package:yad_app/core/services/app_initialization_service.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repository;

  AuthBloc({required this.repository}) : super(const AuthInitial()) {
    on<AuthRegisterEvent>(_onAuthRegister);
    on<AuthLoginEvent>(_onAuthLogin);
    on<AuthLogoutEvent>(_onAuthLogout);
    on<AuthCheckStatusEvent>(_onAuthCheckStatus);
  }

  Future<void> _onAuthRegister(
    AuthRegisterEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await repository.register(
        email: event.email,
        firstName: event.firstName,
        lastName: event.lastName,
        password: event.password,
      );
      emit(AuthRegistrationSuccess(user));
    } catch (e) {
      // Provide user-friendly error messages
      final errorMessage = _getErrorMessage(e);
      emit(AuthFailure(errorMessage));
    }
  }

  Future<void> _onAuthLogin(
    AuthLoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await repository.login(
        email: event.email,
        password: event.password,
      );
      
      // Emit success immediately - initialization happens in background
      emit(AuthLoginSuccess(user, event.email));
      
      // Initialize user preferences in background without blocking login flow
      // This ensures the OTP screen shows immediately for better UX
      Future.microtask(() async {
        try {
          final appInitService = getIt<AppInitializationService>();
          await appInitService.initializeAfterLogin(user.id);
          print('[AuthBloc] User preferences initialized in background for user: ${user.id}');
        } catch (e) {
          print('[AuthBloc] Failed to initialize user preferences (background): $e');
          // Silent fail - app continues without user preferences
        }
      });
    } catch (e) {
      // Provide user-friendly error messages
      final errorMessage = _getErrorMessage(e);
      emit(AuthFailure(errorMessage));
    }
  }

  Future<void> _onAuthLogout(
    AuthLogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await repository.logout();
      emit(const AuthUnauthenticated());
    } catch (e) {
      // Provide user-friendly error messages
      final errorMessage = _getErrorMessage(e);
      emit(AuthFailure(errorMessage));
    }
  }

  Future<void> _onAuthCheckStatus(
    AuthCheckStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    // TODO: Implement check status logic (check cached token, refresh token, etc.)
    emit(const AuthUnauthenticated());
  }

  /// Convert exception to user-friendly error message
  String _getErrorMessage(Object error) {
    final errorString = error.toString();
    
    // Handle specific error messages
    if (errorString.contains('Invalid email or password')) {
      return 'Invalid email or password. Please try again.';
    } else if (errorString.contains('NetworkException') || errorString.contains('SocketException')) {
      return 'Network error. Please check your internet connection.';
    } else if (errorString.contains('TimeoutException')) {
      return 'Request timed out. Please try again.';
    } else if (errorString.contains('User not found')) {
      return 'This account does not exist. Please sign up first.';
    } else if (errorString.contains('Password')) {
      return 'Incorrect password. Please try again.';
    }
    
    // Default fallback message
    return 'An error occurred. Please try again.';
  }
}
