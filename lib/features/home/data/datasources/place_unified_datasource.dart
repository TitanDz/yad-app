import 'package:yad_app/config/app_config.dart';
import 'package:yad_app/core/network/network_service.dart';
import 'package:yad_app/features/home/data/datasources/place_remote_datasource.dart';
import 'package:yad_app/features/home/data/datasources/place_mock_datasource.dart';
import 'package:yad_app/features/home/domain/entities/place.dart';

/// Unified place datasource that switches between mock and real API
/// This allows easy toggling between development (mock) and production (real API) modes
class UnifiedPlaceDataSource implements PlaceRemoteDataSource {
  final NetworkService? networkService;
  late final MockPlaceRemoteDataSource mockDataSource;

  UnifiedPlaceDataSource({this.networkService}) {
    mockDataSource = MockPlaceRemoteDataSource();
  }

  /// Returns true if using mock API, false if using real API
  bool get isMockMode => AppConfig.useMockApi;

  @override
  Future<List<Place>> getSavedPlaces({
    required int limit,
    required int offset,
  }) async {
    if (isMockMode) {
      return await mockDataSource.getSavedPlaces(
        limit: limit,
        offset: offset,
      );
    } else {
      if (networkService == null) {
        throw Exception('NetworkService not initialized');
      }
      try {
        return await PlaceRemoteDataSourceImpl(networkService!).getSavedPlaces(
          limit: limit,
          offset: offset,
        );
      } catch (e) {
        rethrow;
      }
    }
  }

  @override
  Future<Place> getSavedPlace(String placeId) async {
    if (isMockMode) {
      return await mockDataSource.getSavedPlace(placeId);
    } else {
      if (networkService == null) {
        throw Exception('NetworkService not initialized');
      }
      try {
        return await PlaceRemoteDataSourceImpl(networkService!).getSavedPlace(placeId);
      } catch (e) {
        rethrow;
      }
    }
  }

  @override
  Future<bool> isPlaceSaved(String placeId) async {
    if (isMockMode) {
      return await mockDataSource.isPlaceSaved(placeId);
    } else {
      if (networkService == null) {
        throw Exception('NetworkService not initialized');
      }
      try {
        return await PlaceRemoteDataSourceImpl(networkService!).isPlaceSaved(placeId);
      } catch (e) {
        rethrow;
      }
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
    if (isMockMode) {
      return await mockDataSource.savePlace(
        placeId: placeId,
        name: name,
        address: address,
        latitude: latitude,
        longitude: longitude,
        placeType: placeType,
        phoneNumber: phoneNumber,
        website: website,
      );
    } else {
      if (networkService == null) {
        throw Exception('NetworkService not initialized');
      }
      try {
        return await PlaceRemoteDataSourceImpl(networkService!).savePlace(
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
    if (isMockMode) {
      return await mockDataSource.updatePlace(
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
    } else {
      if (networkService == null) {
        throw Exception('NetworkService not initialized');
      }
      try {
        return await PlaceRemoteDataSourceImpl(networkService!).updatePlace(
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
  }

  @override
  Future<void> removeSavedPlace(String placeId) async {
    if (isMockMode) {
      return await mockDataSource.removeSavedPlace(placeId);
    } else {
      if (networkService == null) {
        throw Exception('NetworkService not initialized');
      }
      try {
        return await PlaceRemoteDataSourceImpl(networkService!).removeSavedPlace(placeId);
      } catch (e) {
        rethrow;
      }
    }
  }

  @override
  Future<List<Place>> searchPlaces({
    required String query,
    required int limit,
    required int offset,
  }) async {
    if (isMockMode) {
      return await mockDataSource.searchPlaces(
        query: query,
        limit: limit,
        offset: offset,
      );
    } else {
      if (networkService == null) {
        throw Exception('NetworkService not initialized');
      }
      try {
        return await PlaceRemoteDataSourceImpl(networkService!).searchPlaces(
          query: query,
          limit: limit,
          offset: offset,
        );
      } catch (e) {
        rethrow;
      }
    }
  }
}
