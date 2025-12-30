import 'package:yad_app/features/invitation/domain/entities/group_lobby.dart';

abstract class GroupLobbyDataSource {
  /// Create a new group lobby when invitations are sent
  Future<void> createGroupLobby(GroupLobby lobby);

  /// Get an existing group lobby by ID
  Future<GroupLobby?> getGroupLobby(String lobbyId);

  /// Update a group lobby (when acceptances are received)
  Future<void> updateGroupLobby(GroupLobby lobby);

  /// Add a participant to a lobby when their invitation is accepted
  Future<void> addParticipantToLobby({
    required String lobbyId,
    required String participantId,
    required String participantName,
  });

  /// Check if a lobby exists for a specific minyan
  Future<GroupLobby?> getLobbyByMinyanId(String minyanId);

  /// Get all lobbies for a specific user (as creator or participant)
  Future<List<GroupLobby>> getUserLobbies(String userId);
}

/// Mock implementation for testing
class MockGroupLobbyDataSource implements GroupLobbyDataSource {
  static final Map<String, GroupLobby> _lobbies = {};

  @override
  Future<void> createGroupLobby(GroupLobby lobby) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _lobbies[lobby.lobbyId] = lobby;
    print('✅ [GroupLobby] Created lobby: ${lobby.lobbyId} for minyan: ${lobby.minyanId}');
  }

  @override
  Future<GroupLobby?> getGroupLobby(String lobbyId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final lobby = _lobbies[lobbyId];
    print('🔍 [GroupLobby] Retrieved lobby: ${lobby?.lobbyId} with ${lobby?.participantIds.length ?? 0} participants');
    return lobby;
  }

  @override
  Future<void> updateGroupLobby(GroupLobby lobby) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _lobbies[lobby.lobbyId] = lobby;
    print('🔄 [GroupLobby] Updated lobby: ${lobby.lobbyId}, participants: ${lobby.participantIds.length}, isReady: ${lobby.isReady}');
  }

  @override
  Future<void> addParticipantToLobby({
    required String lobbyId,
    required String participantId,
    required String participantName,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final lobby = _lobbies[lobbyId];
    if (lobby != null) {
      final updatedParticipants = Set<String>.from(lobby.participantIds)..add(participantId);
      final updatedLobby = lobby.copyWith(
        participantIds: updatedParticipants.toList(),
        isReady: updatedParticipants.length >= 2,
        activatedAt: updatedParticipants.length >= 2 ? DateTime.now() : lobby.activatedAt,
        status: updatedParticipants.length >= 2 ? 'active' : 'forming',
      );
      _lobbies[lobbyId] = updatedLobby;
      print('👥 [GroupLobby] Added participant $participantId to lobby ${lobbyId}, total: ${updatedParticipants.length}, ready: ${updatedParticipants.length >= 2}');
    }
  }

  @override
  Future<GroupLobby?> getLobbyByMinyanId(String minyanId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    for (final lobby in _lobbies.values) {
      if (lobby.minyanId == minyanId) {
        print('🔍 [GroupLobby] Found lobby for minyan $minyanId: ${lobby.lobbyId}');
        return lobby;
      }
    }
    print('🔍 [GroupLobby] No lobby found for minyan $minyanId');
    return null;
  }

  @override
  Future<List<GroupLobby>> getUserLobbies(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final userLobbies = _lobbies.values
        .where((lobby) => lobby.creatorId == userId || lobby.participantIds.contains(userId))
        .toList();
    print('👥 [GroupLobby] Found ${userLobbies.length} lobbies for user $userId');
    return userLobbies;
  }
}