import 'package:equatable/equatable.dart';

class Minyan extends Equatable {
  final String id;
  final String userId;
  final String prayerType; // Shacharit, Mincha, Maariv
  final String date; // YYYY-MM-DD
  final String time; // HH:MM
  final String locationName;
  final double latitude;
  final double longitude;
  final String notes;
  final String status; // draft, published, cancelled
  final int participantCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double? distance; // Only for nearby minyans
  final bool isCreatedByUser;

  const Minyan({
    required this.id,
    required this.userId,
    required this.prayerType,
    required this.date,
    required this.time,
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.notes,
    required this.status,
    required this.participantCount,
    required this.createdAt,
    required this.updatedAt,
    this.distance,
    this.isCreatedByUser = false,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        prayerType,
        date,
        time,
        locationName,
        latitude,
        longitude,
        notes,
        status,
        participantCount,
        createdAt,
        updatedAt,
        distance,
        isCreatedByUser,
      ];
}
