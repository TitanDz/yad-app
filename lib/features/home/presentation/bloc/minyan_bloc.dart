import 'dart:math';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yad_app/features/home/domain/entities/minyan.dart';

// Events
abstract class MinyanEvent extends Equatable {
  const MinyanEvent();

  @override
  List<Object?> get props => [];
}

class LoadMyMinyansEvent extends MinyanEvent {
  const LoadMyMinyansEvent();
}

class LoadNearbyMinyansEvent extends MinyanEvent {
  final double? latitude;
  final double? longitude;
  final double radiusKm;

  const LoadNearbyMinyansEvent({
    this.latitude,
    this.longitude,
    this.radiusKm = 5.0,
  });

  @override
  List<Object?> get props => [latitude, longitude, radiusKm];
}

class FilterMinyansEvent extends MinyanEvent {
  final String? prayerType;
  final String? sortBy;
  final String? filterByDate;
  final double? maxDistance;
  final bool isMyMinyans;

  const FilterMinyansEvent({
    this.prayerType,
    this.sortBy,
    this.filterByDate,
    this.maxDistance,
    this.isMyMinyans = false,
  });

  @override
  List<Object?> get props => [prayerType, sortBy, filterByDate, maxDistance, isMyMinyans];
}

class JoinMinyanEvent extends MinyanEvent {
  final String minyanId;

  const JoinMinyanEvent(this.minyanId);

  @override
  List<Object?> get props => [minyanId];
}

class LeaveMinyanEvent extends MinyanEvent {
  final String minyanId;

  const LeaveMinyanEvent(this.minyanId);

  @override
  List<Object?> get props => [minyanId];
}

class DeleteMinyanEvent extends MinyanEvent {
  final String minyanId;

  const DeleteMinyanEvent(this.minyanId);

  @override
  List<Object?> get props => [minyanId];
}

class PublishMinyanEvent extends MinyanEvent {
  final String minyanId;

  const PublishMinyanEvent(this.minyanId);

  @override
  List<Object?> get props => [minyanId];
}

class RefreshMinyansEvent extends MinyanEvent {
  final bool isMyMinyans;

  const RefreshMinyansEvent({this.isMyMinyans = false});

  @override
  List<Object?> get props => [isMyMinyans];
}

// States
abstract class MinyanState extends Equatable {
  const MinyanState();

  @override
  List<Object?> get props => [];
}

class MinyanInitial extends MinyanState {
  const MinyanInitial();
}

class MinyanLoading extends MinyanState {
  final bool isMyMinyans;

  const MinyanLoading({this.isMyMinyans = false});

  @override
  List<Object?> get props => [isMyMinyans];
}

class MyMinyanLoaded extends MinyanState {
  final List<Minyan> minyans;
  final String? filterPrayerType;
  final String? filterByDate;
  final double? maxDistance;

  const MyMinyanLoaded({
    required this.minyans,
    this.filterPrayerType,
    this.filterByDate,
    this.maxDistance,
  });

  @override
  List<Object?> get props => [minyans, filterPrayerType, filterByDate, maxDistance];
}

class NearbyMinyanLoaded extends MinyanState {
  final List<Minyan> minyans;
  final String? filterPrayerType;
  final String? sortBy;

  const NearbyMinyanLoaded({
    required this.minyans,
    this.filterPrayerType,
    this.sortBy = 'distance',
  });

  @override
  List<Object?> get props => [minyans, filterPrayerType, sortBy];
}

class MinyanError extends MinyanState {
  final String message;

  const MinyanError(this.message);

  @override
  List<Object?> get props => [message];
}

class MinyanActionSuccess extends MinyanState {
  final String message;
  final String action;

  const MinyanActionSuccess({
    required this.message,
    required this.action,
  });

  @override
  List<Object?> get props => [message, action];
}

// BLoC
class MinyanBloc extends Bloc<MinyanEvent, MinyanState> {
  // Mock data storage
  final List<Minyan> _myMinyans = [];
  final List<Minyan> _nearbyMinyans = [];

  MinyanBloc() : super(const MinyanInitial()) {
    on<LoadMyMinyansEvent>(_onLoadMyMinyans);
    on<LoadNearbyMinyansEvent>(_onLoadNearbyMinyans);
    on<FilterMinyansEvent>(_onFilterMinyans);
    on<JoinMinyanEvent>(_onJoinMinyan);
    on<LeaveMinyanEvent>(_onLeaveMinyan);
    on<DeleteMinyanEvent>(_onDeleteMinyan);
    on<PublishMinyanEvent>(_onPublishMinyan);
    on<RefreshMinyansEvent>(_onRefreshMinyans);
  }

