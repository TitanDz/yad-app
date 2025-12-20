import 'package:equatable/equatable.dart';

enum InvitationStatus { pending, accepted, declined, expired }

class Invitation extends Equatable {
  final String invitationId;
  final String minyanId;
  final String senderId;
  final String senderName;
  final String recipientId;
  final DateTime sentAt;
  final DateTime? respondedAt;
  final InvitationStatus status;
  final String minyanDetails;
  final double distanceKm;

  const Invitation({
    required this.invitationId,
    required this.minyanId,
    required this.senderId,
    required this.senderName,
    required this.recipientId,
    required this.sentAt,
    this.respondedAt,
    required this.status,
    required this.minyanDetails,
    required this.distanceKm,
  });

  @override
  List<Object?> get props => [
    invitationId,
    minyanId,
    senderId,
    senderName,
    recipientId,
    sentAt,
    respondedAt,
    status,
    minyanDetails,
    distanceKm,
  ];

  Invitation copyWith({
    String? invitationId,
    String? minyanId,
    String? senderId,
    String? senderName,
    String? recipientId,
    DateTime? sentAt,
    DateTime? respondedAt,
    InvitationStatus? status,
    String? minyanDetails,
    double? distanceKm,
  }) {
    return Invitation(
      invitationId: invitationId ?? this.invitationId,
      minyanId: minyanId ?? this.minyanId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      recipientId: recipientId ?? this.recipientId,
      sentAt: sentAt ?? this.sentAt,
      respondedAt: respondedAt ?? this.respondedAt,
      status: status ?? this.status,
      minyanDetails: minyanDetails ?? this.minyanDetails,
      distanceKm: distanceKm ?? this.distanceKm,
    );
  }
}
