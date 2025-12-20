import 'package:flutter/foundation.dart';
import 'package:yad_app/features/invitation/domain/entities/invitation.dart';

abstract class InvitationDataSource {
  /// Send invitation to nearby users
  Future<void> sendInvitations({
    required String minyanId,
    required String senderId,
    required String senderName,
    required List<String> recipientIds,
    required String minyanDetails,
  });

  /// Get pending invitations for current user
  Future<List<Invitation>> getPendingInvitations(String userId);

  /// Respond to invitation
  Future<void> respondToInvitation({
    required String invitationId,
    required InvitationStatus response,
  });

  /// Get sent invitations (for organizer to track responses)
  Future<List<Invitation>> getSentInvitations(String userId);

  /// Get all invitations (for debugging)
  Future<List<Invitation>> getAllInvitations();
}

/// Mock implementation for testing
class MockInvitationDataSource implements InvitationDataSource {
  static final List<Invitation> _invitations = [];

  @override
  Future<void> sendInvitations({
    required String minyanId,
    required String senderId,
    required String senderName,
    required List<String> recipientIds,
    required String minyanDetails,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    for (final recipientId in recipientIds) {
      final invitation = Invitation(
        invitationId: 'inv_${DateTime.now().millisecondsSinceEpoch}_${recipientId.hashCode}',
        minyanId: minyanId,
        senderId: senderId,
        senderName: senderName,
        recipientId: recipientId,
        sentAt: DateTime.now(),
        status: InvitationStatus.pending,
        minyanDetails: minyanDetails,
        distanceKm: 0.5,
      );

      _invitations.add(invitation);
      debugPrint('✅ [Invitation] Sent to $recipientId: ${invitation.invitationId}');
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
    return pending;
  }

  @override
  Future<void> respondToInvitation({
    required String invitationId,
    required InvitationStatus response,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _invitations.indexWhere((inv) => inv.invitationId == invitationId);
    if (index != -1) {
      final old = _invitations[index];
      _invitations[index] = old.copyWith(
        status: response,
        respondedAt: DateTime.now(),
      );

      debugPrint(
        '✅ [Invitation] Response recorded: ${response.toString().split('.').last.toUpperCase()}',
      );
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
  Future<List<Invitation>> getAllInvitations() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _invitations;
  }

  /// Clear all invitations (useful for testing)
  static void clearAllInvitations() {
    _invitations.clear();
    debugPrint('🗑️ [Invitation] All invitations cleared');
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
