import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:yad_app/features/home/domain/entities/active_user_marker.dart';

/// Data source for fetching nearby active users
abstract class ActiveUsersDataSource {
  Future<List<ActiveUserMarker>> getNearbyActiveUsers({
    required double latitude,
    required double longitude,
    required double radiusKm,
  });

  Future<List<ActiveUserMarker>> getActiveUsersSearching({
    required String prayerType,
    required double radiusKm,
  });
}

/// Mock implementation of ActiveUsersDataSource
/// Enhanced with 15+ test users to support minyan formation testing
class MockActiveUsersDataSource implements ActiveUsersDataSource {
  /// Static list of all available test users
  /// Expanded for comprehensive testing scenarios
  static final List<ActiveUserMarker> _allTestUsers = [
    // Group 1: Immediately available users (0.2 - 0.5 km)
    ActiveUserMarker(
      userId: 'user_001',
      name: 'David',
      latitude: 40.7128, // NYC baseline
      longitude: -74.0060,
      address: 'West Side Synagogue',
      isAvailable: true,
      minutesUnavailable: 0,
      lastPrayerType: 'Mincha',
      distance: 0.2,
    ),
    ActiveUserMarker(
      userId: 'user_002',
      name: 'Rachel',
      latitude: 40.7165,
      longitude: -74.0028,
      address: 'Fifth Avenue Synagogue',
      isAvailable: true,
      minutesUnavailable: 0,
      lastPrayerType: 'Mincha',
      distance: 0.4,
    ),
    ActiveUserMarker(
      userId: 'user_003',
      name: 'Michael',
      latitude: 40.7130,
      longitude: -74.0090,
      address: 'Park Avenue Synagogue',
      isAvailable: true,
      minutesUnavailable: 0,
      lastPrayerType: 'Mincha',
      distance: 0.3,
    ),
    ActiveUserMarker(
      userId: 'user_004',
      name: 'Sarah',
      latitude: 40.7095,
      longitude: -74.0050,
      address: 'Shearith Israel',
      isAvailable: true,
      minutesUnavailable: 0,
      lastPrayerType: 'Mincha',
      distance: 0.35,
    ),
    // Group 2: Unavailable users (temporarily busy)
    ActiveUserMarker(
      userId: 'user_005',
      name: 'Aaron',
      latitude: 40.7140,
      longitude: -74.0070,
      address: 'Congregation Kehilath Jeshurun',
      isAvailable: false,
      minutesUnavailable: 8,
      lastPrayerType: 'Mincha',
      distance: 0.25,
    ),
    ActiveUserMarker(
      userId: 'user_006',
      name: 'Miriam',
      latitude: 40.7110,
      longitude: -74.0040,
      address: 'Central Synagogue',
      isAvailable: false,
      minutesUnavailable: 15,
      lastPrayerType: 'Mincha',
      distance: 0.2,
    ),
    // Group 3: More users searching Shacharit
    ActiveUserMarker(
      userId: 'user_007',
      name: 'Eli',
      latitude: 40.7150,
      longitude: -74.0030,
      address: 'Temple Beth Sholom',
      isAvailable: true,
      minutesUnavailable: 0,
      lastPrayerType: 'Shacharit',
      distance: 0.42,
    ),
    ActiveUserMarker(
      userId: 'user_008',
      name: 'Hannah',
      latitude: 40.7120,
      longitude: -74.0080,
      address: 'Congregation Anshe Sholom',
      isAvailable: true,
      minutesUnavailable: 0,
      lastPrayerType: 'Shacharit',
      distance: 0.38,
    ),
    // Group 4: More users for larger minyan (11+ threshold)
    ActiveUserMarker(
      userId: 'user_009',
      name: 'Jacob',
      latitude: 40.7135,
      longitude: -74.0065,
      address: 'Orach Chaim Congregation',
      isAvailable: true,
      minutesUnavailable: 0,
      lastPrayerType: 'Mincha',
      distance: 0.28,
    ),
    ActiveUserMarker(
      userId: 'user_010',
      name: 'Leah',
      latitude: 40.7105,
      longitude: -74.0045,
      address: 'Shearith Israel East',
      isAvailable: true,
      minutesUnavailable: 0,
      lastPrayerType: 'Mincha',
      distance: 0.31,
    ),
    ActiveUserMarker(
      userId: 'user_011',
      name: 'Joseph',
      latitude: 40.7125,
      longitude: -74.0075,
      address: 'Beth Jacob',
      isAvailable: true,
      minutesUnavailable: 0,
      lastPrayerType: 'Mincha',
      distance: 0.32,
    ),
    // Group 5: Additional users to reach 15+
    ActiveUserMarker(
      userId: 'user_012',
      name: 'Ruth',
      latitude: 40.7145,
      longitude: -74.0025,
      address: 'Congregation Bnai Jeshurun',
      isAvailable: true,
      minutesUnavailable: 0,
      lastPrayerType: 'Mincha',
      distance: 0.41,
    ),
    ActiveUserMarker(
      userId: 'user_013',
      name: 'Samuel',
      latitude: 40.7115,
      longitude: -74.0085,
      address: 'Chabads NYC',
      isAvailable: true,
      minutesUnavailable: 0,
      lastPrayerType: 'Maariv',
      distance: 0.37,
    ),
    ActiveUserMarker(
      userId: 'user_014',
      name: 'Esther',
      latitude: 40.7130,
      longitude: -74.0055,
      address: 'Orthodox Shul',
      isAvailable: true,
      minutesUnavailable: 0,
      lastPrayerType: 'Mincha',
      distance: 0.33,
    ),
    ActiveUserMarker(
      userId: 'user_015',
      name: 'Benjamin',
      latitude: 40.7110,
      longitude: -74.0075,
      address: 'Young Israel of Manhattan',
      isAvailable: true,
      minutesUnavailable: 0,
      lastPrayerType: 'Mincha',
      distance: 0.29,
    ),
  ];

