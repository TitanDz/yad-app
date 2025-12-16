import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yad_app/features/home/domain/entities/active_user_marker.dart';
import 'package:yad_app/features/home/data/datasources/active_users_datasource.dart';

// Events
abstract class ActiveUsersEvent extends Equatable {
  const ActiveUsersEvent();

  @override
  List<Object?> get props => [];
}

class LoadNearbyUsersEvent extends ActiveUsersEvent {
  final double latitude;
  final double longitude;
  final double radiusKm;
  final String? prayerType;

  const LoadNearbyUsersEvent({
    required this.latitude,
    required this.longitude,
    required this.radiusKm,
    this.prayerType,
  });

  @override
  List<Object?> get props => [latitude, longitude, radiusKm, prayerType];
}

class RefreshNearbyUsersEvent extends ActiveUsersEvent {
  const RefreshNearbyUsersEvent();
}

class FilterByPrayerTypeEvent extends ActiveUsersEvent {
  final String prayerType;

  const FilterByPrayerTypeEvent(this.prayerType);

  @override
  List<Object?> get props => [prayerType];
}

// States
abstract class ActiveUsersState extends Equatable {
  const ActiveUsersState();

  @override
  List<Object?> get props => [];
}

class ActiveUsersInitial extends ActiveUsersState {
  const ActiveUsersInitial();
}

class ActiveUsersLoading extends ActiveUsersState {
  const ActiveUsersLoading();
}

class ActiveUsersLoaded extends ActiveUsersState {
  final List<ActiveUserMarker> users;
  final int totalCount;
  final double latitude;
  final double longitude;
  final double radiusKm;
  final String? filterPrayerType;

  const ActiveUsersLoaded({
    required this.users,
    required this.totalCount,
    required this.latitude,
    required this.longitude,
    required this.radiusKm,
    this.filterPrayerType,
  });

  ActiveUsersLoaded copyWith({
    List<ActiveUserMarker>? users,
    int? totalCount,
    double? latitude,
    double? longitude,
    double? radiusKm,
    String? filterPrayerType,
  }) {
    return ActiveUsersLoaded(
      users: users ?? this.users,
      totalCount: totalCount ?? this.totalCount,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radiusKm: radiusKm ?? this.radiusKm,
      filterPrayerType: filterPrayerType ?? this.filterPrayerType,
    );
  }

  @override
  List<Object?> get props => [
    users,
    totalCount,
    latitude,
    longitude,
    radiusKm,
    filterPrayerType,
  ];
}

class ActiveUsersEmpty extends ActiveUsersState {
  const ActiveUsersEmpty();
}

class ActiveUsersError extends ActiveUsersState {
  final String message;

  const ActiveUsersError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class ActiveUsersBloc extends Bloc<ActiveUsersEvent, ActiveUsersState> {
  final ActiveUsersDataSource dataSource;

  ActiveUsersBloc({required this.dataSource}) : super(const ActiveUsersInitial()) {
    on<LoadNearbyUsersEvent>(_onLoadNearbyUsers);
    on<RefreshNearbyUsersEvent>(_onRefreshNearbyUsers);
    on<FilterByPrayerTypeEvent>(_onFilterByPrayerType);
  }

  Future<void> _onLoadNearbyUsers(
    LoadNearbyUsersEvent event,
    Emitter<ActiveUsersState> emit,
  ) async {
    try {
      emit(const ActiveUsersLoading());

      // Fetch nearby active users
      final users = await dataSource.getNearbyActiveUsers(
        latitude: event.latitude,
        longitude: event.longitude,
        radiusKm: event.radiusKm,
      );

      if (users.isEmpty) {
        emit(const ActiveUsersEmpty());
      } else {
        // Filter by prayer type if provided
        final filtered = event.prayerType != null
            ? users
                .where((u) => u.lastPrayerType == event.prayerType)
                .toList()
            : users;

        emit(ActiveUsersLoaded(
          users: filtered,
          totalCount: users.length,
          latitude: event.latitude,
          longitude: event.longitude,
          radiusKm: event.radiusKm,
          filterPrayerType: event.prayerType,
        ));
      }
    } catch (e) {
      emit(ActiveUsersError('Failed to load nearby users: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshNearbyUsers(
    RefreshNearbyUsersEvent event,
    Emitter<ActiveUsersState> emit,
  ) async {
    if (state is ActiveUsersLoaded) {
      final currentState = state as ActiveUsersLoaded;
      add(LoadNearbyUsersEvent(
        latitude: currentState.latitude,
        longitude: currentState.longitude,
        radiusKm: currentState.radiusKm,
        prayerType: currentState.filterPrayerType,
      ));
    }
  }

  Future<void> _onFilterByPrayerType(
    FilterByPrayerTypeEvent event,
    Emitter<ActiveUsersState> emit,
  ) async {
    if (state is ActiveUsersLoaded) {
      final currentState = state as ActiveUsersLoaded;
      final filtered = currentState.users
          .where((u) => u.lastPrayerType == event.prayerType)
          .toList();

      emit(currentState.copyWith(
        users: filtered,
        filterPrayerType: event.prayerType,
      ));
    }
  }
}
