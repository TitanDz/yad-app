import 'package:yad_app/features/home/data/datasources/place_remote_datasource.dart';
import 'package:yad_app/features/home/domain/entities/place.dart';

class MockPlaceRemoteDataSource implements PlaceRemoteDataSource {
  final List<Place> _mockPlaces = [];

  MockPlaceRemoteDataSource() {
    _initializeMockData();
  }

  void _initializeMockData() {
    _mockPlaces.addAll([
      Place(
        id: 'place_1',
        name: 'Central Synagogue',
        address: '652 Park Ave, New York, NY 10065',
        latitude: 40.7128,
        longitude: -74.0060,
        placeType: 'Synagogue',
        phoneNumber: '(212) 838-5122',
        website: 'www.centralsynagogue.org',
      ),
      Place(
        id: 'place_2',
        name: 'Park Avenue Shul',
        address: '50 E 92nd St, New York, NY 10128',
        latitude: 40.7250,
        longitude: -73.9850,
        placeType: 'Synagogue',
        phoneNumber: '(212) 289-7222',
        website: 'www.parkavenueshul.org',
      ),
      Place(
        id: 'place_3',
        name: 'B\'nai Jeshrun',
        address: '257 W 88th St, New York, NY 10024',
        latitude: 40.7850,
        longitude: -73.9950,
        placeType: 'Jewish Community Center',
        phoneNumber: '(212) 787-7600',
        website: 'www.bnaijeshurun.org',
      ),
    ]);
  }

  @override
  Future<List<Place>> getSavedPlaces({
    required int limit,
    required int offset,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockPlaces.skip(offset).take(limit).toList();
  }

  @override
  Future<Place> getSavedPlace(String placeId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockPlaces.firstWhere(
      (p) => p.id == placeId,
      orElse: () => throw Exception('Place not found'),
    );
  }

  @override
  Future<bool> isPlaceSaved(String placeId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _mockPlaces.any((p) => p.id == placeId);
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
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Check if already saved
    if (_mockPlaces.any((p) => p.id == placeId)) {
      throw Exception('Place already saved');
    }

    final newPlace = Place(
      id: placeId,
      name: name,
      address: address,
      latitude: latitude,
      longitude: longitude,
      placeType: placeType,
      phoneNumber: phoneNumber,
      website: website,
    );
    _mockPlaces.add(newPlace);
    return newPlace;
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
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _mockPlaces.indexWhere((p) => p.id == id);
    if (index == -1) throw Exception('Place not found');

    final updated = Place(
      id: id,
      name: name,
      address: address,
      latitude: latitude,
      longitude: longitude,
      placeType: placeType,
      phoneNumber: phoneNumber,
      website: website,
    );
    _mockPlaces[index] = updated;
    return updated;
  }

  @override
  Future<void> removeSavedPlace(String placeId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _mockPlaces.removeWhere((p) => p.id == placeId);
  }

  @override
  Future<List<Place>> searchPlaces({
    required String query,
    required int limit,
    required int offset,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final results = _mockPlaces
        .where((p) =>
            p.name.toLowerCase().contains(query.toLowerCase()) ||
            p.address.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return results.skip(offset).take(limit).toList();
  }
}
