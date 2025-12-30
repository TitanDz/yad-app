import 'package:flutter/foundation.dart';
import 'package:yad_app/features/invitation/domain/entities/invitation.dart';
import 'package:yad_app/features/invitation/domain/entities/group_lobby.dart';
import 'group_lobby_datasource.dart';

abstract class InvitationDataSource {
  /// Send invitation to nearby users
  Future<void> sendInvitations({
    required String minyanId,
    required String senderId,
    required String senderName,
    required List<String> recipientIds,
    required String minyanDetails,
    required List<String> recipientNames, // NEW: Track recipient names
    required List<double> distances, // NEW: Track distances for each recipient
  });

  /// Get pending invitations for current user (as recipient)
  Future<List<Invitation>> getPendingInvitations(String userId);

  /// Respond to invitation
  Future<void> respondToInvitation({
    required String invitationId,
    required InvitationStatus response,
    required String recipientName, // NEW: Track who responded
    required double distance, // NEW: Track distance
  });

  /// Get sent invitations (for organizer to track responses)
  Future<List<Invitation>> getSentInvitations(String userId);

  /// Get acceptance notifications for sender
  Future<List<InvitationResponse>> getAcceptanceNotifications(String userId);

  /// Get all invitations (for debugging)
  Future<List<Invitation>> getAllInvitations();
}

/// Mock implementation for testing
class MockInvitationDataSource implements InvitationDataSource {
  static final List<Invitation> _invitations = [];
  static final List<InvitationResponse> _acceptanceNotifications = [];
  
  // Add group lobby data source
  final GroupLobbyDataSource _lobbyDataSource;  
  
  MockInvitationDataSource({
    GroupLobbyDataSource? lobbyDataSource,
  }) : _lobbyDataSource = lobbyDataSource ?? MockGroupLobbyDataSource();

