import 'package:yad_app/features/home/data/datasources/minyan_remote_datasource.dart';
import 'package:yad_app/features/home/domain/entities/minyan.dart';

abstract class MinyanRepository {
  Future<List<Minyan>> getMyMinyans({
    int limit = 20,
    int offset = 0,
  });

  Future<List<Minyan>> getNearbyMinyans({
    required double latitude,
    required double longitude,
    double radiusKm = 5.0,
    int limit = 20,
    int offset = 0,
  });

  Future<Minyan> getMinyan(String minyanId);

  Future<Minyan> createMinyan({
    required String prayerType,
    required String date,
    required String time,
    required String locationName,
    required double latitude,
    required double longitude,
    required String notes,
  });

  Future<Minyan> updateMinyan({
    required String minyanId,
    required String prayerType,
    required String date,
    required String time,
    required String locationName,
    required double latitude,
    required double longitude,
    required String notes,
  });

  Future<void> deleteMinyan(String minyanId);

  Future<Minyan> publishMinyan(String minyanId);

  Future<void> joinMinyan(String minyanId);

  Future<void> leaveMinyan(String minyanId);

  Future<List<Minyan>> searchMinyans({
    required String query,
    int limit = 20,
    int offset = 0,
  });
}

class MinyanRepositoryImpl implements MinyanRepository {
  final MinyanRemoteDataSource remoteDataSource;

  MinyanRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Minyan>> getMyMinyans({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      return await remoteDataSource.getMyMinyans(
        limit: limit,
        offset: offset,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Minyan>> getNearbyMinyans({
    required double latitude,
    required double longitude,
    double radiusKm = 5.0,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      return await remoteDataSource.getNearbyMinyans(
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

  @override
  Future<Minyan> getMinyan(String minyanId) async {
    try {
      return await remoteDataSource.getMinyan(minyanId);
    } catch (e) {
      rethrow;
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
    try {
      return await remoteDataSource.createMinyan(
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
    try {
      return await remoteDataSource.updateMinyan(
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

  @override
  Future<void> deleteMinyan(String minyanId) async {
    try {
      return await remoteDataSource.deleteMinyan(minyanId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Minyan> publishMinyan(String minyanId) async {
    try {
      return await remoteDataSource.publishMinyan(minyanId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> joinMinyan(String minyanId) async {
    try {
      return await remoteDataSource.joinMinyan(minyanId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> leaveMinyan(String minyanId) async {
    try {
      return await remoteDataSource.leaveMinyan(minyanId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Minyan>> searchMinyans({
    required String query,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      return await remoteDataSource.searchMinyans(
        query: query,
        limit: limit,
        offset: offset,
      );
    } catch (e) {
      rethrow;
    }
  }
}
