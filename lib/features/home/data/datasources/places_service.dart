import 'package:yad_app/features/home/domain/entities/place.dart';

class PlacesService {
  static const String googleMapsApiKey = 'AIzaSyD1_mZtNCy3Rbb-qD4sQQtUKd25VzdF8hI';

  Future<List<Place>> searchPlaces(
    String query, {
    double? latitude,
    double? longitude,
    double radiusMeters = 50000,
  }) async {
    if (query.isEmpty) {
      return [];
    }

    try {
      // This is a mock implementation. In a real app, you would:
      // 1. Use Google Places API
      // 2. Make an HTTP request with the API key
      // 3. Parse the response and return Place objects

      // For now, return mock data based on the query
      return _getMockPlaces(query, latitude, longitude);
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

  List<Place> _getMockPlaces(
    String query,
    double? latitude,
    double? longitude,
  ) {
    final mockPlaces = [
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
