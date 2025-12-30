import 'package:equatable/equatable.dart';

enum InvitationStatus { pending, accepted, declined, expired }

class InvitationResponse extends Equatable {
  final String senderId; // The user who sent the original invitation
  final String recipientId;
  final String recipientName;
  final InvitationStatus response;
  final DateTime respondedAt;
  final double distanceKm;

  const InvitationResponse({
    required this.senderId,
    required this.recipientId,
    required this.recipientName,
    required this.response,
    required this.respondedAt,
    required this.distanceKm,
  });

  @override
  List<Object?> get props => [senderId, recipientId, recipientName, response, respondedAt, distanceKm];
}

class Invitation extends Equatable {
  final String invitationId;
  final String minyanId;
  final String senderId;
  final String senderName;
  final String recipientId;
  final String? recipientName; // NEW: Track recipient name
  final DateTime sentAt;
  final DateTime? respondedAt;
  final InvitationStatus status;
  final String minyanDetails;
  final double distanceKm;
  final List<InvitationResponse> responses; // NEW: Track all responses

  const Invitation({
    required this.invitationId,
    required this.minyanId,
    required this.senderId,
    required this.senderName,
    required this.recipientId,
    this.recipientName,
    required this.sentAt,
    this.respondedAt,
    required this.status,
    required this.minyanDetails,
    required this.distanceKm,
    this.responses = const [],
  });

  @override
  List<Object?> get props => [
    invitationId,
    minyanId,
    senderId,
    senderName,
    recipientId,
    recipientName,
    sentAt,
    respondedAt,
    status,
    minyanDetails,
    distanceKm,
    responses,
  ];

  Invitation copyWith({
    String? invitationId,
    String? minyanId,
    String? senderId,
    String? senderName,
    String? recipientId,
    String? recipientName,
    DateTime? sentAt,
    DateTime? respondedAt,
    InvitationStatus? status,
    String? minyanDetails,
    double? distanceKm,
    List<InvitationResponse>? responses,
  }) {
    return Invitation(
      invitationId: invitationId ?? this.invitationId,
      minyanId: minyanId ?? this.minyanId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      recipientId: recipientId ?? this.recipientId,
      recipientName: recipientName ?? this.recipientName,
      sentAt: sentAt ?? this.sentAt,
      respondedAt: respondedAt ?? this.respondedAt,
      status: status ?? this.status,
      minyanDetails: minyanDetails ?? this.minyanDetails,
      distanceKm: distanceKm ?? this.distanceKm,
      responses: responses ?? this.responses,
    );
  }
}
