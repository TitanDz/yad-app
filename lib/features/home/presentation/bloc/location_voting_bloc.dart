import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yad_app/core/services/centroid_calculation_service.dart';
import 'package:yad_app/features/home/domain/entities/location_suggestion.dart';
import 'package:yad_app/features/home/domain/entities/voting_session.dart';
import 'package:yad_app/features/home/domain/entities/minyan.dart';

// Events
abstract class LocationVotingEvent extends Equatable {
  const LocationVotingEvent();

  @override
  List<Object?> get props => [];
}

class InitializeVotingSessionEvent extends LocationVotingEvent {
  final Minyan minyan;
  final List<String> participantIds;

  const InitializeVotingSessionEvent({
    required this.minyan,
    required this.participantIds,
  });

  @override
  List<Object?> get props => [minyan, participantIds];
}

class AddLocationSuggestionEvent extends LocationVotingEvent {
  final String name;
  final String? address;
  final double latitude;
  final double longitude;
  final String userId;

  const AddLocationSuggestionEvent({
    required this.name,
    this.address,
    required this.latitude,
    required this.longitude,
    required this.userId,
  });

  @override
  List<Object?> get props => [name, address, latitude, longitude, userId];
}

class VoteForLocationEvent extends LocationVotingEvent {
  final String suggestionId;
  final String userId;

  const VoteForLocationEvent({
    required this.suggestionId,
    required this.userId,
  });

  @override
  List<Object?> get props => [suggestionId, userId];
}

class CheckConsensusEvent extends LocationVotingEvent {
  const CheckConsensusEvent();
}

class FinalizeVotingEvent extends LocationVotingEvent {
  const FinalizeVotingEvent();
}

class CancelVotingEvent extends LocationVotingEvent {
  const CancelVotingEvent();
}

// States
abstract class LocationVotingState extends Equatable {
  const LocationVotingState();

  @override
  List<Object?> get props => [];
}

class LocationVotingInitial extends LocationVotingState {
  const LocationVotingInitial();
}

class VotingSessionActive extends LocationVotingState {
  final VotingSession session;
  final int minutesRemaining;

  const VotingSessionActive({
    required this.session,
    required this.minutesRemaining,
  });

  @override
  List<Object?> get props => [session, minutesRemaining];
}

class SuggestionAdded extends LocationVotingState {
  final VotingSession session;
  final LocationSuggestion newSuggestion;

  const SuggestionAdded({
    required this.session,
    required this.newSuggestion,
  });

  @override
  List<Object?> get props => [session, newSuggestion];
}

class VoteCasted extends LocationVotingState {
  final VotingSession session;
  final String votedSuggestionId;

  const VoteCasted({
    required this.session,
    required this.votedSuggestionId,
  });

  @override
  List<Object?> get props => [session, votedSuggestionId];
}

class ConsensusReached extends LocationVotingState {
  final VotingSession session;
  final LocationSuggestion winningLocation;
  final String reason; // 'majority_votes', 'all_agreed', 'highest_average_distance'

  const ConsensusReached({
    required this.session,
    required this.winningLocation,
    required this.reason,
  });

  @override
  List<Object?> get props => [session, winningLocation, reason];
}

class VotingExpired extends LocationVotingState {
  final VotingSession session;
  final LocationSuggestion? defaultLocation;

  const VotingExpired({
    required this.session,
    this.defaultLocation,
  });

  @override
  List<Object?> get props => [session, defaultLocation];
}

class LocationVotingError extends LocationVotingState {
  final String message;

