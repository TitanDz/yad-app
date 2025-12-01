import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yad_app/core/models/unavailability_status.dart';
import 'dart:async';

// Events
abstract class AvailabilityEvent extends Equatable {
  const AvailabilityEvent();

  @override
  List<Object?> get props => [];
}

class InitializeAvailabilityEvent extends AvailabilityEvent {
  final String userId;

  const InitializeAvailabilityEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class SetUnavailableEvent extends AvailabilityEvent {
  final String userId;
  final Duration duration;
  final String reason;

  const SetUnavailableEvent({
    required this.userId,
    this.duration = const Duration(minutes: 30),
    this.reason = 'Do not disturb',
  });

  @override
  List<Object?> get props => [userId, duration, reason];
}

class SetAvailableEvent extends AvailabilityEvent {
  final String userId;

  const SetAvailableEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class UpdateAvailabilityEvent extends AvailabilityEvent {
  const UpdateAvailabilityEvent();

  @override
  List<Object?> get props => [];
}

// States
abstract class AvailabilityState extends Equatable {
  const AvailabilityState();

  @override
  List<Object?> get props => [];
}

class AvailabilityInitial extends AvailabilityState {
  const AvailabilityInitial();
}

class AvailabilityLoading extends AvailabilityState {
  const AvailabilityLoading();
}

class AvailabilityLoaded extends AvailabilityState {
  final UnavailabilityStatus status;
  final int? remainingMinutes;

  const AvailabilityLoaded({
    required this.status,
    this.remainingMinutes,
  });

  AvailabilityLoaded copyWith({
    UnavailabilityStatus? status,
    int? remainingMinutes,
  }) {
    return AvailabilityLoaded(
      status: status ?? this.status,
      remainingMinutes: remainingMinutes ?? this.remainingMinutes,
    );
  }

  @override
  List<Object?> get props => [status, remainingMinutes];
}

class AvailabilityError extends AvailabilityState {
  final String message;

  const AvailabilityError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class AvailabilityBloc extends Bloc<AvailabilityEvent, AvailabilityState> {
  late UnavailabilityStatus _currentStatus;
  Timer? _countdownTimer;

  AvailabilityBloc() : super(const AvailabilityInitial()) {
    on<InitializeAvailabilityEvent>(_onInitialize);
    on<SetUnavailableEvent>(_onSetUnavailable);
    on<SetAvailableEvent>(_onSetAvailable);
    on<UpdateAvailabilityEvent>(_onUpdateAvailability);
  }

  Future<void> _onInitialize(
    InitializeAvailabilityEvent event,
    Emitter<AvailabilityState> emit,
  ) async {
    emit(const AvailabilityLoading());
    try {
      // Initialize with available status
      _currentStatus = UnavailabilityStatus.available(userId: event.userId);
      emit(AvailabilityLoaded(
        status: _currentStatus,
        remainingMinutes: null,
      ));
      _startCountdownTimer();
    } catch (e) {
      emit(AvailabilityError('Failed to initialize availability: $e'));
    }
  }

  Future<void> _onSetUnavailable(
    SetUnavailableEvent event,
    Emitter<AvailabilityState> emit,
  ) async {
    try {
      final now = DateTime.now();
      _currentStatus = UnavailabilityStatus(
        userId: event.userId,
        isUnavailable: true,
        unavailableUntil: now.add(event.duration),
        reason: event.reason,
        createdAt: now,
        updatedAt: now,
      );
      
      emit(AvailabilityLoaded(
        status: _currentStatus,
        remainingMinutes: event.duration.inMinutes,
      ));
      
      _startCountdownTimer();
    } catch (e) {
      emit(AvailabilityError('Failed to set unavailable: $e'));
    }
  }

  Future<void> _onSetAvailable(
    SetAvailableEvent event,
    Emitter<AvailabilityState> emit,
  ) async {
    try {
      _currentStatus = UnavailabilityStatus.available(userId: event.userId);
      emit(AvailabilityLoaded(
        status: _currentStatus,
        remainingMinutes: null,
      ));
      _stopCountdownTimer();
    } catch (e) {
      emit(AvailabilityError('Failed to set available: $e'));
    }
  }

  Future<void> _onUpdateAvailability(
    UpdateAvailabilityEvent event,
    Emitter<AvailabilityState> emit,
  ) async {
    if (state is AvailabilityLoaded) {
      final currentState = state as AvailabilityLoaded;
      
      if (_currentStatus.isCurrentlyUnavailable) {
        final remainingMinutes = _currentStatus.remainingMinutes;
        emit(AvailabilityLoaded(
          status: _currentStatus,
          remainingMinutes: remainingMinutes,
        ));
      } else if (_currentStatus.isUnavailable && !_currentStatus.isCurrentlyUnavailable) {
        // Unavailability expired, reset to available
        _currentStatus = UnavailabilityStatus.available(userId: _currentStatus.userId);
        emit(AvailabilityLoaded(
          status: _currentStatus,
          remainingMinutes: null,
        ));
        _stopCountdownTimer();
      }
    }
  }

  void _startCountdownTimer() {
    _stopCountdownTimer();
    _countdownTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      add(const UpdateAvailabilityEvent());
    });
  }

  void _stopCountdownTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
  }

  @override
  Future<void> close() {
    _stopCountdownTimer();
    return super.close();
  }
}
