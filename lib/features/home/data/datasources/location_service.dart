import 'package:geolocator/geolocator.dart';
import 'package:yad_app/features/home/domain/entities/user_location.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class LocationService {
  Future<UserLocation?> getCurrentLocation() async {
    try {
      // Step 1: Check if location services are enabled
      final isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isLocationServiceEnabled) {
        debugPrint('❌ Location services disabled on device');
        return null;
      }
      debugPrint('✅ Location services enabled');

      // Step 2: Check and request permissions
      LocationPermission permission = await Geolocator.checkPermission();
      debugPrint('📍 Current permission: $permission');
      
      if (permission == LocationPermission.denied) {
        debugPrint('⚠️ Location permission denied, requesting...');
        permission = await Geolocator.requestPermission();
        debugPrint('📍 Permission after request: $permission');
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('❌ Location permission denied forever');
        return null;
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        debugPrint('✅ Permission granted, getting position...');
        
        try {
          // Try to get current position with timeout
          // On simulator without mock location, this will timeout
          final Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
            timeLimit: const Duration(seconds: 10),
          ).timeout(
            const Duration(seconds: 12),
            onTimeout: () {
              debugPrint('⏱️ Position request timed out after 12 seconds');
              throw TimeoutException('Position request timed out');
            },
          );
          debugPrint('✅ Position obtained: ${position.latitude}, ${position.longitude}');

          return UserLocation(
            latitude: position.latitude,
            longitude: position.longitude,
            accuracy: position.accuracy,
            address:
                '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}',
          );
        } catch (e) {
          debugPrint('⏱️ Position request failed: $e');
          // Try to get last known position as fallback (works better on simulator)
          try {
            final Position? lastPosition = await Geolocator.getLastKnownPosition();
            if (lastPosition != null) {
              debugPrint('✅ Using last known position: ${lastPosition.latitude}, ${lastPosition.longitude}');
              return UserLocation(
                latitude: lastPosition.latitude,
                longitude: lastPosition.longitude,
                accuracy: lastPosition.accuracy,
                address:
                    '${lastPosition.latitude.toStringAsFixed(4)}, ${lastPosition.longitude.toStringAsFixed(4)}',
              );
            }
          } catch (e) {
            debugPrint('⚠️ Could not get last known position: $e');
          }
          debugPrint('⚠️ No location available - using fallback location');
          // Return null to use fallback location in HomePage
          return null;
        }
      }
      
      debugPrint('❌ Permission: $permission - cannot proceed');
      return null;
    } catch (e) {
      debugPrint('❌ Fatal error in getCurrentLocation: $e');
      return null;
    }
  }

  Future<bool> requestLocationPermission() async {
    try {
      final permission = await Geolocator.requestPermission();
      return permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;
    } catch (e) {
      debugPrint('❌ Error requesting permission: $e');
      return false;
    }
  }

  Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      debugPrint('❌ Error checking location service: $e');
      return false;
    }
  }

  Stream<Position> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );
  }
}
