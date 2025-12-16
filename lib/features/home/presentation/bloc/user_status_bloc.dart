import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Events
abstract class UserStatusEvent extends Equatable {
  const UserStatusEvent();

  @override
  List<Object?> get props => [];
}

class UpdateUserStatusEvent extends UserStatusEvent {
  final String userId;
  final String status; // 'online', 'offline', 'searching'
  final bool isAvailable;

  const UpdateUserStatusEvent({
    required this.userId,
    required this.status,
    required this.isAvailable,
  });

  @override
  List<Object?> get props => [userId, status, isAvailable];
}

class SetUnavailableEvent extends UserStatusEvent {
  final String userId;
  final int minutes; // 5, 7, 10, or 15

  const SetUnavailableEvent({
    required this.userId,
    required this.minutes,
  });

  @override
  List<Object?> get props => [userId, minutes];
}

class UpdateUserLocationEvent extends UserStatusEvent {
  final String userId;
  final double latitude;
  final double longitude;
  final int radiusKm;

  const UpdateUserLocationEvent({
    required this.userId,
    required this.latitude,
    required this.longitude,
    required this.radiusKm,
  });

  @override
  List<Object?> get props => [userId, latitude, longitude, radiusKm];
}

// States
abstract class UserStatusState extends Equatable {
  const UserStatusState();

  @override
  List<Object?> get props => [];
}

class UserStatusInitial extends UserStatusState {
  const UserStatusInitial();
}

class UserStatusLoading extends UserStatusState {
  const UserStatusLoading();
}

class UserStatusLoaded extends UserStatusState {
  final String userId;
  final String status; // 'online', 'offline', 'searching'
  final bool isAvailable;
  final DateTime? unavailableUntil;
  final double? latitude;
  final double? longitude;
  final int radiusKm;

  const UserStatusLoaded({
    required this.userId,
    required this.status,
    required this.isAvailable,
    this.unavailableUntil,
    this.latitude,
    this.longitude,
    this.radiusKm = 10,
  });

  UserStatusLoaded copyWith({
    String? userId,
    String? status,
    bool? isAvailable,
    DateTime? unavailableUntil,
    double? latitude,
    double? longitude,
    int? radiusKm,
  }) {
    return UserStatusLoaded(
      userId: userId ?? this.userId,
      status: status ?? this.status,
      isAvailable: isAvailable ?? this.isAvailable,
      unavailableUntil: unavailableUntil ?? this.unavailableUntil,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radiusKm: radiusKm ?? this.radiusKm,
    );
  }

  @override
  List<Object?> get props => [
    userId,
    status,
    isAvailable,
    unavailableUntil,
    latitude,
    longitude,
    radiusKm,
  ];
}

class UserStatusError extends UserStatusState {
  final String message;

  const UserStatusError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class UserStatusBloc extends Bloc<UserStatusEvent, UserStatusState> {
  UserStatusBloc() : super(const UserStatusInitial()) {
    on<UpdateUserStatusEvent>(_onUpdateUserStatus);
    on<SetUnavailableEvent>(_onSetUnavailable);
    on<UpdateUserLocationEvent>(_onUpdateUserLocation);
  }

  Future<void> _onUpdateUserStatus(
    UpdateUserStatusEvent event,
    Emitter<UserStatusState> emit,
  ) async {
    try {
      emit(const UserStatusLoading());
      
      // Simulate API call to update user status
      await Future.delayed(const Duration(milliseconds: 300));

      if (state is UserStatusLoaded) {
        final currentState = state as UserStatusLoaded;
        emit(currentState.copyWith(
          status: event.status,
          isAvailable: event.isAvailable,
        ));
      } else {
        emit(UserStatusLoaded(
          userId: event.userId,
          status: event.status,
          isAvailable: event.isAvailable,
        ));
      }
    } catch (e) {
      emit(UserStatusError('Failed to update status: ${e.toString()}'));
    }
  }

  Future<void> _onSetUnavailable(
    SetUnavailableEvent event,
    Emitter<UserStatusState> emit,
  ) async {
    try {
      emit(const UserStatusLoading());

      // Calculate unavailable until time
      final unavailableUntil = DateTime.now().add(Duration(minutes: event.minutes));

      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 300));

      if (state is UserStatusLoaded) {
        final currentState = state as UserStatusLoaded;
        emit(currentState.copyWith(
          isAvailable: false,
          unavailableUntil: unavailableUntil,
        ));
      } else {
        emit(UserStatusLoaded(
          userId: event.userId,
          status: 'offline',
          isAvailable: false,
          unavailableUntil: unavailableUntil,
        ));
      }
    } catch (e) {
      emit(UserStatusError('Failed to set unavailable: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateUserLocation(
    UpdateUserLocationEvent event,
    Emitter<UserStatusState> emit,
  ) async {
    try {
      if (state is UserStatusLoaded) {
        final currentState = state as UserStatusLoaded;
        emit(currentState.copyWith(
          latitude: event.latitude,
          longitude: event.longitude,
          radiusKm: event.radiusKm,
        ));
      }
    } catch (e) {
      emit(UserStatusError('Failed to update location: ${e.toString()}'));
    }
  }
}
