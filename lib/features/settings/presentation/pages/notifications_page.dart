import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yad_app/config/theme.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _newMinyahAlerts = true;
  bool _minyahUpdates = true;
  bool _appAnnouncements = true;
  bool _sound = false;
  bool _vibration = false;
  bool _quietHours = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
            onPressed: () => context.pop(),
          ),
          title: const Text(
            'Notifications',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Material(
            color: AppTheme.purity,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Minyan Alerts Section
                    Text(
                      'Minyan Alerts',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // New Minyan Alerts
                    _buildNotificationToggleItem(
                      title: 'New Minyan Alerts',
                      subtitle: 'Receive notifications when a new Minyan is created near you.',
                      value: _newMinyahAlerts,
                      onChanged: (value) {
                        setState(() => _newMinyahAlerts = value);
                      },
                    ),
                    const SizedBox(height: 12),

                    // Minyan Updates
                    _buildNotificationToggleItem(
                      title: 'Minyan Updates',
                      subtitle: 'Get updates on Minyan details, such as time changes or cancellations.',
                      value: _minyahUpdates,
                      onChanged: (value) {
                        setState(() => _minyahUpdates = value);
                      },
                    ),
                    const SizedBox(height: 28),

                    // App Updates Section
                    Text(
                      'App Updates',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // App Announcements
                    _buildNotificationToggleItem(
                      title: 'App Announcements',
                      subtitle: 'Stay informed about new features, improvements, and important announcements.',
                      value: _appAnnouncements,
                      onChanged: (value) {
                        setState(() => _appAnnouncements = value);
                      },
                    ),
                    const SizedBox(height: 28),

                    // Notification Preferences Section
                    Text(
                      'Notification Preferences',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Sound
                    _buildNotificationToggleItem(
                      title: 'Sound',
                      subtitle: '',
                      value: _sound,
                      onChanged: (value) {
                        setState(() => _sound = value);
                      },
                    ),
                    const SizedBox(height: 12),

                    // Vibration
                    _buildNotificationToggleItem(
                      title: 'Vibration',
                      subtitle: '',
                      value: _vibration,
                      onChanged: (value) {
                        setState(() => _vibration = value);
                      },
                    ),
                    const SizedBox(height: 12),

                    // Quiet Hours
                    _buildNotificationToggleItem(
                      title: 'Quiet Hours',
                      subtitle: 'Mute notifications during specific hours.',
                      value: _quietHours,
                      onChanged: (value) {
                        setState(() => _quietHours = value);
                      },
                    ),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationToggleItem({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.celestial.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primary,
            thumbColor: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.selected)) {
                return Colors.white;
              }
              return Colors.white;
            }),
            trackColor: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.selected)) {
                return AppTheme.primary;
              }
              return AppTheme.celestial.withValues(alpha: 0.3);
            }),
          ),
        ],
      ),
    );
  }
}
