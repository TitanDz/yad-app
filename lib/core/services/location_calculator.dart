import 'dart:math';

/// LocationCalculator provides distance calculations using the Haversine formula
/// This ensures consistent distance calculations across the entire application
/// and allows seamless replication on the backend
class LocationCalculator {
  /// Earth's radius in kilometers
  static const double earthRadiusKm = 6371.0;

  /// Calculate the distance in kilometers between two geographic points
  /// using the Haversine formula.
  ///
  /// Parameters:
  /// - [lat1], [lon1]: User's latitude and longitude
  /// - [lat2], [lon2]: Target location's latitude and longitude
  ///
  /// Returns: Distance in kilometers (double)
  ///
  /// Example:
  /// ```dart
  /// double distance = LocationCalculator.calculateDistanceInKm(
  ///   40.7128, -74.0060,  // New York
  ///   34.0522, -118.2437  // Los Angeles
  /// );
  /// // Returns approximately 3944 km
  /// ```
  static double calculateDistanceInKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    // Convert latitude difference to radians
    final dLat = _degreesToRadians(lat2 - lat1);
    // Convert longitude difference to radians
    final dLon = _degreesToRadians(lon2 - lon1);

    // Haversine formula components
    final sinHalfDLat = sin(dLat / 2);
    final sinHalfDLon = sin(dLon / 2);

    // Calculate 'a' component
    final a = sinHalfDLat * sinHalfDLat +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sinHalfDLon *
            sinHalfDLon;

    // Calculate 'c' component
    final c = 2 * asin(sqrt(a));

    // Return distance in kilometers
    return earthRadiusKm * c;
  }

  /// Calculate distance in miles
  /// Convenience method that converts kilometers to miles
  static double calculateDistanceInMiles(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final distanceKm = calculateDistanceInKm(lat1, lon1, lat2, lon2);
    return distanceKm / 1.60934;
  }

  /// Convert degrees to radians
  /// Used internally by the Haversine formula
  static double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  /// Check if a point is within a specified radius
  /// Convenience method combining distance calculation and comparison
  static bool isWithinRadius(
    double userLat,
    double userLon,
    double targetLat,
    double targetLon,
    double radiusKm,
  ) {
    final distance = calculateDistanceInKm(
      userLat,
      userLon,
      targetLat,
      targetLon,
    );
    return distance <= radiusKm;
  }
}
