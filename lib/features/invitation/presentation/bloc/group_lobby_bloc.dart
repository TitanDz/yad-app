import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yad_app/features/invitation/domain/entities/group_lobby.dart';
import 'package:yad_app/features/invitation/data/datasources/group_lobby_datasource.dart';

// Events
abstract class GroupLobbyEvent extends Equatable {
  const GroupLobbyEvent();

  @override
  List<Object?> get props => [];
}

class CreateGroupLobbyEvent extends GroupLobbyEvent {
  final GroupLobby lobby;

  const CreateGroupLobbyEvent(this.lobby);

  @override
  List<Object?> get props => [lobby];
}

class LoadGroupLobbyEvent extends GroupLobbyEvent {
  final String lobbyId;

  const LoadGroupLobbyEvent(this.lobbyId);

  @override
  List<Object?> get props => [lobbyId];
}

class LoadUserLobbiesEvent extends GroupLobbyEvent {
  final String userId;

  const LoadUserLobbiesEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class LoadLobbyByMinyanEvent extends GroupLobbyEvent {
  final String minyanId;

  const LoadLobbyByMinyanEvent(this.minyanId);

  @override
  List<Object?> get props => [minyanId];
}

class ParticipantJoinedEvent extends GroupLobbyEvent {
  final String lobbyId;
  final String participantId;
  final String participantName;

  const ParticipantJoinedEvent({
    required this.lobbyId,
    required this.participantId,
    required this.participantName,
  });

  @override
  List<Object?> get props => [lobbyId, participantId, participantName];
}

// States
abstract class GroupLobbyState extends Equatable {
  const GroupLobbyState();

  @override
  List<Object?> get props => [];
}

class GroupLobbyInitial extends GroupLobbyState {}

class GroupLobbyLoading extends GroupLobbyState {}

class GroupLobbyLoaded extends GroupLobbyState {
  final GroupLobby lobby;

  const GroupLobbyLoaded(this.lobby);

  @override
  List<Object?> get props => [lobby];
}

class UserLobbiesLoaded extends GroupLobbyState {
  final List<GroupLobby> lobbies;

  const UserLobbiesLoaded(this.lobbies);

  @override
  List<Object?> get props => [lobbies];
}

class GroupLobbyError extends GroupLobbyState {
  final String message;

  const GroupLobbyError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class GroupLobbyBloc extends Bloc<GroupLobbyEvent, GroupLobbyState> {
  final GroupLobbyDataSource dataSource;

  GroupLobbyBloc({required this.dataSource}) : super(GroupLobbyInitial()) {
    on<CreateGroupLobbyEvent>(_onCreateGroupLobby);
    on<LoadGroupLobbyEvent>(_onLoadGroupLobby);
    on<LoadUserLobbiesEvent>(_onLoadUserLobbies);
    on<LoadLobbyByMinyanEvent>(_onLoadLobbyByMinyan);
    on<ParticipantJoinedEvent>(_onParticipantJoined);
  }

  Future<void> _onCreateGroupLobby(
    CreateGroupLobbyEvent event,
    Emitter<GroupLobbyState> emit,
  ) async {
    try {
      await dataSource.createGroupLobby(event.lobby);
      emit(GroupLobbyLoaded(event.lobby));
    } catch (e) {
      emit(GroupLobbyError('Failed to create group lobby: ${e.toString()}'));
    }
  }

  Future<void> _onLoadGroupLobby(
    LoadGroupLobbyEvent event,
    Emitter<GroupLobbyState> emit,
  ) async {
    try {
      emit(GroupLobbyLoading());
      final lobby = await dataSource.getGroupLobby(event.lobbyId);
      if (lobby != null) {
        emit(GroupLobbyLoaded(lobby));
      } else {
        emit(GroupLobbyError('Lobby not found'));
      }
    } catch (e) {
      emit(GroupLobbyError('Failed to load lobby: ${e.toString()}'));
    }
  }

  Future<void> _onLoadUserLobbies(
    LoadUserLobbiesEvent event,
    Emitter<GroupLobbyState> emit,
  ) async {
    try {
      emit(GroupLobbyLoading());
      final lobbies = await dataSource.getUserLobbies(event.userId);
      emit(UserLobbiesLoaded(lobbies));
    } catch (e) {
      emit(GroupLobbyError('Failed to load user lobbies: ${e.toString()}'));
    }
  }

  Future<void> _onLoadLobbyByMinyan(
    LoadLobbyByMinyanEvent event,
    Emitter<GroupLobbyState> emit,
  ) async {
    try {
      emit(GroupLobbyLoading());
      final lobby = await dataSource.getLobbyByMinyanId(event.minyanId);
      if (lobby != null) {
        emit(GroupLobbyLoaded(lobby));
      } else {
        emit(GroupLobbyError('No lobby found for minyan'));
      }
    } catch (e) {
      emit(GroupLobbyError('Failed to load lobby: ${e.toString()}'));
    }
  }

  Future<void> _onParticipantJoined(
    ParticipantJoinedEvent event,
    Emitter<GroupLobbyState> emit,
  ) async {
    try {
      await dataSource.addParticipantToLobby(
        lobbyId: event.lobbyId,
        participantId: event.participantId,
        participantName: event.participantName,
      );
      
      // Reload the lobby to get the updated state
      final updatedLobby = await dataSource.getGroupLobby(event.lobbyId);
      if (updatedLobby != null) {
        emit(GroupLobbyLoaded(updatedLobby));
        
        // Check if lobby is now ready (has 10 participants)
        if (updatedLobby.hasRequiredParticipants && updatedLobby.status == 'active') {
          print('🎉 [GroupLobby] Lobby ${updatedLobby.lobbyId} is now ready for minyan formation!');
        }
      }
    } catch (e) {
      emit(GroupLobbyError('Failed to add participant: ${e.toString()}'));
    }
  }
}