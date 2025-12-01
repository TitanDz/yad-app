import 'dart:math';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yad_app/features/home/data/repositories/minyan_repository.dart';
import 'package:yad_app/features/home/domain/entities/minyan.dart';
import 'package:yad_app/config/service_locator.dart';
import 'package:yad_app/core/services/app_initialization_service.dart';
import 'package:yad_app/core/models/user_preferences.dart';
import 'package:yad_app/core/services/prayer_times_calculator.dart';

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

class LoadUserPreferencesEvent extends MinyanEvent {
  final String userId;

  const LoadUserPreferencesEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class LoadPrayerTimesEvent extends MinyanEvent {
  final double latitude;
  final double longitude;
  final String timeZone;
  final DateTime date;

  const LoadPrayerTimesEvent({
    required this.latitude,
    required this.longitude,
    required this.timeZone,
    required this.date,
  });

  @override
  List<Object?> get props => [latitude, longitude, timeZone, date];
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

class UserPreferencesLoaded extends MinyanState {
  final UserPreferences preferences;

  const UserPreferencesLoaded({required this.preferences});

  @override
  List<Object?> get props => [preferences];
}

class PrayerTimesLoaded extends MinyanState {
  final List<PrayerTime> prayerTimes;
  final List<String> suggestedTypes;
  final double latitude;
  final double longitude;
  final DateTime date;

  const PrayerTimesLoaded({
    required this.prayerTimes,
    required this.suggestedTypes,
    required this.latitude,
    required this.longitude,
    required this.date,
  });

  @override
  List<Object?> get props => [prayerTimes, suggestedTypes, latitude, longitude, date];
}

// BLoC
class MinyanBloc extends Bloc<MinyanEvent, MinyanState> {
  final MinyanRepository _minyanRepository;

  MinyanBloc({required MinyanRepository minyanRepository})
      : _minyanRepository = minyanRepository,
        super(const MinyanInitial()) {
    on<LoadMyMinyansEvent>(_onLoadMyMinyans);
    on<LoadNearbyMinyansEvent>(_onLoadNearbyMinyans);
    on<FilterMinyansEvent>(_onFilterMinyans);
    on<JoinMinyanEvent>(_onJoinMinyan);
    on<LeaveMinyanEvent>(_onLeaveMinyan);
    on<DeleteMinyanEvent>(_onDeleteMinyan);
    on<PublishMinyanEvent>(_onPublishMinyan);
    on<RefreshMinyansEvent>(_onRefreshMinyans);
    on<LoadUserPreferencesEvent>(_onLoadUserPreferences);
    on<LoadPrayerTimesEvent>(_onLoadPrayerTimes);
  }

  Future<void> _onLoadMyMinyans(
    LoadMyMinyansEvent event,
    Emitter<MinyanState> emit,
  ) async {
    emit(const MinyanLoading(isMyMinyans: true));
    try {
      // Load my minyans from repository
      final minyans = await _minyanRepository.getMyMinyans();
      emit(MyMinyanLoaded(minyans: minyans));
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
      // Load nearby minyans from repository
      final minyans = await _minyanRepository.getNearbyMinyans(
        latitude: event.latitude ?? 40.7128,
        longitude: event.longitude ?? -74.0060,
        radiusKm: event.radiusKm,
      );
      emit(NearbyMinyanLoaded(minyans: minyans));
    } catch (e) {
      emit(MinyanError('Failed to load nearby minyans: ${e.toString()}'));
    }
  }

  Future<void> _onFilterMinyans(
    FilterMinyansEvent event,
    Emitter<MinyanState> emit,
  ) async {
    try {
      if (event.isMyMinyans && state is MyMinyanLoaded) {
        // Load fresh data with filters
        final minyans = await _minyanRepository.getMyMinyans();
        var filtered = List<Minyan>.from(minyans);

        // Filter by prayer type
        if (event.prayerType != null) {
          filtered = filtered.where((m) => m.prayerType == event.prayerType).toList();
        }

        // Filter by date
        if (event.filterByDate != null) {
          filtered = filtered.where((m) => m.date == event.filterByDate).toList();
        }

        // Filter by distance
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
      } else if (!event.isMyMinyans && state is NearbyMinyanLoaded) {
        // Filter nearby minyans
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
      await _minyanRepository.joinMinyan(event.minyanId);
      emit(MinyanActionSuccess(
        message: 'Successfully joined minyan',
        action: 'joined',
      ));
      add(const LoadNearbyMinyansEvent());
    } catch (e) {
      emit(MinyanError('Failed to join minyan: ${e.toString()}'));
    }
  }

  Future<void> _onLeaveMinyan(
    LeaveMinyanEvent event,
    Emitter<MinyanState> emit,
  ) async {
    try {
      await _minyanRepository.leaveMinyan(event.minyanId);
      emit(MinyanActionSuccess(
        message: 'Left minyan',
        action: 'left',
      ));
      add(const LoadNearbyMinyansEvent());
    } catch (e) {
      emit(MinyanError('Failed to leave minyan: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteMinyan(
    DeleteMinyanEvent event,
    Emitter<MinyanState> emit,
  ) async {
    try {
      await _minyanRepository.deleteMinyan(event.minyanId);
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
      await _minyanRepository.publishMinyan(event.minyanId);
      emit(MinyanActionSuccess(
        message: 'Minyan published',
        action: 'published',
      ));
      add(const LoadMyMinyansEvent());
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

  Future<void> _onLoadUserPreferences(
    LoadUserPreferencesEvent event,
    Emitter<MinyanState> emit,
  ) async {
    try {
      final appInitService = getIt<AppInitializationService>();
      final preferences = await appInitService.getCachedPreferences(event.userId);
      if (preferences != null) {
        emit(UserPreferencesLoaded(preferences: preferences));
      }
    } catch (e) {
      print('[MinyanBloc] Failed to load user preferences: $e');
      // Non-blocking - don't emit error state
    }
  }

  Future<void> _onLoadPrayerTimes(
    LoadPrayerTimesEvent event,
    Emitter<MinyanState> emit,
  ) async {
    try {
      final prayerTimes = PrayerTimesCalculator.calculatePrayerTimes(
        latitude: event.latitude,
        longitude: event.longitude,
        date: event.date,
        timeZone: event.timeZone,
      );

      final suggestedTypes = PrayerTimesCalculator.getSuggestedPrayerTypes(
        latitude: event.latitude,
        longitude: event.longitude,
        now: DateTime.now(),
        timeZone: event.timeZone,
      );

      emit(PrayerTimesLoaded(
        prayerTimes: prayerTimes,
        suggestedTypes: suggestedTypes,
        latitude: event.latitude,
        longitude: event.longitude,
        date: event.date,
      ));
    } catch (e) {
      print('[MinyanBloc] Failed to load prayer times: $e');
      // Non-blocking - don't emit error state
    }
  }
}