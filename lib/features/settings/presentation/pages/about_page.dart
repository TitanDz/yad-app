import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yad_app/config/theme.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

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
            'About Us',
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Our Mission Section
                    Text(
                      'Our Mission',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'The10th is dedicated to fostering a stronger Jewish community by making it easier for individuals to find and participate in prayer services.',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Our app connects users with nearby minyans, ensuring everyone has access to communal prayer opportunities.',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // The Team Section
                    Text(
                      'The Team',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'The10th was developed by a passionate team of individuals committed to enhancing Jewish life through technology. Our team includes experienced developers, community leaders, and dedicated volunteers.',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Legal Information Section
                    Text(
                      'Legal Information',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildLegalItem(
                      title: 'Terms of Service',
                      context: context,
                      onTap: () {},
                    ),
                    const SizedBox(height: 16),

                    _buildLegalItem(
                      title: 'Privacy Policy',
                      context: context,
                      onTap: () {},
                    ),
                    const SizedBox(height: 32),

                    // Privacy Policy Section
                    Text(
                      'Privacy Policy',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'At The10th, we prioritize your privacy. We collect minimal data necessary for app functionality, such as location for minyan searches. Your data is securely stored and never shared with third parties without your explicit consent. We employ industry-standard security measures to protect your information. For detailed information, please refer to our full Privacy Policy.',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegalItem({
    required String title,
    required BuildContext context,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.celestial.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: AppTheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}