  @override
  Future<void> sendInvitations({
    required String minyanId,
    required String senderId,
    required String senderName,
    required List<String> recipientIds,
    required String minyanDetails,
    required List<String> recipientNames,
    required List<double> distances,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Create a group lobby for this minyan invitation
    final lobby = GroupLobby(
      lobbyId: 'lobby_${DateTime.now().millisecondsSinceEpoch}',
      minyanId: minyanId,
      creatorId: senderId,
      participantIds: [senderId], // Start with the creator
      acceptances: [],
      createdAt: DateTime.now(),
      status: 'forming',
    );
    
    await _lobbyDataSource.createGroupLobby(lobby);
    debugPrint('✅ [GroupLobby] Created lobby for minyan $minyanId with creator $senderId');

    for (int i = 0; i < recipientIds.length; i++) {
      final recipientId = recipientIds[i];
      final recipientName = recipientNames.length > i ? recipientNames[i] : 'Unknown User';
      final distance = distances.length > i ? distances[i] : 0.5;

      final invitation = Invitation(
        invitationId: 'inv_${DateTime.now().millisecondsSinceEpoch}_${recipientId.hashCode}',
        minyanId: minyanId,
        senderId: senderId,
        senderName: senderName,
        recipientId: recipientId,
        recipientName: recipientName,
        sentAt: DateTime.now(),
        status: InvitationStatus.pending,
        minyanDetails: minyanDetails,
        distanceKm: distance,
      );

      _invitations.add(invitation);
      debugPrint('✅ [Invitation] Sent to $recipientName ($recipientId): ${invitation.invitationId} (Distance: ${distance.toStringAsFixed(1)}km), senderId: ${invitation.senderId}');
    }
  }

  @override
  Future<List<Invitation>> getPendingInvitations(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final pending = _invitations
        .where((inv) =>
            inv.recipientId == userId && inv.status == InvitationStatus.pending)
        .toList();

    debugPrint('📬 [Invitation] Found ${pending.length} pending invitations for $userId');
    for (final inv in pending) {
      debugPrint('   From: ${inv.senderName} (${inv.distanceKm.toStringAsFixed(1)}km away)');
    }
    return pending;
  }

  @override
  Future<void> respondToInvitation({
    required String invitationId,
    required InvitationStatus response,
    required String recipientName,
    required double distance,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    debugPrint('🔔 [Invitation] respondToInvitation called for invitationId: $invitationId');
    debugPrint('🔔 [Invitation] Current _invitations count: ${_invitations.length}');
    
    final index = _invitations.indexWhere((inv) => inv.invitationId == invitationId);
    
    if (index != -1) {
      final old = _invitations[index];
      debugPrint('🔔 [Invitation] Found invitation to respond to: senderId=${old.senderId}, senderName=${old.senderName}, recipientId=${old.recipientId}, recipientName=${old.recipientName}');
      
      _invitations[index] = old.copyWith(
        status: response,
        respondedAt: DateTime.now(),
      );

      // Create notification for sender
      if (response == InvitationStatus.accepted) {
        debugPrint('✅ [Invitation] Creating acceptance notification: senderId=${old.senderId}, oldSenderId=${old.senderId}, oldSenderName=${old.senderName}, oldRecipientId=${old.recipientId}');
        
        final notification = InvitationResponse(
          senderId: old.senderId, // The user who sent the original invitation
          recipientId: old.recipientId, // The user who accepted (was the original recipient)
          recipientName: recipientName,
          response: response,
          respondedAt: DateTime.now(),
          distanceKm: distance,
        );
        _acceptanceNotifications.add(notification);
        
        debugPrint(
          '✅ [Invitation] $recipientName ACCEPTED invitation from ${old.senderName} (Distance: ${distance.toStringAsFixed(1)}km)',
        );
        debugPrint(
          '✅ [Invitation] Created notification: senderId=${notification.senderId}, recipient=${notification.recipientId}, stored in list (total now: ${_acceptanceNotifications.length})',
        );
        
        // Add the accepting participant to the corresponding group lobby
        try {
          final lobby = await _lobbyDataSource.getLobbyByMinyanId(old.minyanId);
          if (lobby != null) {
            await _lobbyDataSource.addParticipantToLobby(
              lobbyId: lobby.lobbyId,
              participantId: old.recipientId,
              participantName: recipientName,
            );
            debugPrint('✅ [GroupLobby] Added participant ${old.recipientId} to lobby ${lobby.lobbyId} for minyan ${old.minyanId}');
          }
        } catch (e) {
          debugPrint('❌ [GroupLobby] Error adding participant to lobby: $e');
        }
      } else {
        debugPrint(
          '❌ [Invitation] $recipientName DECLINED invitation from ${old.senderName}',
        );
      }
    } else {
      debugPrint('❌ [Invitation] Invitation with ID $invitationId not found!');
      debugPrint('🔔 [Invitation] Available invitation IDs:');
      for (final inv in _invitations) {
        debugPrint('   - ${inv.invitationId} (sender: ${inv.senderId}, recipient: ${inv.recipientId})');
      }
    }
  }

  @override
  Future<List<Invitation>> getSentInvitations(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final sent = _invitations
        .where((inv) => inv.senderId == userId)
        .toList();

    debugPrint('📤 [Invitation] Found ${sent.length} sent invitations from $userId');
    return sent;
  }

  @override
  Future<List<InvitationResponse>> getAcceptanceNotifications(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    debugPrint('🔔 [Invitation] Looking for acceptance notifications for user $userId');
    debugPrint('🔔 [Invitation] Total _acceptanceNotifications: ${_acceptanceNotifications.length}');
    
    // Log all existing notifications for debugging
    for (int i = 0; i < _acceptanceNotifications.length; i++) {
      final notification = _acceptanceNotifications[i];
      debugPrint('🔔 [Invitation] Notification $i: senderId=${notification.senderId}, recipientId=${notification.recipientId}, name=${notification.recipientName}');
    }
    
    // Get all acceptance notifications where the sender is the current user
    final acceptances = _acceptanceNotifications
        .where((notification) => notification.senderId == userId)
        .toList();
    
    debugPrint('🔔 [Invitation] Found ${acceptances.length} acceptance notifications for user $userId');
    
    for (final acc in acceptances) {
      debugPrint('   ${acc.recipientName} accepted your invitation (${acc.distanceKm.toStringAsFixed(1)}km away)');
    }
    return acceptances;
  }

  @override
  Future<List<Invitation>> getAllInvitations() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _invitations;
  }

  /// Clear all invitations (useful for testing)
  static void clearAllInvitations() {
    _invitations.clear();
    _acceptanceNotifications.clear();
    debugPrint('🗑️ [Invitation] All invitations and notifications cleared');
  }

  /// Get invitation by ID (for debugging)
  static Invitation? getInvitationById(String id) {
    try {
      return _invitations.firstWhere((inv) => inv.invitationId == id);
    } catch (e) {
      return null;
    }
  }
}
