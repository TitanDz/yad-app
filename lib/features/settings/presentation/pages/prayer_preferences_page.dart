import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yad_app/config/theme.dart';

class PrayerPreferencesPage extends StatefulWidget {
  const PrayerPreferencesPage({super.key});

  @override
  State<PrayerPreferencesPage> createState() => _PrayerPreferencesPageState();
}

class _PrayerPreferencesPageState extends State<PrayerPreferencesPage> {
  late Set<String> _selectedPrayers;
  late String _selectedAlertType;
  late String _selectedTimeFormat;

  @override
  void initState() {
    super.initState();
    _selectedPrayers = {'Shacharit'};
    _selectedAlertType = 'Push Notification';
    _selectedTimeFormat = '12h';
  }

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
          'Prayer Preferences',
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
              // Select Prayers Section
              Text(
                'Select Prayers',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),

              // Shacharit
              _buildPrayerCheckbox(
                title: 'Shacharit',
                value: _selectedPrayers.contains('Shacharit'),
                onChanged: (value) {
                  setState(() {
                    if (value ?? false) {
                      _selectedPrayers.add('Shacharit');
                    } else {
                      _selectedPrayers.remove('Shacharit');
                    }
                  });
                },
              ),
              const SizedBox(height: 12),

              // Mincha
              _buildPrayerCheckbox(
                title: 'Mincha',
                value: _selectedPrayers.contains('Mincha'),
                onChanged: (value) {
                  setState(() {
                    if (value ?? false) {
                      _selectedPrayers.add('Mincha');
                    } else {
                      _selectedPrayers.remove('Mincha');
                    }
                  });
                },
              ),
              const SizedBox(height: 12),

              // Maariv
              _buildPrayerCheckbox(
                title: 'Maariv',
                value: _selectedPrayers.contains('Maariv'),
                onChanged: (value) {
                  setState(() {
                    if (value ?? false) {
                      _selectedPrayers.add('Maariv');
                    } else {
                      _selectedPrayers.remove('Maariv');
                    }
                  });
                },
              ),
              const SizedBox(height: 32),

              // Alert Type Section
              Text(
                'Alert Type',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),

              // Button Group
              Row(
                children: [
                  Expanded(
                    child: _buildAlertTypeButton(
                      label: 'Push Notification',
                      isSelected: _selectedAlertType == 'Push Notification',
                      onPressed: () {
                        setState(() => _selectedAlertType = 'Push Notification');
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildAlertTypeButton(
                      label: 'Email',
                      isSelected: _selectedAlertType == 'Email',
                      onPressed: () {
                        setState(() => _selectedAlertType = 'Email');
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Time Format Section
              Text(
                'Time Format',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),

              // Time Format Buttons
              Row(
                children: [
                  Expanded(
                    child: _buildTimeFormatButton(
                      label: '12h',
                      isSelected: _selectedTimeFormat == '12h',
                      onPressed: () {
                        setState(() => _selectedTimeFormat = '12h');
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTimeFormatButton(
                      label: '24h',
                      isSelected: _selectedTimeFormat == '24h',
                      onPressed: () {
                        setState(() => _selectedTimeFormat = '24h');
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Save preferences
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Preferences saved!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Save Preferences',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrayerCheckbox({
    required String title,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: AppTheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }

  Widget _buildAlertTypeButton({
    required String label,
    required bool isSelected,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected ? AppTheme.primaryLight : null,
        side: BorderSide(
          color: isSelected ? AppTheme.primary : AppTheme.neutral300,
          width: 2,
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isSelected ? AppTheme.primary : AppTheme.neutral600,
        ),
      ),
    );
  }

  Widget _buildTimeFormatButton({
    required String label,
    required bool isSelected,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected ? AppTheme.primaryLight : null,
        side: BorderSide(
          color: isSelected ? AppTheme.primary : AppTheme.neutral300,
          width: 2,
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isSelected ? AppTheme.primary : AppTheme.neutral600,
        ),
      ),
    );
  }
}
