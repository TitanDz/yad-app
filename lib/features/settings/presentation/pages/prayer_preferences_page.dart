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
    return Column(
      children: [
        AppBar(
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
        Expanded(
          child: Material(
            color: AppTheme.purity,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Select Prayers Section
                    Text(
                      'Select Prayers',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Shacharit
                    _buildPrayerOption(
                      title: 'Shacharit',
                      value: _selectedPrayers.contains('Shacharit'),
                      onChanged: (value) {
                        setState(() {
                          if (value ?? false) {
                            _selectedPrayers.clear();
                            _selectedPrayers.add('Shacharit');
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 12),

                    // Mincha
                    _buildPrayerOption(
                      title: 'Mincha',
                      value: _selectedPrayers.contains('Mincha'),
                      onChanged: (value) {
                        setState(() {
                          if (value ?? false) {
                            _selectedPrayers.clear();
                            _selectedPrayers.add('Mincha');
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 12),

                    // Maariv
                    _buildPrayerOption(
                      title: 'Maariv',
                      value: _selectedPrayers.contains('Maariv'),
                      onChanged: (value) {
                        setState(() {
                          if (value ?? false) {
                            _selectedPrayers.clear();
                            _selectedPrayers.add('Maariv');
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 32),

                    // Alert Type Section
                    Text(
                      'Alert Type',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Push Notification Toggle
                    _buildAlertTypeOption(
                      title: 'Push Notification',
                      value: _selectedAlertType == 'Push Notification',
                      onChanged: (value) {
                        setState(() => _selectedAlertType = 'Push Notification');
                      },
                    ),
                    const SizedBox(height: 12),

                    // Email Toggle
                    _buildAlertTypeOption(
                      title: 'Email',
                      value: _selectedAlertType == 'Email',
                      onChanged: (value) {
                        setState(() => _selectedAlertType = 'Email');
                      },
                    ),
                    const SizedBox(height: 32),

                    // Time Format Section
                    Text(
                      'Time Format',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Time Format Buttons
                    Row(
                      children: [
                        Expanded(
                          child: _buildTimeFormatButton(
                            label: '12 hours',
                            icon: Icons.schedule,
                            isSelected: _selectedTimeFormat == '12h',
                            onPressed: () {
                              setState(() => _selectedTimeFormat = '12h');
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTimeFormatButton(
                            label: '24 hours',
                            icon: Icons.schedule,
                            isSelected: _selectedTimeFormat == '24h',
                            onPressed: () {
                              setState(() => _selectedTimeFormat = '24h');
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Preferences saved!'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
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
          ),
        ),
      ],
    );
  }

  Widget _buildPrayerOption({
    required String title,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.celestial.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          Radio<bool>(
            value: true,
            groupValue: value,
            onChanged: onChanged,
            activeColor: AppTheme.primary,
            fillColor: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.selected)) {
                return AppTheme.primary;
              }
              return Colors.grey[300];
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertTypeOption({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.celestial.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
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

  Widget _buildTimeFormatButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected ? AppTheme.primary : AppTheme.purity,
        side: BorderSide(
          color: isSelected ? AppTheme.primary : AppTheme.neutral300,
          width: 1,
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.white : AppTheme.neutral600,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : AppTheme.neutral900,
            ),
          ),
        ],
      ),
    );
  }
}
