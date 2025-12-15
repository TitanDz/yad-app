import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Service to calculate routes and generate polylines for navigation
/// Integrates with Google Directions API for real road-based routing
class RoutingService {
  static const String _apiKey = 'AIzaSyD1_mZtNCy3Rbb-qD4sQQtUKd25VzdF8hI';
  static const String _directionsBaseUrl = 'https://maps.googleapis.com/maps/api/directions/json';

  /// Get route from Google Directions API
  /// Returns a list of LatLng points that form the actual road route
  Future<List<LatLng>?> getDirectionsRoute({
    required LatLng origin,
    required LatLng destination,
    String travelMode = 'driving', // driving, walking, bicycling, transit
  }) async {
    try {
      debugPrint('🛣️ Requesting directions from ${origin.latitude},${origin.longitude} to ${destination.latitude},${destination.longitude}');
      
      final String url = '$_directionsBaseUrl'
          '?origin=${origin.latitude},${origin.longitude}'
          '&destination=${destination.latitude},${destination.longitude}'
          '&mode=$travelMode'
          '&key=$_apiKey';

      debugPrint('🔗 API URL: $url');
      
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));

      debugPrint('📡 API Response Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        try {
          final json = jsonDecode(response.body);
          debugPrint('📦 API Response: ${json['status']}');
          
          if (json['status'] == 'OK' && (json['routes'] as List).isNotEmpty) {
            debugPrint('✅ Directions received with ${json['routes'].length} route(s)');
            
            // Get the first route (primary route)
            final route = json['routes'][0];
            final polylinePoints = route['overview_polyline']['points'] as String?;
            
            if (polylinePoints == null || polylinePoints.isEmpty) {
              debugPrint('⚠️ Polyline points are empty');
              return null;
            }
            
            // Decode the encoded polyline
            final routePoints = _decodePolyline(polylinePoints);
            
            debugPrint('📍 Route has ${routePoints.length} points');
            
            // Get distance and duration info
            if ((route['legs'] as List).isNotEmpty) {
              final leg = route['legs'][0];
              final distance = leg['distance']?['text'] ?? 'Unknown';
              final duration = leg['duration']?['text'] ?? 'Unknown';
              debugPrint('📊 Distance: $distance | Duration: $duration');
            }
            
            return routePoints;
          } else {
            final errorMsg = json['error_message'] ?? json['status'] ?? 'Unknown error';
            debugPrint('⚠️ No routes found: $errorMsg');
            return null;
          }
        } catch (parseError) {
          debugPrint('❌ JSON parse error: $parseError');
          debugPrint('📄 Response body: ${response.body}');
          return null;
        }
      } else {
        debugPrint('❌ API error: ${response.statusCode}');
        debugPrint('📄 Response: ${response.body}');
        return null;
      }
    } on TimeoutException {
      debugPrint('⏱️ API request timeout (10 seconds)');
      return null;
    } catch (e) {
      debugPrint('❌ Error getting directions: $e');
      return null;
    }
  }

  /// Decode polyline string returned by Google Directions API
  /// Google uses a proprietary polyline encoding algorithm
  List<LatLng> _decodePolyline(String polyline) {
    final List<LatLng> points = [];
    int index = 0, lat = 0, lng = 0;

    while (index < polyline.length) {
      int result = 0, shift = 0;
      int byte;
      
      // Decode latitude delta
      do {
        byte = polyline.codeUnitAt(index++) - 63;
        result |= (byte & 0x1f) << shift;
        shift += 5;
      } while (byte >= 0x20);
      
      int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      // Decode longitude delta
      result = 0;
      shift = 0;
      do {
        byte = polyline.codeUnitAt(index++) - 63;
        result |= (byte & 0x1f) << shift;
        shift += 5;
      } while (byte >= 0x20);
      
      int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      // Add decoded point to list
      points.add(LatLng(lat / 1e5, lng / 1e5));
    }
    return points;
  }

  /// Generate a polyline to be displayed on the map
  static Polyline createRoutePolyline({
    required String polylineId,
    required List<LatLng> points,
    Color color = const Color(0xFF4285F4), // Google Blue
    double width = 5.0,
    bool geodesic = false, // Use false for actual roads
  }) {
    return Polyline(
      polylineId: PolylineId(polylineId),
      points: points,
      color: color,
      width: width.toInt(),
      geodesic: geodesic,
      patterns: const [],
    );
  }

  /// Calculate distance in kilometers between two coordinates using Haversine formula
  /// Used for quick distance estimates without API calls
  static double calculateDistance(LatLng origin, LatLng destination) {
    const earthRadiusKm = 6371.0;

    final latDelta = _degreesToRadians(destination.latitude - origin.latitude);
    final lngDelta = _degreesToRadians(destination.longitude - origin.longitude);

    final a = math.sin(latDelta / 2) * math.sin(latDelta / 2) +
        math.cos(_degreesToRadians(origin.latitude)) *
            math.cos(_degreesToRadians(destination.latitude)) *
            math.sin(lngDelta / 2) *
            math.sin(lngDelta / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    final distance = earthRadiusKm * c;

    return distance;
  }

  /// Convert degrees to radians
  static double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  /// Fallback: Generate simple geodesic route if API fails
  /// This provides a backup visualization when API is unavailable
  static List<LatLng> generateSimpleRoute(
    LatLng origin,
    LatLng destination, {
    int pointCount = 20,
  }) {
    final List<LatLng> routePoints = [];

    routePoints.add(origin);

    for (int i = 1; i < pointCount; i++) {
      final fraction = i / pointCount;
      final lat = origin.latitude + (destination.latitude - origin.latitude) * fraction;
      final lng = origin.longitude + (destination.longitude - origin.longitude) * fraction;
      routePoints.add(LatLng(lat, lng));
    }

    routePoints.add(destination);

    return routePoints;
  }
}
