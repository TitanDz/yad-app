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
    return Scaffold(
      appBar: AppBar(
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Minyan Alerts Section
              Text(
                'Minyan Alerts',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),

              // New Minyan Alerts
              _buildNotificationToggleItem(
                title: 'New Minyan Alerts',
                subtitle: 'Receive notifications when a new Minyan is created near you.',
                value: _newMinyahAlerts,
                onChanged: (value) {
                  setState(() => _newMinyahAlerts = value);
                },
              ),
              const SizedBox(height: 16),

              // Minyan Updates
              _buildNotificationToggleItem(
                title: 'Minyan Updates',
                subtitle: 'Get updates on Minyan details, such as time changes or cancellations.',
                value: _minyahUpdates,
                onChanged: (value) {
                  setState(() => _minyahUpdates = value);
                },
              ),
              const SizedBox(height: 32),

              // App Updates Section
              Text(
                'App Updates',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),

              // App Announcements
              _buildNotificationToggleItem(
                title: 'App Announcements',
                subtitle: 'Stay informed about new features, improvements, and important',
                value: _appAnnouncements,
                onChanged: (value) {
                  setState(() => _appAnnouncements = value);
                },
              ),
              const SizedBox(height: 32),

              // Notification Preferences Section
              Text(
                'Notification Preferences',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),

              // Sound
              _buildNotificationToggleItem(
                title: 'Sound',
                subtitle: '',
                value: _sound,
                onChanged: (value) {
                  setState(() => _sound = value);
                },
              ),
              const SizedBox(height: 16),

              // Vibration
              _buildNotificationToggleItem(
                title: 'Vibration',
                subtitle: '',
                value: _vibration,
                onChanged: (value) {
                  setState(() => _vibration = value);
                },
              ),
              const SizedBox(height: 16),

              // Quiet Hours
              _buildNotificationToggleItem(
                title: 'Quiet Hours',
                subtitle: 'Mute notifications during specific hours.',
                value: _quietHours,
                onChanged: (value) {
                  setState(() => _quietHours = value);
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationToggleItem({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
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
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 16),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppTheme.primary,
        ),
      ],
    );
  }
}
