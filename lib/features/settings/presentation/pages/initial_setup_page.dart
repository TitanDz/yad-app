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
  final List<String> _languages = ['English', 'Hebrew', 'Spanish'];
  final List<String> _timeZones = [
    'America/New_York',
    'America/Chicago',
    'America/Denver',
    'America/Los_Angeles',
    'Europe/London',
    'Europe/Paris',
    'Asia/Tokyo',
  ];
  final List<String> _visibilityOptions = ['Active', 'Invisible'];

  late String _selectedLanguage;
  late String _selectedTimeZone;
  late String _selectedVisibility;
  late int _searchRadius;
  late String _homeZone;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = 'English';
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
            language: _selectedLanguage,
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppTheme.neutral900),
          onPressed: () => context.pop(),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              const Text(
                'Initial Setup',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.neutral900,
                ),
              ),
              const SizedBox(height: 32),

              // Language Section
              const Text(
                'Language',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.neutral900,
                ),
              ),
              const SizedBox(height: 16),
              ..._languages.map(
                (language) => LanguageOption(
                  label: language,
                  isSelected: _selectedLanguage == language,
                  onTap: () {
                    setState(() => _selectedLanguage = language);
                  },
                ),
              ),
              const SizedBox(height: 32),

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
                  border: Border.all(color: AppTheme.neutral300),
                  borderRadius: BorderRadius.circular(8),
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
              ..._visibilityOptions.asMap().entries.map(
                (entry) {
                  final label = entry.value;
                  final isActive = label == 'Active';
                  final description = isActive
                      ? 'Visible to other users'
                      : 'Invisible to other users';

                  return VisibilityOption(
                    label: label,
                    description: description,
                    isSelected: _selectedVisibility == label,
                    onTap: () {
                      setState(() => _selectedVisibility = label);
                    },
                  );
                },
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
              const SizedBox(height: 8),
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
                  hintText: 'Enter Home Zone',
                  filled: true,
                  fillColor: AppTheme.neutral100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
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
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    disabledBackgroundColor: AppTheme.neutral400,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
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

class LanguageOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const LanguageOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.neutral300,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? AppTheme.primaryLight : Colors.transparent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: AppTheme.neutral900,
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppTheme.primary : AppTheme.neutral400,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.primary,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
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
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.neutral300,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? AppTheme.primaryLight : Colors.transparent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: AppTheme.neutral900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.neutral600,
                  ),
                ),
              ],
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppTheme.primary : AppTheme.neutral400,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.primary,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
