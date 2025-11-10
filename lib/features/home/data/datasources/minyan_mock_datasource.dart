import 'package:yad_app/features/home/data/datasources/minyan_remote_datasource.dart';
import 'package:yad_app/features/home/domain/entities/minyan.dart';

class MockMinyanRemoteDataSource implements MinyanRemoteDataSource {
  final List<Minyan> _mockMinyans = [];

  MockMinyanRemoteDataSource() {
    _initializeMockData();
  }

  void _initializeMockData() {
    _mockMinyans.addAll([
      Minyan(
        id: '1',
        userId: 'user123',
        prayerType: 'Shacharit',
        date: '2024-12-15',
        time: '06:30',
        locationName: 'Central Synagogue',
        latitude: 40.7128,
        longitude: -74.0060,
        notes: 'Morning prayers with breakfast',
        status: 'published',
        participantCount: 3,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        distance: 0.5,
        isCreatedByUser: true,
      ),
      Minyan(
        id: '2',
        userId: 'user123',
        prayerType: 'Mincha',
        date: '2024-12-16',
        time: '13:30',
        locationName: 'Park Avenue Shul',
        latitude: 40.7250,
        longitude: -73.9850,
        notes: 'Afternoon service',
        status: 'published',
        participantCount: 2,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        distance: 1.2,
        isCreatedByUser: true,
      ),
      Minyan(
        id: '3',
        userId: 'user456',
        prayerType: 'Shacharit',
        date: '2024-12-15',
        time: '06:45',
        locationName: 'Midtown Synagogue',
        latitude: 40.7500,
        longitude: -73.9800,
        notes: '',
        status: 'published',
        participantCount: 4,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        distance: 3.2,
        isCreatedByUser: false,
      ),
      Minyan(
        id: '4',
        userId: 'user789',
        prayerType: 'Maariv',
        date: '2024-12-15',
        time: '18:00',
        locationName: 'Upper West Side Temple',
        latitude: 40.7800,
        longitude: -73.9900,
        notes: 'Evening prayers',
        status: 'published',
        participantCount: 6,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        distance: 5.1,
        isCreatedByUser: false,
      ),
    ]);
  }

  @override
  Future<List<Minyan>> getMyMinyans({
    required int limit,
    required int offset,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final myMinyans = _mockMinyans.where((m) => m.isCreatedByUser).toList();
    return myMinyans.skip(offset).take(limit).toList();
  }

  @override
  Future<List<Minyan>> getNearbyMinyans({
    required double latitude,
    required double longitude,
    required double radiusKm,
    required int limit,
    required int offset,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final nearby = _mockMinyans
        .where((m) => (m.distance ?? 0) <= radiusKm)
        .toList();
    return nearby.skip(offset).take(limit).toList();
  }

  @override
  Future<Minyan> getMinyan(String minyanId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockMinyans.firstWhere(
      (m) => m.id == minyanId,
      orElse: () => throw Exception('Minyan not found'),
    );
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
    await Future.delayed(const Duration(milliseconds: 300));
    final newMinyan = Minyan(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'user123',
      prayerType: prayerType,
      date: date,
      time: time,
      locationName: locationName,
      latitude: latitude,
      longitude: longitude,
      notes: notes,
      status: 'draft',
      participantCount: 1,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isCreatedByUser: true,
    );
    _mockMinyans.add(newMinyan);
    return newMinyan;
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
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _mockMinyans.indexWhere((m) => m.id == minyanId);
    if (index == -1) throw Exception('Minyan not found');

    final updated = Minyan(
      id: minyanId,
      userId: _mockMinyans[index].userId,
      prayerType: prayerType,
      date: date,
      time: time,
      locationName: locationName,
      latitude: latitude,
      longitude: longitude,
      notes: notes,
      status: _mockMinyans[index].status,
      participantCount: _mockMinyans[index].participantCount,
      createdAt: _mockMinyans[index].createdAt,
      updatedAt: DateTime.now(),
      isCreatedByUser: _mockMinyans[index].isCreatedByUser,
    );
    _mockMinyans[index] = updated;
    return updated;
  }

  @override
  Future<void> deleteMinyan(String minyanId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _mockMinyans.removeWhere((m) => m.id == minyanId);
  }

  @override
  Future<Minyan> publishMinyan(String minyanId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _mockMinyans.indexWhere((m) => m.id == minyanId);
    if (index == -1) throw Exception('Minyan not found');

    final published = Minyan(
      id: minyanId,
      userId: _mockMinyans[index].userId,
      prayerType: _mockMinyans[index].prayerType,
      date: _mockMinyans[index].date,
      time: _mockMinyans[index].time,
      locationName: _mockMinyans[index].locationName,
      latitude: _mockMinyans[index].latitude,
      longitude: _mockMinyans[index].longitude,
      notes: _mockMinyans[index].notes,
      status: 'published',
      participantCount: _mockMinyans[index].participantCount,
      createdAt: _mockMinyans[index].createdAt,
      updatedAt: DateTime.now(),
      isCreatedByUser: _mockMinyans[index].isCreatedByUser,
    );
    _mockMinyans[index] = published;
    return published;
  }

  @override
  Future<void> joinMinyan(String minyanId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _mockMinyans.indexWhere((m) => m.id == minyanId);
    if (index == -1) throw Exception('Minyan not found');

    final updated = Minyan(
      id: minyanId,
      userId: _mockMinyans[index].userId,
      prayerType: _mockMinyans[index].prayerType,
      date: _mockMinyans[index].date,
      time: _mockMinyans[index].time,
      locationName: _mockMinyans[index].locationName,
      latitude: _mockMinyans[index].latitude,
      longitude: _mockMinyans[index].longitude,
      notes: _mockMinyans[index].notes,
      status: _mockMinyans[index].status,
      participantCount: _mockMinyans[index].participantCount + 1,
      createdAt: _mockMinyans[index].createdAt,
      updatedAt: DateTime.now(),
      isCreatedByUser: _mockMinyans[index].isCreatedByUser,
    );
    _mockMinyans[index] = updated;
  }

  @override
  Future<void> leaveMinyan(String minyanId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _mockMinyans.indexWhere((m) => m.id == minyanId);
    if (index == -1) throw Exception('Minyan not found');

    if (_mockMinyans[index].participantCount > 1) {
      final updated = Minyan(
        id: minyanId,
        userId: _mockMinyans[index].userId,
        prayerType: _mockMinyans[index].prayerType,
        date: _mockMinyans[index].date,
        time: _mockMinyans[index].time,
        locationName: _mockMinyans[index].locationName,
        latitude: _mockMinyans[index].latitude,
        longitude: _mockMinyans[index].longitude,
        notes: _mockMinyans[index].notes,
        status: _mockMinyans[index].status,
        participantCount: _mockMinyans[index].participantCount - 1,
        createdAt: _mockMinyans[index].createdAt,
        updatedAt: DateTime.now(),
        isCreatedByUser: _mockMinyans[index].isCreatedByUser,
      );
      _mockMinyans[index] = updated;
    }
  }

  @override
  Future<List<Minyan>> searchMinyans({
    required String query,
    required int limit,
    required int offset,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final results = _mockMinyans
        .where((m) =>
            m.locationName.toLowerCase().contains(query.toLowerCase()) ||
            m.prayerType.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return results.skip(offset).take(limit).toList();
  }
}