  Future<void> _onLoadMyMinyans(
    LoadMyMinyansEvent event,
    Emitter<MinyanState> emit,
  ) async {
    emit(const MinyanLoading(isMyMinyans: true));
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      // Initialize with mock data if empty
      if (_myMinyans.isEmpty) {
        _initializeMockMyMinyans();
      }

      // Only show published minyans
      final published = _myMinyans.where((m) => m.status == 'published').toList();

      emit(MyMinyanLoaded(minyans: published));
    } catch (e) {
      emit(MinyanError('Failed to load minyans: ${e.toString()}'));
    }
  }

  Future<void> _onLoadNearbyMinyans(
    LoadNearbyMinyansEvent event,
    Emitter<MinyanState> emit,
  ) async {
    emit(const MinyanLoading(isMyMinyans: false));
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      // Initialize with mock data if empty
      if (_nearbyMinyans.isEmpty) {
        _initializeMockNearbyMinyans();
      }

      // Filter by distance if provided
      final filtered = event.latitude != null && event.longitude != null
          ? _filterByDistance(
              _nearbyMinyans,
              event.latitude!,
              event.longitude!,
              event.radiusKm,
            )
          : _nearbyMinyans;

      // Sort by distance
      filtered.sort((a, b) => (a.distance ?? 0).compareTo(b.distance ?? 0));

      emit(NearbyMinyanLoaded(minyans: filtered));
    } catch (e) {
      emit(MinyanError('Failed to load nearby minyans: ${e.toString()}'));
    }
  }

  Future<void> _onFilterMinyans(
    FilterMinyansEvent event,
    Emitter<MinyanState> emit,
  ) async {
    try {
      if (event.isMyMinyans) {
        // My Minyans filtering
        final published = _myMinyans.where((m) => m.status == 'published').toList();
        var filtered = List<Minyan>.from(published);

        // Filter by prayer type
        if (event.prayerType != null) {
          filtered = filtered.where((m) => m.prayerType == event.prayerType).toList();
        }

        // Filter by date
        if (event.filterByDate != null) {
          filtered = filtered.where((m) => m.date == event.filterByDate).toList();
        }

        // Filter by distance (using user's location)
        if (event.maxDistance != null) {
          const userLat = 40.7128;
          const userLon = -74.0060;
          filtered = filtered.where((m) {
            final distance = _calculateDistance(userLat, userLon, m.latitude, m.longitude);
            final distanceInMiles = distance / 1.60934;
            return distanceInMiles <= event.maxDistance!;
          }).toList();
        }

        emit(MyMinyanLoaded(
          minyans: filtered,
          filterPrayerType: event.prayerType,
          filterByDate: event.filterByDate,
          maxDistance: event.maxDistance,
        ));
      } else if (state is NearbyMinyanLoaded) {
        // Nearby Minyans filtering
        final current = state as NearbyMinyanLoaded;
        var filtered = event.prayerType != null
            ? current.minyans
                .where((m) => m.prayerType == event.prayerType)
                .toList()
            : List<Minyan>.from(current.minyans);

        // Sort
        if (event.sortBy == 'time') {
          filtered.sort((a, b) => a.time.compareTo(b.time));
        } else if (event.sortBy == 'distance') {
          filtered.sort((a, b) => (a.distance ?? 0).compareTo(b.distance ?? 0));
        }

        emit(NearbyMinyanLoaded(
          minyans: filtered,
          filterPrayerType: event.prayerType,
          sortBy: event.sortBy,
        ));
      }
    } catch (e) {
      emit(MinyanError('Filter failed: ${e.toString()}'));
    }
  }

  Future<void> _onJoinMinyan(
    JoinMinyanEvent event,
    Emitter<MinyanState> emit,
  ) async {
    try {
      final index = _nearbyMinyans.indexWhere((m) => m.id == event.minyanId);
      if (index != -1) {
        final minyan = _nearbyMinyans[index];
        _nearbyMinyans[index] = Minyan(
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
          participantCount: minyan.participantCount + 1,
          createdAt: minyan.createdAt,
          updatedAt: minyan.updatedAt,
          distance: minyan.distance,
        );

        emit(MinyanActionSuccess(
          message: 'Successfully joined minyan',
          action: 'joined',
        ));

        add(const LoadNearbyMinyansEvent());
      }
    } catch (e) {
      emit(MinyanError('Failed to join minyan: ${e.toString()}'));
    }
  }

  Future<void> _onLeaveMinyan(
    LeaveMinyanEvent event,
    Emitter<MinyanState> emit,
  ) async {
    try {
      final index = _nearbyMinyans.indexWhere((m) => m.id == event.minyanId);
      if (index != -1) {
        final minyan = _nearbyMinyans[index];
        if (minyan.participantCount > 1) {
          _nearbyMinyans[index] = Minyan(
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
            participantCount: minyan.participantCount - 1,
            createdAt: minyan.createdAt,
            updatedAt: minyan.updatedAt,
            distance: minyan.distance,
          );
        }

        emit(MinyanActionSuccess(
          message: 'Left minyan',
          action: 'left',
        ));

        add(const LoadNearbyMinyansEvent());
      }
    } catch (e) {
      emit(MinyanError('Failed to leave minyan: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteMinyan(
    DeleteMinyanEvent event,
    Emitter<MinyanState> emit,
  ) async {
    try {
      _myMinyans.removeWhere((m) => m.id == event.minyanId);

      emit(MinyanActionSuccess(
        message: 'Minyan deleted',
        action: 'deleted',
      ));

      add(const LoadMyMinyansEvent());
    } catch (e) {
      emit(MinyanError('Failed to delete minyan: ${e.toString()}'));
    }
  }

  Future<void> _onPublishMinyan(
    PublishMinyanEvent event,
    Emitter<MinyanState> emit,
  ) async {
    try {
      final index = _myMinyans.indexWhere((m) => m.id == event.minyanId);
      if (index != -1) {
        final minyan = _myMinyans[index];
        _myMinyans[index] = Minyan(
          id: minyan.id,
          userId: minyan.userId,
          prayerType: minyan.prayerType,
          date: minyan.date,
          time: minyan.time,
          locationName: minyan.locationName,
          latitude: minyan.latitude,
          longitude: minyan.longitude,
          notes: minyan.notes,
          status: 'published',
          participantCount: minyan.participantCount,
          createdAt: minyan.createdAt,
          updatedAt: DateTime.now(),
        );

        // Add to nearby minyans as well
        if (!_nearbyMinyans.any((m) => m.id == minyan.id)) {
          _nearbyMinyans.add(_myMinyans[index]);
        }

        emit(MinyanActionSuccess(
          message: 'Minyan published',
          action: 'published',
        ));

        add(const LoadMyMinyansEvent());
      }
    } catch (e) {
      emit(MinyanError('Failed to publish minyan: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshMinyans(
    RefreshMinyansEvent event,
    Emitter<MinyanState> emit,
  ) async {
    if (event.isMyMinyans) {
      add(const LoadMyMinyansEvent());
    } else {
      add(const LoadNearbyMinyansEvent());
    }
  }

  void _initializeMockMyMinyans() {
    _myMinyans.addAll([
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
        status: 'draft',
        participantCount: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
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
        participantCount: 3,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isCreatedByUser: true,
      ),
    ]);
  }

  void _initializeMockNearbyMinyans() {
    _nearbyMinyans.addAll([
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
      ),
      Minyan(
        id: '5',
        userId: 'user101',
        prayerType: 'Mincha',
        date: '2024-12-16',
        time: '14:00',
        locationName: 'Riverside Congregation',
        latitude: 40.7900,
        longitude: -74.0100,
        notes: 'Community afternoon service',
        status: 'published',
        participantCount: 5,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        distance: 7.3,
      ),
    ]);
  }

  List<Minyan> _filterByDistance(
    List<Minyan> minyans,
    double latitude,
    double longitude,
    double radiusKm,
  ) {
    return minyans.where((minyan) {
      final distance = _calculateDistance(
        latitude,
        longitude,
        minyan.latitude,
        minyan.longitude,
      );
      return distance <= radiusKm;
    }).toList();
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadiusKm = 6371.0;
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);
    final a = (sin(dLat / 2) * sin(dLat / 2)) +
        (cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2));
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusKm * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (3.14159265359 / 180);
  }
}
