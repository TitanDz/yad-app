import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yad_app/core/services/prayer_countdown_service.dart';

// Events
abstract class PrayerTimerEvent extends Equatable {
  const PrayerTimerEvent();

  @override
  List<Object?> get props => [];
}

class InitializePrayerTimerEvent extends PrayerTimerEvent {
  final double latitude;
  final double longitude;
  final String timeZone;

  const InitializePrayerTimerEvent({
    required this.latitude,
    required this.longitude,
    required this.timeZone,
  });

  @override
  List<Object?> get props => [latitude, longitude, timeZone];
}

class PrayerTimerTickEvent extends PrayerTimerEvent {
  const PrayerTimerTickEvent();
}

class StopPrayerTimerEvent extends PrayerTimerEvent {
  const StopPrayerTimerEvent();
}

// States
abstract class PrayerTimerState extends Equatable {
  const PrayerTimerState();

  @override
  List<Object?> get props => [];
}

class PrayerTimerInitial extends PrayerTimerState {
  const PrayerTimerInitial();
}

class PrayerTimerRunning extends PrayerTimerState {
  final String nextPrayerName;
  final DateTime nextPrayerTime;
  final Duration timeRemaining;
  final int usersNearby;
  final bool shouldTriggerNotification; // True 30 mins before prayer
  final String notificationMessage;

  const PrayerTimerRunning({
    required this.nextPrayerName,
    required this.nextPrayerTime,
    required this.timeRemaining,
    required this.usersNearby,
    required this.shouldTriggerNotification,
    required this.notificationMessage,
  });

  @override
  List<Object?> get props => [
    nextPrayerName,
    nextPrayerTime,
    timeRemaining,
    usersNearby,
    shouldTriggerNotification,
    notificationMessage,
  ];
}

class PrayerTimerStopped extends PrayerTimerState {
  const PrayerTimerStopped();
}

class PrayerTimerError extends PrayerTimerState {
  final String message;

  const PrayerTimerError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class PrayerTimerBloc extends Bloc<PrayerTimerEvent, PrayerTimerState> {
  final PrayerCountdownService prayerCountdownService;
  Timer? _checkTimer;
  DateTime? _lastNotificationTime;

  PrayerTimerBloc({required this.prayerCountdownService})
      : super(const PrayerTimerInitial()) {
    on<InitializePrayerTimerEvent>(_onInitializePrayerTimer);
    on<PrayerTimerTickEvent>(_onPrayerTimerTick);
    on<StopPrayerTimerEvent>(_onStopPrayerTimer);
  }

  Future<void> _onInitializePrayerTimer(
    InitializePrayerTimerEvent event,
    Emitter<PrayerTimerState> emit,
  ) async {
    try {
      // Initialize prayer countdown service
      prayerCountdownService.initialize(
        latitude: event.latitude,
        longitude: event.longitude,
        timeZone: event.timeZone,
      );

      // Start checking for 30-minute pre-prayer condition every 10 seconds
      _checkTimer?.cancel();
      _checkTimer = Timer.periodic(const Duration(seconds: 10), (_) {
        add(const PrayerTimerTickEvent());
      });

      // Emit initial state
      _emitPrayerTimerState(emit);
    } catch (e) {
      emit(PrayerTimerError('Failed to initialize prayer timer: ${e.toString()}'));
    }
  }

  Future<void> _onPrayerTimerTick(
    PrayerTimerTickEvent event,
    Emitter<PrayerTimerState> emit,
  ) async {
    try {
      _emitPrayerTimerState(emit);
    } catch (e) {
      emit(PrayerTimerError('Prayer timer error: ${e.toString()}'));
    }
  }

  Future<void> _onStopPrayerTimer(
    StopPrayerTimerEvent event,
    Emitter<PrayerTimerState> emit,
  ) async {
    _checkTimer?.cancel();
    prayerCountdownService.dispose();
    emit(const PrayerTimerStopped());
  }

  void _emitPrayerTimerState(Emitter<PrayerTimerState> emit) {
    try {
      final prayerTimes = prayerCountdownService.getPrayerTimes();
      
      if (prayerTimes.isEmpty) {
        emit(const PrayerTimerError('No prayer times available'));
        return;
      }

      // Find next upcoming prayer
      PrayerTimeInfo? nextPrayer;
      for (final prayer in prayerTimes) {
        if (!prayer.timeUntilStart.isNegative) {
          nextPrayer = prayer;
          break;
        }
      }

      // If no upcoming prayer today, use first prayer of next day
      nextPrayer ??= prayerTimes.first;

      final timeUntilPrayer = nextPrayer.timeUntilStart;
      
      // Check if we're within 30 minutes of prayer start
      final thirtyMinutes = const Duration(minutes: 30);
      final shouldTriggerNotification = 
          timeUntilPrayer.inSeconds > 0 && 
          timeUntilPrayer <= thirtyMinutes;

      // Avoid spamming notifications - only trigger once per prayer
      if (shouldTriggerNotification && 
          (_lastNotificationTime == null || 
           DateTime.now().difference(_lastNotificationTime!).inMinutes > 30)) {
        _lastNotificationTime = DateTime.now();
      }

      emit(PrayerTimerRunning(
        nextPrayerName: nextPrayer.name,
        nextPrayerTime: nextPrayer.startTime,
        timeRemaining: timeUntilPrayer,
        usersNearby: 0, // Will be updated by ActiveUsersBloc
        shouldTriggerNotification: shouldTriggerNotification,
        notificationMessage: shouldTriggerNotification
            ? '${nextPrayer.name}: 10+ people nearby. Would you like to join a minyan?'
            : 'Next prayer: ${nextPrayer.name} at ${nextPrayer.displayStartTime}',
      ));
    } catch (e) {
      emit(PrayerTimerError('Failed to emit prayer timer state: ${e.toString()}'));
    }
  }

  @override
  Future<void> close() {
    _checkTimer?.cancel();
    prayerCountdownService.dispose();
    return super.close();
  }
}
