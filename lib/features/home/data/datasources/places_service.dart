import 'package:yad_app/features/home/domain/entities/place.dart';

class PlacesService {
  static const String googleMapsApiKey = 'AIzaSyD1_mZtNCy3Rbb-qD4sQQtUKd25VzdF8hI';

  // Jewish prayer venue types for filtering
  static const List<String> jewishVenueTypes = [
    'Synagogue',
    'Minyan Location',
    'Jewish Prayer Center',
    'Shul',
    'Temple',
    'Jewish Community Center',
    'Hebrew Congregation',
  ];

  Future<List<Place>> searchPlaces(
    String query, {
    double? latitude,
    double? longitude,
    double radiusMeters = 50000,
    bool jewishVenuesOnly = false,
  }) async {
    if (query.isEmpty) {
      return [];
    }

    try {
      // This is a mock implementation. In a real app, you would:
      // 1. Use Google Places API with type filters
      // 2. Make an HTTP request with the API key
      // 3. Parse the response and return Place objects

      // For now, return mock data based on the query
      var results = _getMockPlaces(query, latitude, longitude);
      
      // Filter to Jewish venues only if requested
      if (jewishVenuesOnly) {
        results = _filterJewishVenues(results);
      }
      
      return results;
    } catch (e) {
      return [];
    }
  }

  /// Get nearby places filtered to show only Jewish prayer venues
  Future<List<Place>> getNearbyJewishVenues({
    required double latitude,
    required double longitude,
    double radiusMeters = 50000,
  }) async {
    try {
      // In a real app, you would query Google Places API with type filters
      // for religious venues near the user's location
      final allPlaces = _getMockPlaces('', latitude, longitude);
      return _filterJewishVenues(allPlaces);
    } catch (e) {
      return [];
    }
  }

  Future<Place?> getPlaceDetails(String placeId) async {
    try {
      // Mock implementation
      final mockPlaces = _getMockPlaces('', null, null);
      for (final place in mockPlaces) {
        if (place.id == placeId) {
          return place;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Filter places to include only Jewish prayer venues
  List<Place> _filterJewishVenues(List<Place> places) {
    return places.where((place) {
      final type = place.placeType?.toLowerCase() ?? '';
      return jewishVenueTypes.any((venue) => type.contains(venue.toLowerCase()));
    }).toList();
  }

  List<Place> _getMockPlaces(
    String query,
    double? latitude,
    double? longitude,
  ) {
    final mockPlaces = [
      // Jewish Prayer Venues
      Place(
        id: '101',
        name: 'Central Synagogue',
        address: '123 E 55th St, New York, NY 10022',
        latitude: 40.7615,
        longitude: -73.9776,
        placeType: 'Synagogue',
        phoneNumber: '+1 (212) 838-5122',
        website: 'https://www.centralsynagogue.org',
      ),
      Place(
        id: '102',
        name: 'Temple Emanu-El',
        address: '1 E 65th St, New York, NY 10065',
        latitude: 40.7728,
        longitude: -73.9638,
        placeType: 'Temple',
        phoneNumber: '+1 (212) 744-1400',
        website: 'https://www.emanuelnyc.org',
      ),
      Place(
        id: '103',
        name: 'Beth Israel Synagogue',
        address: '207 W 13th St, New York, NY 10011',
        latitude: 40.7347,
        longitude: -74.0001,
        placeType: 'Synagogue',
        phoneNumber: '+1 (212) 691-8000',
      ),
      Place(
        id: '104',
        name: 'Anshe Chesed',
        address: '251 W 100th St, New York, NY 10025',
        latitude: 40.8034,
        longitude: -73.9689,
        placeType: 'Shul',
        phoneNumber: '+1 (212) 865-0600',
      ),
      Place(
        id: '105',
        name: 'Young Israel of Manhattan',
        address: '3 W 16th St, New York, NY 10011',
        latitude: 40.7365,
        longitude: -74.0000,
        placeType: 'Synagogue',
        phoneNumber: '+1 (212) 929-1149',
      ),
      Place(
        id: '106',
        name: 'Congregation B\'nai Jeshurun',
        address: '257 W 88th St, New York, NY 10024',
        latitude: 40.7855,
        longitude: -73.9811,
        placeType: 'Synagogue',
        phoneNumber: '+1 (212) 787-7600',
      ),
      Place(
        id: '107',
        name: 'Jewish Community Center',
        address: '520 W 49th St, New York, NY 10019',
        latitude: 40.7629,
        longitude: -73.9862,
        placeType: 'Jewish Community Center',
        phoneNumber: '+1 (212) 601-1000',
        website: 'https://www.92ndsty.org',
      ),
      Place(
        id: '108',
        name: 'Minyan at Washington Square',
        address: '42 Washington Sq S, New York, NY 10011',
        latitude: 40.7313,
        longitude: -73.9960,
        placeType: 'Minyan Location',
        phoneNumber: '+1 (212) 998-0001',
      ),
      // Non-Jewish Places (for contrast)
      Place(
        id: '1',
        name: 'Central Park',
        address: '1 Central Park West, New York, NY 10024',
        latitude: 40.7829,
        longitude: -73.9654,
        placeType: 'Park',
        phoneNumber: '+1 (212) 310-6600',
        website: 'https://www.centralparknyc.org',
      ),
      Place(
        id: '2',
        name: 'Times Square',
        address: '42nd St & Broadway, New York, NY',
        latitude: 40.758,
        longitude: -73.9855,
        placeType: 'Tourist Attraction',
      ),
      Place(
        id: '3',
        name: 'Statue of Liberty',
        address: 'Liberty Island, New York, NY 10004',
        latitude: 40.6892,
        longitude: -74.0445,
        placeType: 'Monument',
        website: 'https://www.statuecruises.com',
      ),
      Place(
        id: '4',
        name: 'Brooklyn Bridge',
        address: 'Brooklyn, New York, NY',
        latitude: 40.7061,
        longitude: -73.9969,
        placeType: 'Bridge',
      ),
      Place(
        id: '5',
        name: 'Empire State Building',
        address: '350 5th Ave, New York, NY 10118',
        latitude: 40.7484,
        longitude: -73.9857,
        placeType: 'Building',
        phoneNumber: '+1 (212) 736-3100',
        website: 'https://www.esbnyc.com',
      ),
      Place(
        id: '6',
        name: 'Metropolitan Museum of Art',
        address: '1000 5th Ave, New York, NY 10028',
        latitude: 40.7814,
        longitude: -73.9776,
        placeType: 'Museum',
        phoneNumber: '+1 (212) 535-7710',
        website: 'https://www.metmuseum.org',
      ),
    ];

    if (query.isEmpty) {
      return mockPlaces;
    }

    return mockPlaces
        .where((place) =>
            place.name.toLowerCase().contains(query.toLowerCase()) ||
            place.address.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
