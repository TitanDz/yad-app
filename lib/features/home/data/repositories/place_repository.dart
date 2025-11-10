import 'package:yad_app/features/home/data/datasources/place_remote_datasource.dart';
import 'package:yad_app/features/home/domain/entities/place.dart';

abstract class PlaceRepository {
  Future<List<Place>> getSavedPlaces({
    int limit = 20,
    int offset = 0,
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
    int limit = 20,
    int offset = 0,
  });
}

class PlaceRepositoryImpl implements PlaceRepository {
  final PlaceRemoteDataSource remoteDataSource;

  PlaceRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Place>> getSavedPlaces({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      return await remoteDataSource.getSavedPlaces(
        limit: limit,
        offset: offset,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Place> getSavedPlace(String placeId) async {
    try {
      return await remoteDataSource.getSavedPlace(placeId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> isPlaceSaved(String placeId) async {
    try {
      return await remoteDataSource.isPlaceSaved(placeId);
    } catch (e) {
      rethrow;
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
      return await remoteDataSource.savePlace(
        placeId: placeId,
        name: name,
        address: address,
        latitude: latitude,
        longitude: longitude,
        placeType: placeType,
        phoneNumber: phoneNumber,
        website: website,
      );
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
      return await remoteDataSource.updatePlace(
        id: id,
        placeId: placeId,
        name: name,
        address: address,
        latitude: latitude,
        longitude: longitude,
        placeType: placeType,
        phoneNumber: phoneNumber,
        website: website,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> removeSavedPlace(String placeId) async {
    try {
      return await remoteDataSource.removeSavedPlace(placeId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Place>> searchPlaces({
    required String query,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      return await remoteDataSource.searchPlaces(
        query: query,
        limit: limit,
        offset: offset,
      );
    } catch (e) {
      rethrow;
    }
  }
}
