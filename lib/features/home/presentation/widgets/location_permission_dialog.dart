import 'package:flutter/material.dart';
import 'package:yad_app/config/theme.dart';

class LocationPermissionDialog extends StatelessWidget {
  final VoidCallback onAllow;
  final VoidCallback onDeny;

  const LocationPermissionDialog({
    super.key,
    required this.onAllow,
    required this.onDeny,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: const Text(
        'Location Permission',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: AppTheme.neutral900,
        ),
      ),
      content: const Text(
        'This app needs access to your location to show nearby places and provide better search results. Your location data is used only within the app.',
        style: TextStyle(
          color: AppTheme.neutral600,
          height: 1.5,
        ),
      ),
      actions: [
        TextButton(
          onPressed: onDeny,
          child: const Text(
            'Not Now',
            style: TextStyle(color: AppTheme.neutral500),
          ),
        ),
        ElevatedButton(
          onPressed: onAllow,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
          ),
          child: const Text(
            'Allow',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
