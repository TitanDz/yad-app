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
class MockActiveUsersDataSource implements ActiveUsersDataSource {
  @override
  Future<List<ActiveUserMarker>> getNearbyActiveUsers({
    required double latitude,
    required double longitude,
    required double radiusKm,
  }) async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Return mock data of nearby active users
    return [
      ActiveUserMarker(
        userId: 'user_001',
        name: 'David',
        latitude: latitude + 0.005,
        longitude: longitude + 0.005,
        address: 'West Side Synagogue',
        isAvailable: true,
        minutesUnavailable: 0,
        lastPrayerType: 'Mincha',
        distance: 0.3,
      ),
      ActiveUserMarker(
        userId: 'user_002',
        name: 'Rachel',
        latitude: latitude - 0.004,
        longitude: longitude + 0.006,
        address: 'Fifth Avenue Synagogue',
        isAvailable: true,
        minutesUnavailable: 0,
        lastPrayerType: 'Shacharit',
        distance: 0.5,
      ),
      ActiveUserMarker(
        userId: 'user_003',
        name: 'Michael',
        latitude: latitude + 0.002,
        longitude: longitude - 0.007,
        address: 'Park Avenue Synagogue',
        isAvailable: false,
        minutesUnavailable: 12,
        lastPrayerType: 'Mincha',
        distance: 0.6,
      ),
      ActiveUserMarker(
        userId: 'user_004',
        name: 'Sarah',
        latitude: latitude + 0.008,
        longitude: longitude - 0.003,
        address: 'Shearith Israel',
        isAvailable: true,
        minutesUnavailable: 0,
        lastPrayerType: 'Maariv',
        distance: 0.4,
      ),
    ];
  }

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