  @override
  Future<List<ActiveUserMarker>> getNearbyActiveUsers({
    required double latitude,
    required double longitude,
    required double radiusKm,
  }) async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Filter users within radius and adjust their distances based on user location
    final nearbyUsers = _allTestUsers
        .where((user) => _calculateDistance(latitude, longitude, user.latitude, user.longitude) <= radiusKm)
        .toList();
    
    debugPrint('📍 [MockActiveUsersDataSource] Found ${nearbyUsers.length} nearby users within ${radiusKm}km');
    return nearbyUsers;
  }

  /// Simple distance calculation for testing purposes
  /// In production, use proper Haversine formula
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double p = 0.017453292519943295;
    final double a = 0.5 - ((cos((lat2 - lat1) * p)) / 2) +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  /// Get all test users (for debugging)
  static List<ActiveUserMarker> getAllTestUsers() => _allTestUsers;

  @override
  Future<List<ActiveUserMarker>> getActiveUsersSearching({
    required String prayerType,
    required double radiusKm,
  }) async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Return mock users searching for specific prayer type
    return [
      ActiveUserMarker(
        userId: 'user_005',
        name: 'Aaron',
        latitude: 40.7128,
        longitude: -74.0060,
        address: 'Congregation Kehilath Jeshurun',
        isAvailable: true,
        minutesUnavailable: 0,
        lastPrayerType: prayerType,
        distance: 0.2,
      ),
      // ActiveUserMarker(
      //   userId: 'user_006',
      //   name: 'Miriam',
      //   latitude: 40.7180,
      //   longitude: -73.9950,
      //   address: 'Central Synagogue',
      //   isAvailable: true,
      //   minutesUnavailable: 0,
      //   lastPrayerType: prayerType,
      //   distance: 0.8,
      // ),
    ];
  }
}

/// Real API implementation (when backend is ready)
class RemoteActiveUsersDataSource implements ActiveUsersDataSource {
  @override
  Future<List<ActiveUserMarker>> getNearbyActiveUsers({
    required double latitude,
    required double longitude,
    required double radiusKm,
  }) async {
    // TODO: Implement API call to backend
    // GET /api/users/nearby?lat={latitude}&lng={longitude}&radius={radiusKm}
    throw UnimplementedError('Remote data source not yet implemented');
  }

  @override
  Future<List<ActiveUserMarker>> getActiveUsersSearching({
    required String prayerType,
    required double radiusKm,
  }) async {
    // TODO: Implement API call to backend
    // GET /api/users/searching?prayerType={prayerType}&radius={radiusKm}
    throw UnimplementedError('Remote data source not yet implemented');
  }
}
