import 'dart:math' as math;

/// Represents a geographic point
class GeoPoint {
  final double latitude;
  final double longitude;

  GeoPoint({required this.latitude, required this.longitude});
}

/// Service for calculating centroids and distances between geographic points
class CentroidCalculationService {
  static const double EARTH_RADIUS_KM = 6371.0;

  /// Calculate the geographic centroid (center point) of multiple locations
  /// Uses spherical average method for better accuracy on Earth's surface
  static GeoPoint calculateCentroid(List<GeoPoint> points) {
    if (points.isEmpty) {
      throw ArgumentError('Cannot calculate centroid of empty list');
    }

    if (points.length == 1) {
      return points.first;
    }

    // Convert to radians
    final lats = points.map((p) => _toRadians(p.latitude)).toList();
    final lons = points.map((p) => _toRadians(p.longitude)).toList();

    // Calculate Cartesian coordinates
    double x = 0, y = 0, z = 0;

    for (int i = 0; i < points.length; i++) {
      x += math.cos(lats[i]) * math.cos(lons[i]);
      y += math.cos(lats[i]) * math.sin(lons[i]);
      z += math.sin(lats[i]);
    }

    x /= points.length;
    y /= points.length;
    z /= points.length;

    // Convert back to geographic coordinates
    final lon = math.atan2(y, x);
    final hyp = math.sqrt(x * x + y * y);
    final lat = math.atan2(z, hyp);

    return GeoPoint(
      latitude: _toDegrees(lat),
      longitude: _toDegrees(lon),
    );
  }

  /// Calculate Haversine distance between two points in kilometers
  static double calculateDistance(GeoPoint point1, GeoPoint point2) {
    final lat1 = _toRadians(point1.latitude);
    final lon1 = _toRadians(point1.longitude);
    final lat2 = _toRadians(point2.latitude);
    final lon2 = _toRadians(point2.longitude);

    final dLat = lat2 - lat1;
    final dLon = lon2 - lon1;

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) * math.cos(lat2) * math.sin(dLon / 2) * math.sin(dLon / 2);

    final c = 2 * math.asin(math.sqrt(a));
    return EARTH_RADIUS_KM * c;
  }

  /// Calculate average distance from a point to multiple other points
  static double calculateAverageDistance(GeoPoint center, List<GeoPoint> points) {
    if (points.isEmpty) return 0;

    double totalDistance = 0;
    for (final point in points) {
      totalDistance += calculateDistance(center, point);
    }

    return totalDistance / points.length;
  }

  /// Get distances from a location to all other points
  static Map<int, double> getDistancesFromPoint(GeoPoint point, List<GeoPoint> otherPoints) {
    final distances = <int, double>{};
    for (int i = 0; i < otherPoints.length; i++) {
      distances[i] = calculateDistance(point, otherPoints[i]);
    }
    return distances;
  }

  /// Calculate bounding box for a set of points (useful for map bounds)
  static Map<String, double> calculateBoundingBox(List<GeoPoint> points) {
    if (points.isEmpty) {
      return {
        'north': 0,
        'south': 0,
        'east': 0,
        'west': 0,
      };
    }

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLon = points.first.longitude;
    double maxLon = points.first.longitude;

    for (final point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLon) minLon = point.longitude;
      if (point.longitude > maxLon) maxLon = point.longitude;
    }

    return {
      'north': maxLat,
      'south': minLat,
      'east': maxLon,
      'west': minLon,
    };
  }

  /// Convert degrees to radians
  static double _toRadians(double degrees) {
    return degrees * math.pi / 180.0;
  }

  /// Convert radians to degrees
  static double _toDegrees(double radians) {
    return radians * 180.0 / math.pi;
  }

  /// Validate if coordinates are within valid ranges
  static bool isValidCoordinate(double latitude, double longitude) {
    return latitude >= -90 && latitude <= 90 && longitude >= -180 && longitude <= 180;
  }

  /// Get human-readable distance string
  static String formatDistance(double distanceKm) {
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).toStringAsFixed(0)}m';
    } else if (distanceKm < 10) {
      return '${distanceKm.toStringAsFixed(2)}km';
    } else {
      return '${distanceKm.toStringAsFixed(1)}km';
    }
  }
}
