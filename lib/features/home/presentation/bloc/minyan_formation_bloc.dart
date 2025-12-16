import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yad_app/features/home/domain/entities/minyan.dart';

// Events
abstract class MinyanFormationEvent extends Equatable {
  const MinyanFormationEvent();

  @override
  List<Object?> get props => [];
}

class CheckUserThresholdEvent extends MinyanFormationEvent {
  final String prayerType;
  final double latitude;
  final double longitude;
  final double radiusKm;
  final int nearbyUserCount;

  const CheckUserThresholdEvent({
    required this.prayerType,
    required this.latitude,
    required this.longitude,
    required this.radiusKm,
    required this.nearbyUserCount,
  });

  @override
  List<Object?> get props => [
    prayerType,
    latitude,
    longitude,
    radiusKm,
    nearbyUserCount,
  ];
}

class TriggerMinyanPromptEvent extends MinyanFormationEvent {
  final String prayerType;
  final int userCount;
  final double latitude;
  final double longitude;
  final DateTime prayerTime;

  const TriggerMinyanPromptEvent({
    required this.prayerType,
    required this.userCount,
    required this.latitude,
    required this.longitude,
    required this.prayerTime,
  });

  @override
  List<Object?> get props => [prayerType, userCount, latitude, longitude, prayerTime];
}

class ConfirmUserParticipationEvent extends MinyanFormationEvent {
  final String userId;
  final bool confirmed;
  final int? availableInMinutes; // 5, 7, 10, or 15

  const ConfirmUserParticipationEvent({
    required this.userId,
    required this.confirmed,
    this.availableInMinutes,
  });

  @override
  List<Object?> get props => [userId, confirmed, availableInMinutes];
}

class FormMinyanEvent extends MinyanFormationEvent {
  final List<String> confirmedUserIds;
  final String prayerType;
  final double latitude;
  final double longitude;
  final DateTime prayerTime;

  const FormMinyanEvent({
    required this.confirmedUserIds,
    required this.prayerType,
    required this.latitude,
    required this.longitude,
    required this.prayerTime,
  });

  @override
  List<Object?> get props => [
    confirmedUserIds,
    prayerType,
    latitude,
    longitude,
    prayerTime,
  ];
}

class ResetFormationEvent extends MinyanFormationEvent {
  const ResetFormationEvent();
}

// States
abstract class MinyanFormationState extends Equatable {
  const MinyanFormationState();

  @override
  List<Object?> get props => [];
}

class MinyanFormationInitial extends MinyanFormationState {
  const MinyanFormationInitial();
}

class MinyanFormationChecking extends MinyanFormationState {
  const MinyanFormationChecking();
}

class InsufficientUsersDetected extends MinyanFormationState {
  final int userCount;
  final int requiredCount;

  const InsufficientUsersDetected({
    required this.userCount,
    required this.requiredCount,
  });

  @override
  List<Object?> get props => [userCount, requiredCount];
}

class MinyanPromptShown extends MinyanFormationState {
  final String prayerType;
  final int userCount;
  final DateTime prayerTime;
  final double latitude;
  final double longitude;

