import 'package:yad_app/features/settings/domain/models/settings_model.dart';

/// Abstract settings datasource interface
abstract class SettingsDataSource {
  Future<SettingsModel> getSettings();
  Future<void> saveSettings(SettingsModel settings);
}

/// Mock settings datasource with in-memory persistence
class MockSettingsDataSource implements SettingsDataSource {
  static const int _apiDelayMs = 1000;

  // In-memory cache for settings
  static SettingsModel? _cachedSettings;

  @override
  Future<SettingsModel> getSettings() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: _apiDelayMs));

    // Return cached settings or defaults
    if (_cachedSettings != null) {
      return _cachedSettings!;
    }

    // Return default settings if not found
    _cachedSettings = SettingsModel.defaultSettings();
    return _cachedSettings!;
  }

  @override
  Future<void> saveSettings(SettingsModel settings) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: _apiDelayMs));

    // Save to in-memory cache
    _cachedSettings = settings;

    // In real API, would save to backend and persistent storage
  }

  /// Get settings from cache only (no API delay)
  SettingsModel getSettingsSync() {
    return _cachedSettings ?? SettingsModel.defaultSettings();
  }

  /// Clear all settings (for testing/logout)
  void clearSettings() {
    _cachedSettings = null;
  }
}
