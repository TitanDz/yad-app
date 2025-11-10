import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yad_app/config/theme.dart';

class PasswordResetSuccessPage extends StatelessWidget {
  const PasswordResetSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 48),

            // Success Icon
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.success.withValues(alpha: 0.1),
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 50,
                  color: AppTheme.success,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Title
            const Text(
              'Password Reset',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.neutral600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Success Message
            const Text(
              'Password Reset Successful',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.neutral900,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Description
            const Text(
              'Your password has been successfully reset. You can now log in with your new credentials.',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.neutral600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),

            // Return to Login Button
            ElevatedButton(
              onPressed: () => context.go('/login'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Return to Login',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
