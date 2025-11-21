import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:yad_app/config/router.dart';
import 'package:yad_app/config/theme.dart';
import 'package:yad_app/features/settings/presentation/bloc/theme_bloc.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? AppTheme.neutral900 : AppTheme.purity;
    final appBarBgColor = isDarkMode ? AppTheme.neutral900 : AppTheme.purity;
    final textColor = isDarkMode ? Colors.white : AppTheme.neutral900;

    return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
            backgroundColor: appBarBgColor,
            elevation: 0,
            leading: Container(
              width: 44,
              height: 44,
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDarkMode ? AppTheme.neutral700 : AppTheme.neutral300,
                  width: 1.5,
                ),
              ),
              child: IconButton(
                icon: SvgPicture.asset(
                  'assets/images/Icons/goback.svg',
                  colorFilter: ColorFilter.mode(
                    textColor,
                    BlendMode.srcIn,
                  ),
                ),
                onPressed: () => context.pop(),
                padding: EdgeInsets.zero,
              ),
            ),
            title: Text(
              'Settings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Account Section
                  _buildSectionTitle('Account', context),
                  const SizedBox(height: 12),
                  _buildCardGrid(
                    context: context,
                    items: [
                      _SettingsCard(
                        svgIcon: 'assets/images/Icons/profile.svg',
                        title: 'Profile',
                        subtitle: 'View profile',
                        onTap: () {
                          context.push(AppRouter.profile);
                        },
                      ),
                      _SettingsCard(
                        svgIcon: 'assets/images/Icons/notification.svg',
                        title: 'Notifications',
                        subtitle: 'Customize',
                        onTap: () {
                          context.push(AppRouter.notifications);
                        },
                      ),
                      _SettingsCard(
                        svgIcon: 'assets/images/Icons/preferences.svg',
                        title: 'Account Settings',
                        subtitle: 'Manage',
                        onTap: () {
                          // TODO: Navigate to account settings page
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Preferences Section
                  _buildSectionTitle('Preferences', context),
                  const SizedBox(height: 12),
                  _buildCardGrid(
                    context: context,
                    items: [
                      _SettingsCard(
                        svgIcon: 'assets/images/Icons/visibility.svg',
                        title: 'Visibility',
                        subtitle: 'Adjust settings',
                        onTap: () {
                          context.push(AppRouter.visibility);
                        },
                      ),
                      _SettingsCard(
                        svgIcon: 'assets/images/Icons/travelmode.svg',
                        title: 'Travel Mode',
                        subtitle: 'Manage mode',
                        onTap: () {
                          context.push(AppRouter.travelMode);
                        },
                      ),
                      _SettingsCard(
                        svgIcon: 'assets/images/Icons/preferences.svg',
                        title: 'Prayer Preferences',
                        subtitle: 'Customize',
                        onTap: () {
                          context.push(AppRouter.prayerPreferences);
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Support Section
                  _buildSectionTitle('Support', context),
                  const SizedBox(height: 12),
                  _buildCardGrid(
                    context: context,
                    items: [
                      _SettingsCard(
                        svgIcon: 'assets/images/Icons/helpcenter.svg',
                        title: 'Help Center',
                        subtitle: 'Get help',
                        onTap: () {
                          context.push(AppRouter.helpCenter);
                        },
                      ),
                      _SettingsCard(
                        svgIcon: 'assets/images/Icons/reportaproblem.svg',
                        title: 'Report',
                        subtitle: 'Feedback',
                        onTap: () {
                          context.push(AppRouter.reportProblem);
                        },
                      ),
                      _SettingsCard(
                        svgIcon: 'assets/images/Icons/about-us.svg',
                        title: 'About',
                        subtitle: 'Learn more',
                        onTap: () {
                          context.push(AppRouter.about);
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Preferences Toggle
                  _buildDarkModeToggle(),

                  const SizedBox(height: 32),

                  // Logout Button
                  _buildLogoutButton(context),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
  }

  Widget _buildSectionTitle(String title, BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDarkMode ? Colors.white : AppTheme.neutral900;

    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: titleColor,
      ),
    );
  }

  Widget _buildCardGrid({
    required BuildContext context,
    required List<_SettingsCard> items,
  }) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.95,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _buildSettingsCardWidget(context, items[index]);
      },
    );
  }

  Widget _buildSettingsCardWidget(
    BuildContext context,
    _SettingsCard card,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardBgColor = isDarkMode ? AppTheme.neutral800 : Colors.white;
    final titleColor = isDarkMode ? Colors.white : AppTheme.neutral900;
    final subtitleColor = isDarkMode ? AppTheme.neutral400 : AppTheme.neutral600;

    return GestureDetector(
      onTap: card.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Icon with circular background
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: SvgPicture.asset(
                    card.svgIcon,
                    width: 28,
                    height: 28,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Title and Subtitle
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      card.title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: titleColor,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      card.subtitle,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: subtitleColor,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }



  Widget _buildDarkModeToggle() {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        final cardBgColor = isDarkMode ? AppTheme.neutral800 : Colors.white;
        final titleColor = isDarkMode ? Colors.white : AppTheme.neutral900;
        final subtitleColor = isDarkMode ? AppTheme.neutral400 : AppTheme.neutral600;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: cardBgColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  color: AppTheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
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
                        color: subtitleColor,
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
                activeTrackColor: AppTheme.primary.withValues(alpha: 0.3),
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
    final cardBgColor = isDarkMode ? AppTheme.neutral800 : Colors.white;

    return GestureDetector(
      onTap: () => _showLogoutConfirmation(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.error.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.logout,
              color: AppTheme.error,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Log Out',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.error,
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
              // Navigate to login page after logout
              context.go(AppRouter.login);
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

class _SettingsCard {
  final String svgIcon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  _SettingsCard({
    required this.svgIcon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}
