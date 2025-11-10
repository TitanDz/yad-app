import 'package:yad_app/core/network/network_service.dart';
import 'package:yad_app/features/home/domain/entities/place.dart';

abstract class PlaceRemoteDataSource {
  Future<List<Place>> getSavedPlaces({
    required int limit,
    required int offset,
  });

  Future<Place> getSavedPlace(String placeId);

  Future<bool> isPlaceSaved(String placeId);

  Future<Place> savePlace({
    required String placeId,
    required String name,
    required String address,
    required double latitude,
    required double longitude,
    required String? placeType,
    required String? phoneNumber,
    required String? website,
  });

  Future<Place> updatePlace({
    required String id,
    required String placeId,
    required String name,
    required String address,
    required double latitude,
    required double longitude,
    required String? placeType,
    required String? phoneNumber,
    required String? website,
  });

  Future<void> removeSavedPlace(String placeId);

  Future<List<Place>> searchPlaces({
    required String query,
    required int limit,
    required int offset,
  });
}

class PlaceRemoteDataSourceImpl implements PlaceRemoteDataSource {
  final NetworkService networkService;

  PlaceRemoteDataSourceImpl(this.networkService);

  @override
  Future<List<Place>> getSavedPlaces({
    required int limit,
    required int offset,
  }) async {
    try {
      final response = await networkService.get<List<dynamic>>(
        '/places/saved?limit=$limit&offset=$offset',
      );
      return (response as List<dynamic>)
          .map((json) => _parsePlace(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Place> getSavedPlace(String placeId) async {
    try {
      final response = await networkService.get<Map<String, dynamic>>(
        '/places/saved/$placeId',
      );
      return _parsePlace(response);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> isPlaceSaved(String placeId) async {
    try {
      await getSavedPlace(placeId);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Place> savePlace({
    required String placeId,
    required String name,
    required String address,
    required double latitude,
    required double longitude,
    required String? placeType,
    required String? phoneNumber,
    required String? website,
  }) async {
    try {
      final response = await networkService.post<Map<String, dynamic>>(
        '/places/saved',
        data: {
          'placeId': placeId,
          'name': name,
          'address': address,
          'latitude': latitude,
          'longitude': longitude,
          'placeType': placeType,
          'phoneNumber': phoneNumber,
          'website': website,
        },
      );
      return _parsePlace(response);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Place> updatePlace({
    required String id,
    required String placeId,
    required String name,
    required String address,
    required double latitude,
    required double longitude,
    required String? placeType,
    required String? phoneNumber,
    required String? website,
  }) async {
    try {
      final response = await networkService.put<Map<String, dynamic>>(
        '/places/saved/$id',
        data: {
          'placeId': placeId,
          'name': name,
          'address': address,
          'latitude': latitude,
          'longitude': longitude,
          'placeType': placeType,
          'phoneNumber': phoneNumber,
          'website': website,
        },
      );
      return _parsePlace(response);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> removeSavedPlace(String placeId) async {
    try {
      await networkService.delete('/places/saved/$placeId');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Place>> searchPlaces({
    required String query,
    required int limit,
    required int offset,
  }) async {
    try {
      final response = await networkService.get<List<dynamic>>(
        '/places/search?q=$query&limit=$limit&offset=$offset',
      );
      return (response as List<dynamic>)
          .map((json) => _parsePlace(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Place _parsePlace(Map<String, dynamic> json) {
    return Place(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      placeType: json['placeType'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      website: json['website'] as String?,
    );
  }
}
