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
import 'package:yad_app/features/home/presentation/pages/create_minyan_page.dart';
import 'package:yad_app/features/settings/data/datasources/settings_datasource.dart';
import 'package:yad_app/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:yad_app/features/settings/presentation/pages/initial_setup_page.dart';
import 'package:yad_app/features/settings/presentation/pages/settings_page.dart';
import 'package:yad_app/features/settings/presentation/pages/profile_page.dart';
import 'package:yad_app/features/settings/presentation/pages/notifications_page.dart';
import 'package:yad_app/features/settings/presentation/pages/prayer_preferences_page.dart';
import 'package:yad_app/features/settings/presentation/pages/visibility_page.dart';
import 'package:yad_app/features/settings/presentation/pages/travel_mode_page.dart';
import 'package:yad_app/features/settings/presentation/pages/report_problem_page.dart';
import 'package:yad_app/features/settings/presentation/pages/help_center_page.dart';
import 'package:yad_app/features/settings/presentation/pages/about_page.dart';

class AppRouter {
  static const String home = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String otp = '/otp';
  static const String initialSetup = '/initial-setup';
  static const String settings = '/settings';
  static const String profile = '/profile';
  static const String notifications = '/notifications';
  static const String prayerPreferences = '/prayer-preferences';
  static const String visibility = '/visibility';
  static const String travelMode = '/travel-mode';
  static const String reportProblem = '/report-problem';
  static const String helpCenter = '/help-center';
  static const String about = '/about';
  static const String createMinyan = '/create-minyan';

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
      GoRoute(
        path: settings,
        builder: (context, state) => BlocProvider<SettingsBloc>(
          create: (context) => SettingsBloc(
            settingsDataSource: MockSettingsDataSource(),
          ),
          child: const SettingsPage(),
        ),
      ),
      GoRoute(
        path: profile,
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: notifications,
        builder: (context, state) => const NotificationsPage(),
      ),
      GoRoute(
        path: prayerPreferences,
        builder: (context, state) => const PrayerPreferencesPage(),
      ),
      GoRoute(
        path: visibility,
        builder: (context, state) => const VisibilityPage(),
      ),
      GoRoute(
        path: travelMode,
        builder: (context, state) => const TravelModePage(),
      ),
      GoRoute(
        path: reportProblem,
        builder: (context, state) => const ReportAProblemPage(),
      ),
      GoRoute(
        path: helpCenter,
        builder: (context, state) => const HelpCenterPage(),
      ),
      GoRoute(
        path: about,
        builder: (context, state) => const AboutPage(),
      ),
      GoRoute(
        path: createMinyan,
        builder: (context, state) => const CreateMinyanPage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Error: ${state.error}'),
      ),
    ),
  );
}
