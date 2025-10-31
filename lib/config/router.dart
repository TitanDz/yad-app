import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:yad_app/config/service_locator.dart';
import 'package:yad_app/features/auth/data/datasources/otp_datasource.dart';
import 'package:yad_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:yad_app/features/auth/presentation/bloc/otp_bloc.dart';
import 'package:yad_app/features/auth/presentation/pages/login_page.dart';
import 'package:yad_app/features/auth/presentation/pages/otp_page.dart';
import 'package:yad_app/features/auth/presentation/pages/register_page.dart';
import 'package:yad_app/features/home/presentation/bloc/home_bloc.dart';
import 'package:yad_app/features/home/presentation/pages/home_page.dart';
import 'package:yad_app/features/settings/data/datasources/settings_datasource.dart';
import 'package:yad_app/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:yad_app/features/settings/presentation/pages/initial_setup_page.dart';

class AppRouter {
  static const String home = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String otp = '/otp';
  static const String initialSetup = '/initial-setup';

  static final GoRouter router = GoRouter(
    initialLocation: login,
    routes: [
      GoRoute(
        path: home,
        builder: (context, state) => BlocProvider<HomeBloc>(
          create: (context) => getIt<HomeBloc>()
            ..add(const InitializeMapEvent()),
          child: const HomePage(),
        ),
      ),
      GoRoute(
        path: login,
        builder: (context, state) => BlocProvider<AuthBloc>(
          create: (context) => getIt<AuthBloc>(),
          child: const LoginPage(),
        ),
      ),
      GoRoute(
        path: register,
        builder: (context, state) => BlocProvider<AuthBloc>(
          create: (context) => getIt<AuthBloc>(),
          child: const RegisterPage(),
        ),
      ),
      GoRoute(
        path: otp,
        builder: (context, state) {
          final email = state.extra as String?;
          return BlocProvider<OtpBloc>(
            create: (context) => OtpBloc(
              otpDataSource: MockOtpDataSource(),
            ),
            child: OtpPage(
              email: email ?? '',
              phoneNumber: '555-123-4567',
            ),
          );
        },
      ),
      GoRoute(
        path: initialSetup,
        builder: (context, state) => BlocProvider<SettingsBloc>(
          create: (context) => SettingsBloc(
            settingsDataSource: MockSettingsDataSource(),
          ),
          child: const InitialSetupPage(),
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Error: ${state.error}'),
      ),
    ),
  );
}
