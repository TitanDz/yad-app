import 'package:equatable/equatable.dart';

/// Represents a suggested location for a minyan
class LocationSuggestion extends Equatable {
  final String id;
  final String name;
  final String? address;
  final double latitude;
  final double longitude;
  final int voteCount;
  final List<String> voterIds;
  final String suggestedByUserId;
  final DateTime suggestedAt;
  final String type; // 'user_suggested', 'centroid', 'synagogue'
  final double? averageDistance; // Average distance from all participants

  const LocationSuggestion({
    required this.id,
    required this.name,
    this.address,
    required this.latitude,
    required this.longitude,
    required this.voteCount,
    required this.voterIds,
    required this.suggestedByUserId,
    required this.suggestedAt,
    required this.type,
    this.averageDistance,
  });

  LocationSuggestion copyWith({
    String? id,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    int? voteCount,
    List<String>? voterIds,
    String? suggestedByUserId,
    DateTime? suggestedAt,
    String? type,
    double? averageDistance,
  }) {
    return LocationSuggestion(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      voteCount: voteCount ?? this.voteCount,
      voterIds: voterIds ?? this.voterIds,
      suggestedByUserId: suggestedByUserId ?? this.suggestedByUserId,
      suggestedAt: suggestedAt ?? this.suggestedAt,
      type: type ?? this.type,
      averageDistance: averageDistance ?? this.averageDistance,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    address,
    latitude,
    longitude,
    voteCount,
    voterIds,
    suggestedByUserId,
    suggestedAt,
    type,
    averageDistance,
  ];
}
