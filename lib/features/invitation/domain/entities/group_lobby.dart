import 'package:equatable/equatable.dart';
import 'package:yad_app/features/invitation/domain/entities/invitation.dart';

class GroupLobby extends Equatable {
  final String lobbyId;
  final String minyanId;
  final String creatorId; // The user who sent the original invitations
  final List<String> participantIds; // All accepted participants including the creator
  final List<InvitationResponse> acceptances; // The acceptance responses
  final DateTime createdAt;
  final DateTime? activatedAt; // When the 10th acceptance was received
  final bool isReady; // Whether the lobby has reached 10 participants
  final String status; // 'forming', 'active', 'completed', etc.

  const GroupLobby({
    required this.lobbyId,
    required this.minyanId,
    required this.creatorId,
    required this.participantIds,
    required this.acceptances,
    required this.createdAt,
    this.activatedAt,
    this.isReady = false,
    this.status = 'forming',
  });

  @override
  List<Object?> get props => [
    lobbyId,
    minyanId,
    creatorId,
    participantIds,
    acceptances,
    createdAt,
    activatedAt,
    isReady,
    status,
  ];

  GroupLobby copyWith({
    String? lobbyId,
    String? minyanId,
    String? creatorId,
    List<String>? participantIds,
    List<InvitationResponse>? acceptances,
    DateTime? createdAt,
    DateTime? activatedAt,
    bool? isReady,
    String? status,
  }) {
    return GroupLobby(
      lobbyId: lobbyId ?? this.lobbyId,
      minyanId: minyanId ?? this.minyanId,
      creatorId: creatorId ?? this.creatorId,
      participantIds: participantIds ?? this.participantIds,
      acceptances: acceptances ?? this.acceptances,
      createdAt: createdAt ?? this.createdAt,
      activatedAt: activatedAt ?? this.activatedAt,
      isReady: isReady ?? this.isReady,
      status: status ?? this.status,
    );
  }

  // Check if lobby has reached required number of participants (temporarily changed to 2 for testing)
  bool get hasRequiredParticipants => participantIds.length >= 2;

  // Get the number of participants needed to reach threshold
  int get participantsNeeded => hasRequiredParticipants ? 0 : 2 - participantIds.length;
}