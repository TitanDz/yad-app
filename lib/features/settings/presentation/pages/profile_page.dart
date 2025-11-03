import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yad_app/config/router.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

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
          'Profile',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),

            // Profile Avatar - Centered
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFAE5D3),
                  border: Border.all(
                    color: const Color(0xFFE8C7A0),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFFAE5D3),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 60,
                      color: Color(0xFF8B6F47),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // User Info Section - Centered
            Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Name
                  const Text(
                    'Ethan',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Member Since
                  Text(
                    'Member since 2022',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Personal Information Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Personal Information',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Email
                  _buildInfoItem(
                    label: 'Email',
                    value: 'ethan@email.com',
                    context: context,
                  ),
                  const SizedBox(height: 20),

                  // Phone Number
                  _buildInfoItem(
                    label: 'Phone Number',
                    value: '+1 (555) 123-4567',
                    context: context,
                  ),
                  const SizedBox(height: 20),

                  // Location
                  _buildInfoItem(
                    label: 'Location',
                    value: 'New York, NY',
                    context: context,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Community Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Community',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Synagogue
                  _buildInfoItem(
                    label: 'Synagogue',
                    value: 'Congregation Beth Shalom',
                    context: context,
                  ),
                  const SizedBox(height: 20),

                  // Denomination
                  _buildInfoItem(
                    label: 'Denomination',
                    value: 'Orthodox',
                    context: context,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Settings Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Notifications
                  _buildSettingItem(
                    label: 'Notifications',
                    onTap: () {
                      context.push(AppRouter.notifications);
                    },
                    context: context,
                  ),
                  const SizedBox(height: 12),

                  // Privacy
                  _buildSettingItem(
                    label: 'Privacy',
                    onTap: () {
                      // TODO: Navigate to privacy settings
                    },
                    context: context,
                  ),
                  const SizedBox(height: 12),

                  // Minyan History
                  _buildSettingItem(
                    label: 'Minyan History',
                    onTap: () {
                      // TODO: Navigate to minyan history
                    },
                    context: context,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required String label,
    required String value,
    required BuildContext context,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingItem({
    required String label,
    required VoidCallback onTap,
    required BuildContext context,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
