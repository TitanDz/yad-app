import 'package:yad_app/features/home/data/datasources/minyan_remote_datasource.dart';
import 'package:yad_app/features/home/domain/entities/minyan.dart';
import 'package:yad_app/core/services/location_calculator.dart';

class MockMinyanRemoteDataSource implements MinyanRemoteDataSource {
  final List<Minyan> _mockMinyans = [];

  MockMinyanRemoteDataSource() {
    _initializeMockData();
  }

  void _initializeMockData() {
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    final tomorrow = today.add(const Duration(days: 1));
    
    final todayStr = _formatDate(today);
    final yesterdayStr = _formatDate(yesterday);
    final tomorrowStr = _formatDate(tomorrow);
    
    _mockMinyans.addAll([
      // New York - Manhattan
      Minyan(
        id: '1',
        userId: 'user456',
        prayerType: 'Shacharit',
        date: todayStr,
        time: '06:30',
        locationName: 'Central Synagogue',
        latitude: 40.7128,
        longitude: -74.0060,
        notes: 'Morning prayers with breakfast',
        status: 'published',
        participantCount: 5,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isCreatedByUser: false,
      ),
      // Los Angeles - Beverly Hills
      Minyan(
        id: '2',
        userId: 'user789',
        prayerType: 'Mincha',
        date: tomorrowStr,
        time: '13:30',
        locationName: 'Beverly Hills Synagogue',
        latitude: 34.0901,
        longitude: -118.4065,
        notes: 'Afternoon service with kiddush',
        status: 'published',
        participantCount: 8,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isCreatedByUser: false,
      ),
      // Chicago - Downtown
      Minyan(
        id: '3',
        userId: 'user321',
        prayerType: 'Shacharit',
        date: yesterdayStr,
        time: '06:45',
        locationName: 'Chicago Loop Congregation',
        latitude: 41.8827,
        longitude: -87.6233,
        notes: 'Traditional service',
        status: 'published',
        participantCount: 6,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isCreatedByUser: false,
      ),
      // Boston - Back Bay
      Minyan(
        id: '4',
        userId: 'user654',
        prayerType: 'Maariv',
        date: todayStr,
        time: '18:15',
        locationName: 'Temple Emanuel',
        latitude: 42.3554,
        longitude: -71.0729,
        notes: 'Evening prayers and discussion',
        status: 'published',
        participantCount: 4,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isCreatedByUser: false,
      ),
      // San Francisco - Financial District
      Minyan(
        id: '5',
        userId: 'user987',
        prayerType: 'Shacharit',
        date: tomorrowStr,
        time: '07:00',
        locationName: 'Congregation Emanu-El',
        latitude: 37.7909,
        longitude: -122.3958,
        notes: 'Morning minyan downtown',
        status: 'published',
        participantCount: 7,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isCreatedByUser: false,
      ),
      // Miami - Wynwood
      Minyan(
        id: '6',
        userId: 'user111',
        prayerType: 'Mincha',
        date: yesterdayStr,
        time: '13:00',
        locationName: 'Wynwood Hebrew Congregation',
        latitude: 25.7959,
        longitude: -80.1982,
        notes: 'Casual afternoon minyan',
        status: 'published',
        participantCount: 3,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isCreatedByUser: false,
      ),
      // Washington DC - Georgetown
      Minyan(
        id: '7',
        userId: 'user222',
        prayerType: 'Maariv',
        date: tomorrowStr,
        time: '17:45',
        locationName: 'Georgetown Jewish Center',
        latitude: 38.9072,
        longitude: -77.0748,
        notes: 'Evening study session after prayers',
        status: 'published',
        participantCount: 9,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isCreatedByUser: false,
      ),
      // Seattle - Capitol Hill
      Minyan(
        id: '8',
        userId: 'user333',
        prayerType: 'Shacharit',
        date: todayStr,
        time: '07:30',
        locationName: 'Capitol Hill Shul',
        latitude: 47.6205,
        longitude: -122.3212,
        notes: 'Community minyan with bagels',
        status: 'published',
        participantCount: 5,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isCreatedByUser: false,
      ),
      // Denver - Cherry Creek
      Minyan(
        id: '9',
        userId: 'user444',
        prayerType: 'Mincha',
        date: yesterdayStr,
        time: '14:00',
        locationName: 'Denver Jewish Community Center',
        latitude: 39.7392,
        longitude: -104.9903,
        notes: 'Afternoon services',
        status: 'published',
        participantCount: 6,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isCreatedByUser: false,
      ),
      // Atlanta - Buckhead
      Minyan(
        id: '10',
        userId: 'user555',
        prayerType: 'Maariv',
        date: todayStr,
        time: '18:30',
        locationName: 'Congregation Shearith Israel',
        latitude: 33.8447,
        longitude: -84.3766,
        notes: 'Evening minyan with optional dinner',
        status: 'published',
        participantCount: 10,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isCreatedByUser: false,
      ),
      // San Diego - Downtown (YOUR LOCATION)
      Minyan(
        id: '11',
        userId: 'user666',
        prayerType: 'Shacharit',
        date: todayStr,
        time: '07:15',
        locationName: 'Tifereth Israel San Diego',
        latitude: 32.7157,
        longitude: -117.1611,
        notes: 'Downtown morning minyan with traditional liturgy',
        status: 'published',
        participantCount: 7,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isCreatedByUser: false,
      ),
      // San Diego - La Jolla (YOUR LOCATION)
      Minyan(
        id: '12',
        userId: 'user777',
        prayerType: 'Mincha',
        date: tomorrowStr,
        time: '13:45',
        locationName: 'La Jolla Jewish Center',
        latitude: 32.8453,
        longitude: -117.2723,
        notes: 'Casual afternoon minyan in La Jolla - followed by kiddush',
        status: 'published',
        participantCount: 5,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isCreatedByUser: false,
      ),
    ]);
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
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
    
    // Filter minyans within radius and calculate actual distances
    final nearby = <Minyan>[];
    for (final minyan in _mockMinyans) {
      // Only include published minyans
      if (minyan.status != 'published') continue;
      
      // Calculate actual distance from user location using Haversine formula
      final distance = LocationCalculator.calculateDistanceInKm(
        latitude,
        longitude,
        minyan.latitude,
        minyan.longitude,
      );
      
      // Filter by radius
      if (distance <= radiusKm) {
        // Add calculated distance to minyan
        final minyanWithDistance = Minyan(
          id: minyan.id,
          userId: minyan.userId,
          prayerType: minyan.prayerType,
          date: minyan.date,
          time: minyan.time,
          locationName: minyan.locationName,
          latitude: minyan.latitude,
          longitude: minyan.longitude,
          notes: minyan.notes,
          status: minyan.status,
          participantCount: minyan.participantCount,
          createdAt: minyan.createdAt,
          updatedAt: minyan.updatedAt,
          distance: distance, // SET CALCULATED DISTANCE
          isCreatedByUser: minyan.isCreatedByUser,
        );
        nearby.add(minyanWithDistance);
      }
    }
    
    // Sort by distance (closest first)
    nearby.sort((a, b) => (a.distance ?? 0).compareTo(b.distance ?? 0));
    
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