  const LocationVotingError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class LocationVotingBloc extends Bloc<LocationVotingEvent, LocationVotingState> {
  VotingSession? _currentSession;
  Timer? _expiryTimer;
  Timer? _consensusCheckTimer;

  LocationVotingBloc() : super(const LocationVotingInitial()) {
    on<InitializeVotingSessionEvent>(_onInitializeVotingSession);
    on<AddLocationSuggestionEvent>(_onAddLocationSuggestion);
    on<VoteForLocationEvent>(_onVoteForLocation);
    on<CheckConsensusEvent>(_onCheckConsensus);
    on<FinalizeVotingEvent>(_onFinalizeVoting);
    on<CancelVotingEvent>(_onCancelVoting);
  }

  Future<void> _onInitializeVotingSession(
    InitializeVotingSessionEvent event,
    Emitter<LocationVotingState> emit,
  ) async {
    try {
      _currentSession?.copyWith(status: 'cancelled');
      _expiryTimer?.cancel();
      _consensusCheckTimer?.cancel();

      final votesNeeded = (event.participantIds.length / 2).ceil();
      final expiresAt = event.minyan.createdAt.add(const Duration(minutes: 20));

      // Create initial suggestions
      final initialSuggestions = <LocationSuggestion>[];

      // Add centroid as first suggestion
      if (event.participantIds.length >= 2) {
        // In real app, would use actual participant coordinates
        // For now, create a synthetic centroid suggestion
        final centroidId = 'centroid_${event.minyan.id}';
        initialSuggestions.add(LocationSuggestion(
          id: centroidId,
          name: 'Central Location',
          latitude: event.minyan.latitude,
          longitude: event.minyan.longitude,
          voteCount: 0,
          voterIds: const [],
          suggestedByUserId: 'system',
          suggestedAt: DateTime.now(),
          type: 'centroid',
        ));
      }

      _currentSession = VotingSession(
        id: 'voting_${event.minyan.id}',
        minyanId: event.minyan.id,
        prayerType: event.minyan.prayerType,
        prayerTime: event.minyan.createdAt ?? DateTime.now(),
        participantIds: event.participantIds,
        suggestions: initialSuggestions,
        status: 'active',
        votesNeeded: votesNeeded,
        createdAt: DateTime.now(),
        expiresAt: expiresAt,
      );

      _startExpiryTimer(emit);
      _startConsensusCheckTimer(emit);

      emit(VotingSessionActive(
        session: _currentSession!,
        minutesRemaining: _currentSession!.getMinutesUntilExpiry(),
      ));
    } catch (e) {
      emit(LocationVotingError('Failed to initialize voting: ${e.toString()}'));
    }
  }

  Future<void> _onAddLocationSuggestion(
    AddLocationSuggestionEvent event,
    Emitter<LocationVotingState> emit,
  ) async {
    try {
      if (_currentSession == null) {
        emit(const LocationVotingError('No active voting session'));
        return;
      }

      if (_currentSession!.status != 'active') {
        emit(LocationVotingError('Voting session is ${_currentSession!.status}'));
        return;
      }

      final newSuggestion = LocationSuggestion(
        id: 'suggestion_${DateTime.now().millisecondsSinceEpoch}',
        name: event.name,
        address: event.address,
        latitude: event.latitude,
        longitude: event.longitude,
        voteCount: 0,
        voterIds: const [],
        suggestedByUserId: event.userId,
        suggestedAt: DateTime.now(),
        type: 'user_suggested',
      );

      final updatedSuggestions = [..._currentSession!.suggestions, newSuggestion];
      _currentSession = _currentSession!.copyWith(suggestions: updatedSuggestions);

      emit(SuggestionAdded(
        session: _currentSession!,
        newSuggestion: newSuggestion,
      ));

      emit(VotingSessionActive(
        session: _currentSession!,
        minutesRemaining: _currentSession!.getMinutesUntilExpiry(),
      ));
    } catch (e) {
      emit(LocationVotingError('Failed to add suggestion: ${e.toString()}'));
    }
  }

  Future<void> _onVoteForLocation(
    VoteForLocationEvent event,
    Emitter<LocationVotingState> emit,
  ) async {
    try {
      if (_currentSession == null) {
        emit(const LocationVotingError('No active voting session'));
        return;
      }

      if (_currentSession!.status != 'active') {
        emit(LocationVotingError('Voting session is ${_currentSession!.status}'));
        return;
      }

      // Update the suggestion with new vote
      final updatedSuggestions = _currentSession!.suggestions.map((suggestion) {
        if (suggestion.id == event.suggestionId) {
          // Check if user already voted for this
          if (suggestion.voterIds.contains(event.userId)) {
            return suggestion; // Already voted
          }
          return suggestion.copyWith(
            voteCount: suggestion.voteCount + 1,
            voterIds: [...suggestion.voterIds, event.userId],
          );
        }
        // Remove vote from other suggestions by this user
        if (suggestion.voterIds.contains(event.userId)) {
          return suggestion.copyWith(
            voteCount: suggestion.voteCount - 1,
            voterIds: suggestion.voterIds
                .where((id) => id != event.userId)
                .toList(),
          );
        }
        return suggestion;
      }).toList();

      _currentSession = _currentSession!.copyWith(suggestions: updatedSuggestions);

      emit(VoteCasted(
        session: _currentSession!,
        votedSuggestionId: event.suggestionId,
      ));

      emit(VotingSessionActive(
        session: _currentSession!,
        minutesRemaining: _currentSession!.getMinutesUntilExpiry(),
      ));

      // Check for consensus after vote
      add(const CheckConsensusEvent());
    } catch (e) {
      emit(LocationVotingError('Failed to vote: ${e.toString()}'));
    }
  }

  Future<void> _onCheckConsensus(
    CheckConsensusEvent event,
    Emitter<LocationVotingState> emit,
  ) async {
    try {
      if (_currentSession == null) return;

      if (_currentSession!.hasConsensus()) {
        final winning = _currentSession!.getLeadingSuggestion();
        if (winning != null) {
          _currentSession = _currentSession!.copyWith(
            status: 'consensus_reached',
            consensusLocation: winning,
            winningReason: 'majority_votes',
          );

          _expiryTimer?.cancel();
          _consensusCheckTimer?.cancel();

          emit(ConsensusReached(
            session: _currentSession!,
            winningLocation: winning,
            reason: 'majority_votes',
          ));
        }
      }
    } catch (e) {
      emit(LocationVotingError('Failed to check consensus: ${e.toString()}'));
    }
  }

  Future<void> _onFinalizeVoting(
    FinalizeVotingEvent event,
    Emitter<LocationVotingState> emit,
  ) async {
    try {
      if (_currentSession == null) {
        emit(const LocationVotingError('No active voting session'));
        return;
      }

      _expiryTimer?.cancel();
      _consensusCheckTimer?.cancel();

      if (_currentSession!.hasConsensus()) {
        final winning = _currentSession!.getLeadingSuggestion()!;
        _currentSession = _currentSession!.copyWith(
          status: 'consensus_reached',
          consensusLocation: winning,
        );

        emit(ConsensusReached(
          session: _currentSession!,
          winningLocation: winning,
          reason: 'finalized',
        ));
      } else {
        // Use location with highest average distance or first suggestion
        final winning = _currentSession!.getLeadingSuggestion();
        if (winning != null) {
          _currentSession = _currentSession!.copyWith(
            status: 'consensus_reached',
            consensusLocation: winning,
            winningReason: 'highest_votes',
          );

          emit(ConsensusReached(
            session: _currentSession!,
            winningLocation: winning,
            reason: 'highest_votes',
          ));
        }
      }
    } catch (e) {
      emit(LocationVotingError('Failed to finalize voting: ${e.toString()}'));
    }
  }

  Future<void> _onCancelVoting(
    CancelVotingEvent event,
    Emitter<LocationVotingState> emit,
  ) async {
    _expiryTimer?.cancel();
    _consensusCheckTimer?.cancel();
    _currentSession = null;
    emit(const LocationVotingInitial());
  }

  void _startExpiryTimer(Emitter<LocationVotingState> emit) {
    _expiryTimer?.cancel();
    _expiryTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_currentSession != null && _currentSession!.isExpired()) {
        timer.cancel();
        _consensusCheckTimer?.cancel();

        final defaultLocation = _currentSession!.getLeadingSuggestion();
        _currentSession = _currentSession!.copyWith(status: 'expired');

        emit(VotingExpired(
          session: _currentSession!,
          defaultLocation: defaultLocation,
        ));
      } else if (_currentSession != null) {
        // Update minutes remaining
        emit(VotingSessionActive(
          session: _currentSession!,
          minutesRemaining: _currentSession!.getMinutesUntilExpiry(),
        ));
      }
    });
  }

  void _startConsensusCheckTimer(Emitter<LocationVotingState> emit) {
    _consensusCheckTimer?.cancel();
    _consensusCheckTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (_currentSession != null && _currentSession!.status == 'active') {
        add(const CheckConsensusEvent());
      }
    });
  }

  @override
  Future<void> close() {
    _expiryTimer?.cancel();
    _consensusCheckTimer?.cancel();
    return super.close();
  }
}
