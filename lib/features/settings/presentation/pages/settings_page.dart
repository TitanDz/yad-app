import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:yad_app/config/router.dart';
import 'package:yad_app/config/theme.dart';
import 'package:yad_app/features/settings/presentation/bloc/theme_bloc.dart';
import 'package:yad_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:yad_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:yad_app/features/auth/presentation/bloc/auth_state.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? AppTheme.neutral900 : Colors.white;
    final appBarBgColor = isDarkMode ? AppTheme.neutral900 : Colors.white;
    final textColor = isDarkMode ? Colors.white : AppTheme.neutral900;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          // Navigate to login after successful logout
          context.go(AppRouter.login);
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Logout failed: ${state.message}'),
              backgroundColor: AppTheme.error,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: appBarBgColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: textColor),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'Settings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Account Section
              _buildSection(
                title: 'Account',
                context: context,
                children: [
                  _buildAccountSettingsItem(
                    icon: Icons.person,
                    title: 'Profile',
                    subtitle: 'View and edit your profile',
                    onTap: () {
                      context.push(AppRouter.profile);
                    },
                    context: context,
                  ),
                  _buildAccountSettingsItem(
                    icon: Icons.settings,
                    title: 'Account Settings',
                    subtitle: 'Manage your account settings',
                    onTap: () {
                      // TODO: Navigate to account settings page
                    },
                    context: context,
                  ),
                ],
              ),

              // Preferences Section
              _buildSection(
                title: 'Preferences',
                context: context,
                children: [
                  _buildSettingsItem(
                    icon: Icons.notifications,
                    title: 'Notifications',
                    subtitle: 'Customize your notification settings',
                    onTap: () {
                      context.push(AppRouter.notifications);
                    },
                    context: context,
                  ),
                  _buildSettingsItem(
                    icon: Icons.notifications,
                    title: 'Prayer Preferences',
                    subtitle: 'Customize your prayer preferences',
                    onTap: () {
                      context.push(AppRouter.prayerPreferences);
                    },
                    context: context,
                  ),
                  _buildSettingsItem(
                    icon: Icons.visibility,
                    title: 'Visibility',
                    subtitle: 'Adjust your visibility settings',
                    onTap: () {
                      context.push(AppRouter.visibility);
                    },
                    context: context,
                  ),
                  _buildSettingsItem(
                    icon: Icons.language,
                    title: 'Travel Mode',
                    subtitle: 'Manage your travel mode',
                    onTap: () {
                      context.push(AppRouter.travelMode);
                    },
                    context: context,
                  ),
                  _buildDarkModeToggle(),
                ],
              ),

              // Support Section
              _buildSection(
                title: 'Support',
                context: context,
                children: [
                  _buildSettingsItem(
                    icon: Icons.help,
                    title: 'Help Center',
                    subtitle: 'Get help and support',
                    onTap: () {
                      context.push(AppRouter.helpCenter);
                    },
                    context: context,
                  ),
                  _buildSettingsItem(
                    icon: Icons.flag,
                    title: 'Report a Problem',
                    subtitle: 'Report a problem or provide feedback',
                    onTap: () {
                      context.push(AppRouter.reportProblem);
                    },
                    context: context,
                  ),
                  _buildSettingsItem(
                    icon: Icons.info,
                    title: 'About',
                    subtitle: 'Learn more about the app',
                    onTap: () {
                      context.push(AppRouter.about);
                    },
                    context: context,
                  ),
                ],
              ),

              // Session Section
              _buildSection(
                title: 'Session',
                context: context,
                children: [
                  _buildLogoutButton(context),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required BuildContext context,
    required List<Widget> children,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDarkMode ? Colors.white : AppTheme.neutral900;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: titleColor,
              ),
            ),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  Widget _buildAccountSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required BuildContext context,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final itemBgColor = isDarkMode ? AppTheme.neutral800 : AppTheme.neutral100;
    final titleColor = isDarkMode ? Colors.white : AppTheme.neutral900;
    final subtextColor = isDarkMode ? AppTheme.neutral400 : AppTheme.neutral500;
    final iconBgColor = isDarkMode ? AppTheme.neutral700 : AppTheme.neutral200;
    final iconColor = isDarkMode ? AppTheme.neutral400 : AppTheme.neutral600;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: itemBgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconBgColor,
              ),
              child: icon == Icons.person
                  ? CircleAvatar(
                      backgroundColor: isDarkMode ? AppTheme.neutral600 : AppTheme.neutral300,
                      child: Icon(
                        Icons.person,
                        color: iconColor,
                        size: 24,
                      ),
                    )
                  : Icon(
                      icon,
                      color: iconColor,
                      size: 24,
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: subtextColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required BuildContext context,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final itemBgColor = isDarkMode ? AppTheme.neutral800 : AppTheme.neutral100;
    final titleColor = isDarkMode ? Colors.white : AppTheme.neutral900;
    final subtextColor = isDarkMode ? AppTheme.neutral400 : AppTheme.neutral500;
    final iconBgColor = isDarkMode ? AppTheme.neutral700 : AppTheme.neutral200;
    final iconColor = isDarkMode ? AppTheme.neutral400 : AppTheme.neutral600;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: itemBgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconBgColor,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: subtextColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDarkModeToggle() {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        final itemBgColor = isDarkMode ? AppTheme.neutral800 : AppTheme.neutral100;
        final titleColor = isDarkMode ? Colors.white : AppTheme.neutral900;
        final subtextColor = isDarkMode ? AppTheme.neutral400 : AppTheme.neutral500;
        final iconBgColor = isDarkMode ? AppTheme.neutral700 : AppTheme.neutral200;
        final iconColor = isDarkMode ? AppTheme.neutral400 : AppTheme.neutral600;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: itemBgColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: iconBgColor,
                ),
                child: Icon(
                  Icons.dark_mode,
                  color: iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dark Mode',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Switch between light and dark mode',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: subtextColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Switch(
                value: state.isDarkMode,
                onChanged: (value) {
                  context.read<ThemeBloc>().add(ToggleThemeEvent());
                },
                activeThumbColor: AppTheme.primary,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final itemBgColor = isDarkMode ? AppTheme.neutral800 : AppTheme.neutral100;

    return GestureDetector(
      onTap: () => _showLogoutConfirmation(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: itemBgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.error.withValues(alpha: 0.1),
              ),
              child: Icon(
                Icons.logout,
                color: AppTheme.error,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Log Out',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.error,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Sign out from your account',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out of your account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              // Trigger logout event
              context.read<AuthBloc>().add(const AuthLogoutEvent());
            },
            child: Text(
              'Log Out',
              style: TextStyle(color: AppTheme.error),
            ),
          ),
        ],
      ),
    );
  }
}
