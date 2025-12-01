import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:yad_app/core/models/user_preferences.dart';

/// Service for auto-detecting and managing user preferences
class UserPreferencesManager {
  static const String _defaultTimeZone = 'America/New_York';
  static const String _defaultHomeZone = 'Home';
  static const String _defaultVisibility = 'Active';
  static const int _defaultSearchRadius = 10;

  /// Auto-detect timezone from device
  static String detectTimeZone() {
    try {
      final now = DateTime.now();
      final offset = now.timeZoneOffset;
      
      // Get system timezone name (simplified approach)
      // In production, you might want to use timezone package to be more precise
      final offsetHours = offset.inHours;
      
      // Simple timezone mapping based on offset
      // You can expand this with more comprehensive mapping
      final timeZoneMap = {
        -5: 'America/New_York',
        -6: 'America/Chicago',
        -7: 'America/Denver',
        -8: 'America/Los_Angeles',
        0: 'Europe/London',
        1: 'Europe/Paris',
        9: 'Asia/Tokyo',
      };
      
      return timeZoneMap[offsetHours] ?? _defaultTimeZone;
    } catch (e) {
      return _defaultTimeZone;
    }
  }

  /// Get current device location with fallback
  static Future<Map<String, dynamic>?> detectLocation() async {
    try {
      // Check if location services are enabled
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        return null;
      }

      // Check permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        return null;
      }

      // Get current position
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      // Try to get address from coordinates
      String address = '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          address = '${place.locality ?? ''}, ${place.administrativeArea ?? ''}'.trim();
          if (address.endsWith(',')) {
            address = address.substring(0, address.length - 1);
          }
        }
      } catch (e) {
        // Fallback to coordinates
      }

      return {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'address': address,
        'accuracy': position.accuracy,
      };
    } catch (e) {
      return null;
    }
  }

  /// Create UserPreferences from auto-detected values
  static Future<UserPreferences> createAutoPreferences(String userId) async {
    final timeZone = detectTimeZone();
    final locationData = await detectLocation();

    return UserPreferences(
      userId: userId,
      timeZone: timeZone,
      latitude: locationData?['latitude'] as double?,
      longitude: locationData?['longitude'] as double?,
      address: locationData?['address'] as String?,
      visibility: _defaultVisibility,
      searchRadiusMiles: _defaultSearchRadius,
      homeZone: _defaultHomeZone,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Merge user preferences with defaults
  static UserPreferences mergeWithDefaults(UserPreferences preferences) {
    return UserPreferences(
      userId: preferences.userId,
      timeZone: preferences.timeZone ?? _defaultTimeZone,
      latitude: preferences.latitude,
      longitude: preferences.longitude,
      address: preferences.address,
      visibility: preferences.visibility.isEmpty ? _defaultVisibility : preferences.visibility,
      searchRadiusMiles: preferences.searchRadiusMiles <= 0 ? _defaultSearchRadius : preferences.searchRadiusMiles,
      homeZone: preferences.homeZone?.isEmpty ?? true ? _defaultHomeZone : preferences.homeZone,
      createdAt: preferences.createdAt,
      updatedAt: preferences.updatedAt,
      isUnavailable: preferences.isUnavailable,
      unavailableUntil: preferences.unavailableUntil,
    );
  }

  /// Request location permission and update preferences
  static Future<bool> requestLocationPermissionAndUpdate(
    UserPreferences preferences,
    Function(UserPreferences) onUpdate,
  ) async {
    try {
      final permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        final locationData = await detectLocation();
        if (locationData != null) {
          final updated = preferences.copyWith(
            latitude: locationData['latitude'] as double?,
            longitude: locationData['longitude'] as double?,
            address: locationData['address'] as String?,
            updatedAt: DateTime.now(),
          );
          onUpdate(updated);
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
