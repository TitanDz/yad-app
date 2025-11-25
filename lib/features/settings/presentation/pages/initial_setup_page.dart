import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:yad_app/config/theme.dart';
import 'package:yad_app/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:yad_app/features/settings/presentation/bloc/settings_event.dart';
import 'package:yad_app/features/settings/presentation/bloc/settings_state.dart';

class InitialSetupPage extends StatefulWidget {
  const InitialSetupPage({super.key});

  @override
  State<InitialSetupPage> createState() => _InitialSetupPageState();
}

class _InitialSetupPageState extends State<InitialSetupPage> {
  final List<String> _timeZones = [
    'America/New_York',
    'America/Chicago',
    'America/Denver',
    'America/Los_Angeles',
    'Europe/London',
    'Europe/Paris',
    'Asia/Tokyo',
  ];

  late String _selectedTimeZone;
  late String _selectedVisibility;
  late int _searchRadius;
  late String _homeZone;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedTimeZone = 'America/New_York';
    _selectedVisibility = 'Active';
    _searchRadius = 10;
    _homeZone = '';
  }

  void _handleSave() {
    if (_homeZone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your home zone'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    context.read<SettingsBloc>().add(
          SaveSettingsEvent(
            language: 'English',
            timeZone: _selectedTimeZone,
            visibility: _selectedVisibility,
            searchRadius: _searchRadius,
            homeZone: _homeZone,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.celestial,
      appBar: AppBar(
        backgroundColor: AppTheme.celestial,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppTheme.neutral400,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.arrow_back,
              color: AppTheme.neutral900,
              size: 20,
            ),
          ),
        ),
        centerTitle: true,
        title: const Text(
          'Initial Setup',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.neutral900,
          ),
        ),
      ),
      body: BlocListener<SettingsBloc, SettingsState>(
        listener: (context, state) {
          if (state is SettingsLoading) {
            setState(() => _isLoading = true);
          } else if (state is SettingsSaved) {
            setState(() => _isLoading = false);
            // Navigate to home and remove all previous routes
            context.go('/');
          } else if (state is SettingsFailure) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.error,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Time Zone Section
              const Text(
                'Time Zone',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.neutral900,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppTheme.neutral300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButton<String>(
                  value: _selectedTimeZone,
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: _timeZones
                      .map(
                        (tz) => DropdownMenuItem(
                          value: tz,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(tz),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedTimeZone = value);
                    }
                  },
                ),
              ),
              const SizedBox(height: 32),

              // Visibility Section
              const Text(
                'Visibility',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.neutral900,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: VisibilityOption(
                      label: 'Active',
                      description: 'Visible to other users',
                      isSelected: _selectedVisibility == 'Active',
                      onTap: () {
                        setState(() => _selectedVisibility = 'Active');
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: VisibilityOption(
                      label: 'Invisible',
                      description: 'Invisible to other users',
                      isSelected: _selectedVisibility == 'Invisible',
                      onTap: () {
                        setState(() => _selectedVisibility = 'Invisible');
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Search Radius Section
              const Text(
                'Search Radius',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.neutral900,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Radius'),
                        Text(
                          '$_searchRadius mi',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Slider(
                      value: _searchRadius.toDouble(),
                      min: 1,
                      max: 50,
                      divisions: 49,
                      activeColor: AppTheme.primary,
                      onChanged: (value) {
                        setState(() => _searchRadius = value.toInt());
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Home Zone Section
              const Text(
                'Home Zone',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.neutral900,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                onChanged: (value) {
                  setState(() => _homeZone = value);
                },
                decoration: InputDecoration(
                  hintText: 'Select Time Zone',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.neutral300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.neutral300),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    disabledBackgroundColor: AppTheme.neutral300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Save',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VisibilityOption extends StatelessWidget {
  final String label;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const VisibilityOption({
    required this.label,
    required this.description,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.neutral300,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? AppTheme.primary : Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  label == 'Active' ? Icons.visibility : Icons.visibility_off,
                  color: isSelected ? Colors.white : AppTheme.neutral600,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppTheme.neutral900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.8)
                    : AppTheme.neutral600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
