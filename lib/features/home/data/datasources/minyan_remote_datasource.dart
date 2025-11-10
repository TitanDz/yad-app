import 'package:yad_app/core/network/network_service.dart';
import 'package:yad_app/features/home/domain/entities/minyan.dart';

abstract class MinyanRemoteDataSource {
  Future<List<Minyan>> getMyMinyans({
    required int limit,
    required int offset,
  });

  Future<List<Minyan>> getNearbyMinyans({
    required double latitude,
    required double longitude,
    required double radiusKm,
    required int limit,
    required int offset,
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
    required int limit,
    required int offset,
  });
}

class MinyanRemoteDataSourceImpl implements MinyanRemoteDataSource {
  final NetworkService networkService;

  MinyanRemoteDataSourceImpl(this.networkService);

  @override
  Future<List<Minyan>> getMyMinyans({
    required int limit,
    required int offset,
  }) async {
    try {
      final response = await networkService.get<List<dynamic>>(
        '/minyans/my?limit=$limit&offset=$offset',
      );
      return (response as List<dynamic>)
          .map((json) => _parseMinyans(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
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
    try {
      final response = await networkService.get<List<dynamic>>(
        '/minyans/nearby?latitude=$latitude&longitude=$longitude&radiusKm=$radiusKm&limit=$limit&offset=$offset',
      );
      return (response as List<dynamic>)
          .map((json) => _parseMinyans(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Minyan> getMinyan(String minyanId) async {
    try {
      final response = await networkService.get<Map<String, dynamic>>(
        '/minyans/$minyanId',
      );
      return _parseMinyans(response);
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
      final response = await networkService.post<Map<String, dynamic>>(
        '/minyans',
        data: {
          'prayerType': prayerType,
          'date': date,
          'time': time,
          'locationName': locationName,
          'latitude': latitude,
          'longitude': longitude,
          'notes': notes,
        },
      );
      return _parseMinyans(response);
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
      final response = await networkService.put<Map<String, dynamic>>(
        '/minyans/$minyanId',
        data: {
          'prayerType': prayerType,
          'date': date,
          'time': time,
          'locationName': locationName,
          'latitude': latitude,
          'longitude': longitude,
          'notes': notes,
        },
      );
      return _parseMinyans(response);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteMinyan(String minyanId) async {
    try {
      await networkService.delete('/minyans/$minyanId');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Minyan> publishMinyan(String minyanId) async {
    try {
      final response = await networkService.post<Map<String, dynamic>>(
        '/minyans/$minyanId/publish',
        data: {},
      );
      return _parseMinyans(response);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> joinMinyan(String minyanId) async {
    try {
      await networkService.post<Map<String, dynamic>>(
        '/minyans/$minyanId/join',
        data: {},
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> leaveMinyan(String minyanId) async {
    try {
      await networkService.post<Map<String, dynamic>>(
        '/minyans/$minyanId/leave',
        data: {},
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Minyan>> searchMinyans({
    required String query,
    required int limit,
    required int offset,
  }) async {
    try {
      final response = await networkService.get<List<dynamic>>(
        '/minyans/search?q=$query&limit=$limit&offset=$offset',
      );
      return (response as List<dynamic>)
          .map((json) => _parseMinyans(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Minyan _parseMinyans(Map<String, dynamic> json) {
    return Minyan(
      id: json['id'] as String,
      userId: json['userId'] as String,
      prayerType: json['prayerType'] as String,
      date: json['date'] as String,
      time: json['time'] as String,
      locationName: json['locationName'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      notes: json['notes'] as String? ?? '',
      status: json['status'] as String,
      participantCount: json['participantCount'] as int? ?? 1,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      distance: json['distance'] != null ? (json['distance'] as num).toDouble() : null,
      isCreatedByUser: false,
    );
  }
}