  const MinyanPromptShown({
    required this.prayerType,
    required this.userCount,
    required this.prayerTime,
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [prayerType, userCount, prayerTime, latitude, longitude];
}

class AwaitingUserConfirmations extends MinyanFormationState {
  final String prayerType;
  final int confirmations;
  final int targetCount; // 10
  final List<String> confirmedUserIds;
  final DateTime prayerTime;

  const AwaitingUserConfirmations({
    required this.prayerType,
    required this.confirmations,
    required this.targetCount,
    required this.confirmedUserIds,
    required this.prayerTime,
  });

  @override
  List<Object?> get props => [
    prayerType,
    confirmations,
    targetCount,
    confirmedUserIds,
    prayerTime,
  ];
}

class MinyanFormed extends MinyanFormationState {
  final Minyan minyan;
  final List<String> confirmedUserIds;
  final String prayerType;

  const MinyanFormed({
    required this.minyan,
    required this.confirmedUserIds,
    required this.prayerType,
  });

  @override
  List<Object?> get props => [minyan, confirmedUserIds, prayerType];
}

class MinyanFormationError extends MinyanFormationState {
  final String message;

  const MinyanFormationError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class MinyanFormationBloc extends Bloc<MinyanFormationEvent, MinyanFormationState> {
  static const int MIN_USERS_FOR_MINYAN = 10;

  MinyanFormationBloc() : super(const MinyanFormationInitial()) {
    on<CheckUserThresholdEvent>(_onCheckUserThreshold);
    on<TriggerMinyanPromptEvent>(_onTriggerMinyanPrompt);
    on<ConfirmUserParticipationEvent>(_onConfirmUserParticipation);
    on<FormMinyanEvent>(_onFormMinyan);
    on<ResetFormationEvent>(_onResetFormation);
  }

  Future<void> _onCheckUserThreshold(
    CheckUserThresholdEvent event,
    Emitter<MinyanFormationState> emit,
  ) async {
    try {
      emit(const MinyanFormationChecking());

      // Check if enough users are nearby
      if (event.nearbyUserCount >= MIN_USERS_FOR_MINYAN) {
        // Sufficient users - trigger the prompt
        emit(MinyanPromptShown(
          prayerType: event.prayerType,
          userCount: event.nearbyUserCount,
          prayerTime: DateTime.now().add(const Duration(minutes: 30)),
          latitude: event.latitude,
          longitude: event.longitude,
        ));
      } else {
        // Insufficient users
        emit(InsufficientUsersDetected(
          userCount: event.nearbyUserCount,
          requiredCount: MIN_USERS_FOR_MINYAN,
        ));
      }
    } catch (e) {
      emit(MinyanFormationError('Failed to check user threshold: ${e.toString()}'));
    }
  }

  Future<void> _onTriggerMinyanPrompt(
    TriggerMinyanPromptEvent event,
    Emitter<MinyanFormationState> emit,
  ) async {
    try {
      emit(MinyanPromptShown(
        prayerType: event.prayerType,
        userCount: event.userCount,
        prayerTime: event.prayerTime,
        latitude: event.latitude,
        longitude: event.longitude,
      ));

      // Initialize waiting state
      emit(AwaitingUserConfirmations(
        prayerType: event.prayerType,
        confirmations: 0,
        targetCount: MIN_USERS_FOR_MINYAN,
        confirmedUserIds: const [],
        prayerTime: event.prayerTime,
      ));
    } catch (e) {
      emit(MinyanFormationError('Failed to trigger minyan prompt: ${e.toString()}'));
    }
  }

  Future<void> _onConfirmUserParticipation(
    ConfirmUserParticipationEvent event,
    Emitter<MinyanFormationState> emit,
  ) async {
    try {
      if (state is AwaitingUserConfirmations) {
        final currentState = state as AwaitingUserConfirmations;

        if (event.confirmed) {
          // User confirmed participation
          final updatedConfirmed = [...currentState.confirmedUserIds, event.userId];
          final newConfirmationCount = updatedConfirmed.length;

          if (newConfirmationCount >= MIN_USERS_FOR_MINYAN) {
            // Threshold reached - form the minyan
            add(FormMinyanEvent(
              confirmedUserIds: updatedConfirmed,
              prayerType: currentState.prayerType,
              latitude: 0.0, // Will be updated with actual location
              longitude: 0.0,
              prayerTime: currentState.prayerTime,
            ));
          } else {
            // Update confirmation count
            emit(AwaitingUserConfirmations(
              prayerType: currentState.prayerType,
              confirmations: newConfirmationCount,
              targetCount: MIN_USERS_FOR_MINYAN,
              confirmedUserIds: updatedConfirmed,
              prayerTime: currentState.prayerTime,
            ));
          }
        } else {
          // User declined - check if still waiting for more confirmations
          emit(currentState);
        }
      }
    } catch (e) {
      emit(MinyanFormationError('Failed to confirm participation: ${e.toString()}'));
    }
  }

  Future<void> _onFormMinyan(
    FormMinyanEvent event,
    Emitter<MinyanFormationState> emit,
  ) async {
    try {
      // Create minyan object
      final newMinyan = Minyan(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: event.confirmedUserIds.isNotEmpty ? event.confirmedUserIds.first : 'system',
        prayerType: event.prayerType,
        date: '${event.prayerTime.year}-${event.prayerTime.month.toString().padLeft(2, '0')}-${event.prayerTime.day.toString().padLeft(2, '0')}',
        time: '${event.prayerTime.hour.toString().padLeft(2, '0')}:${event.prayerTime.minute.toString().padLeft(2, '0')}',
        locationName: 'TBD - Vote on location',
        latitude: event.latitude,
        longitude: event.longitude,
        notes: 'Auto-formed minyan from ${event.confirmedUserIds.length} confirmed users',
        status: 'confirmed',
        participantCount: event.confirmedUserIds.length,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isCreatedByUser: false,
      );

      emit(MinyanFormed(
        minyan: newMinyan,
        confirmedUserIds: event.confirmedUserIds,
        prayerType: event.prayerType,
      ));
    } catch (e) {
      emit(MinyanFormationError('Failed to form minyan: ${e.toString()}'));
    }
  }

  Future<void> _onResetFormation(
    ResetFormationEvent event,
    Emitter<MinyanFormationState> emit,
  ) async {
    emit(const MinyanFormationInitial());
  }
}
