import 'package:yad_app/core/local_storage/isar_service.dart';
import 'package:yad_app/core/models/user_preferences.dart';
import 'package:yad_app/core/services/user_preferences_manager.dart';

/// Service responsible for initializing app after user login
class AppInitializationService {
  final IsarService _isarService;
  static final Map<String, UserPreferences> _preferencesCache = {};

  AppInitializationService(this._isarService);

  /// Initialize app after successful login
  /// Returns the created UserPreferences
  Future<UserPreferences> initializeAfterLogin(String userId) async {
    try {
      // Create auto-detected preferences
      final preferences = await UserPreferencesManager.createAutoPreferences(userId);
      
      // Merge with defaults to ensure all fields are set
      final mergedPreferences = UserPreferencesManager.mergeWithDefaults(preferences);
      
      // Cache in memory
      _preferencesCache[userId] = mergedPreferences;
      
      // Try to save to local storage (Isar schema to be implemented)
      try {
        // Future enhancement: await _savePreferences(mergedPreferences);
      } catch (e) {
        // Local storage might not be available, but app should continue
        print('[AppInitializationService] Failed to save preferences locally: $e');
      }

      return mergedPreferences;
    } catch (e) {
      // Fallback to basic preferences with defaults
      return UserPreferences(
        userId: userId,
        timeZone: 'America/New_York',
        visibility: 'Active',
        searchRadiusMiles: 10,
        homeZone: 'Home',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }

  /// Get cached preferences or null
  Future<UserPreferences?> getCachedPreferences(String userId) async {
    if (_preferencesCache.containsKey(userId)) {
      return _preferencesCache[userId];
    }
    // Future: Load from Isar when schema is implemented
    return null;
  }

  /// Update preferences in cache
  Future<void> updatePreferences(UserPreferences preferences) async {
    _preferencesCache[preferences.userId] = preferences;
    // Future: Update in Isar when schema is implemented
  }
}