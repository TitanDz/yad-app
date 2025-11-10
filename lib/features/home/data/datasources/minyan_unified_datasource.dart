import 'package:yad_app/config/app_config.dart';
import 'package:yad_app/core/network/network_service.dart';
import 'package:yad_app/features/home/data/datasources/minyan_remote_datasource.dart';
import 'package:yad_app/features/home/data/datasources/minyan_mock_datasource.dart';
import 'package:yad_app/features/home/domain/entities/minyan.dart';

/// Unified minyan datasource that switches between mock and real API
/// This allows easy toggling between development (mock) and production (real API) modes
class UnifiedMinyanDataSource implements MinyanRemoteDataSource {
  final NetworkService? networkService;
  late final MockMinyanRemoteDataSource mockDataSource;

  UnifiedMinyanDataSource({this.networkService}) {
    mockDataSource = MockMinyanRemoteDataSource();
  }

  /// Returns true if using mock API, false if using real API
  bool get isMockMode => AppConfig.useMockApi;

  @override
  Future<List<Minyan>> getMyMinyans({
    required int limit,
    required int offset,
  }) async {
    if (isMockMode) {
      return await mockDataSource.getMyMinyans(
        limit: limit,
        offset: offset,
      );
    } else {
      if (networkService == null) {
        throw Exception('NetworkService not initialized');
      }
      try {
        return await MinyanRemoteDataSourceImpl(networkService!).getMyMinyans(
          limit: limit,
          offset: offset,
        );
      } catch (e) {
        rethrow;
      }
    }
  }

  @override
  Future<List<Minyan>> getNearbyMinyans({
    required double latitude,
    required double longitude,
    required double radiusKm,
    required int limit,
    required int offset,
  }) async {
    if (isMockMode) {
      return await mockDataSource.getNearbyMinyans(
        latitude: latitude,
        longitude: longitude,
        radiusKm: radiusKm,
        limit: limit,
        offset: offset,
      );
    } else {
      if (networkService == null) {
        throw Exception('NetworkService not initialized');
      }
      try {
        return await MinyanRemoteDataSourceImpl(networkService!).getNearbyMinyans(
          latitude: latitude,
          longitude: longitude,
          radiusKm: radiusKm,
          limit: limit,
          offset: offset,
        );
      } catch (e) {
        rethrow;
      }
    }
  }

  @override
  Future<Minyan> getMinyan(String minyanId) async {
    if (isMockMode) {
      return await mockDataSource.getMinyan(minyanId);
    } else {
      if (networkService == null) {
        throw Exception('NetworkService not initialized');
      }
      try {
        return await MinyanRemoteDataSourceImpl(networkService!).getMinyan(minyanId);
      } catch (e) {
        rethrow;
      }
    }
  }

  @override
  Future<Minyan> createMinyan({
    required String prayerType,
    required String date,
    required String time,
    required String locationName,
    required double latitude,
    required double longitude,
    required String notes,
  }) async {
    if (isMockMode) {
      return await mockDataSource.createMinyan(
        prayerType: prayerType,
        date: date,
        time: time,
        locationName: locationName,
        latitude: latitude,
        longitude: longitude,
        notes: notes,
      );
    } else {
      if (networkService == null) {
        throw Exception('NetworkService not initialized');
      }
      try {
        return await MinyanRemoteDataSourceImpl(networkService!).createMinyan(
          prayerType: prayerType,
          date: date,
          time: time,
          locationName: locationName,
          latitude: latitude,
          longitude: longitude,
          notes: notes,
        );
      } catch (e) {
        rethrow;
      }
    }
  }

  @override
  Future<Minyan> updateMinyan({
    required String minyanId,
    required String prayerType,
    required String date,
    required String time,
    required String locationName,
    required double latitude,
    required double longitude,
    required String notes,
  }) async {
    if (isMockMode) {
      return await mockDataSource.updateMinyan(
        minyanId: minyanId,
        prayerType: prayerType,
        date: date,
        time: time,
        locationName: locationName,
        latitude: latitude,
        longitude: longitude,
        notes: notes,
      );
    } else {
      if (networkService == null) {
        throw Exception('NetworkService not initialized');
      }
      try {
        return await MinyanRemoteDataSourceImpl(networkService!).updateMinyan(
          minyanId: minyanId,
          prayerType: prayerType,
          date: date,
          time: time,
          locationName: locationName,
          latitude: latitude,
          longitude: longitude,
          notes: notes,
        );
      } catch (e) {
        rethrow;
      }
    }
  }

  @override
  Future<void> deleteMinyan(String minyanId) async {
    if (isMockMode) {
      return await mockDataSource.deleteMinyan(minyanId);
    } else {
      if (networkService == null) {
        throw Exception('NetworkService not initialized');
      }
      try {
        return await MinyanRemoteDataSourceImpl(networkService!).deleteMinyan(minyanId);
      } catch (e) {
        rethrow;
      }
    }
  }

  @override
  Future<Minyan> publishMinyan(String minyanId) async {
    if (isMockMode) {
      return await mockDataSource.publishMinyan(minyanId);
    } else {
      if (networkService == null) {
        throw Exception('NetworkService not initialized');
      }
      try {
        return await MinyanRemoteDataSourceImpl(networkService!).publishMinyan(minyanId);
      } catch (e) {
        rethrow;
      }
    }
  }

  @override
  Future<void> joinMinyan(String minyanId) async {
    if (isMockMode) {
      return await mockDataSource.joinMinyan(minyanId);
    } else {
      if (networkService == null) {
        throw Exception('NetworkService not initialized');
      }
      try {
        return await MinyanRemoteDataSourceImpl(networkService!).joinMinyan(minyanId);
      } catch (e) {
        rethrow;
      }
    }
  }

  @override
  Future<void> leaveMinyan(String minyanId) async {
    if (isMockMode) {
      return await mockDataSource.leaveMinyan(minyanId);
    } else {
      if (networkService == null) {
        throw Exception('NetworkService not initialized');
      }
      try {
        return await MinyanRemoteDataSourceImpl(networkService!).leaveMinyan(minyanId);
      } catch (e) {
        rethrow;
      }
    }
  }

  @override
  Future<List<Minyan>> searchMinyans({
    required String query,
    required int limit,
    required int offset,
  }) async {
    if (isMockMode) {
      return await mockDataSource.searchMinyans(
        query: query,
        limit: limit,
        offset: offset,
      );
    } else {
      if (networkService == null) {
        throw Exception('NetworkService not initialized');
      }
      try {
        return await MinyanRemoteDataSourceImpl(networkService!).searchMinyans(
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
