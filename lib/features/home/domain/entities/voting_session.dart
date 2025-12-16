import 'package:equatable/equatable.dart';
import 'location_suggestion.dart';

/// Represents a voting session for a minyan's location
class VotingSession extends Equatable {
  final String id;
  final String minyanId;
  final String prayerType;
  final DateTime prayerTime;
  final List<String> participantIds; // All users who confirmed for the minyan
  final List<LocationSuggestion> suggestions;
  final String status; // 'active', 'consensus_reached', 'expired'
  final LocationSuggestion? consensusLocation; // Winning location
  final int votesNeeded; // Ceil(participantIds.length * 0.5)
  final DateTime createdAt;
  final DateTime? expiresAt; // Expires 20 mins before prayer time
  final String? winningReason; // 'majority_votes', 'all_agreed', 'highest_average_distance'

  const VotingSession({
    required this.id,
    required this.minyanId,
    required this.prayerType,
    required this.prayerTime,
    required this.participantIds,
    required this.suggestions,
    required this.status,
    this.consensusLocation,
    required this.votesNeeded,
    required this.createdAt,
    this.expiresAt,
    this.winningReason,
  });

  VotingSession copyWith({
    String? id,
    String? minyanId,
    String? prayerType,
    DateTime? prayerTime,
    List<String>? participantIds,
    List<LocationSuggestion>? suggestions,
    String? status,
    LocationSuggestion? consensusLocation,
    int? votesNeeded,
    DateTime? createdAt,
    DateTime? expiresAt,
    String? winningReason,
  }) {
    return VotingSession(
      id: id ?? this.id,
      minyanId: minyanId ?? this.minyanId,
      prayerType: prayerType ?? this.prayerType,
      prayerTime: prayerTime ?? this.prayerTime,
      participantIds: participantIds ?? this.participantIds,
      suggestions: suggestions ?? this.suggestions,
      status: status ?? this.status,
      consensusLocation: consensusLocation ?? this.consensusLocation,
      votesNeeded: votesNeeded ?? this.votesNeeded,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      winningReason: winningReason ?? this.winningReason,
    );
  }

  /// Get the leading suggestion by vote count
  LocationSuggestion? getLeadingSuggestion() {
    if (suggestions.isEmpty) return null;
    suggestions.sort((a, b) => b.voteCount.compareTo(a.voteCount));
    return suggestions.first;
  }

  /// Check if a location has consensus (majority of participants voted for it)
  bool hasConsensus() {
    final leading = getLeadingSuggestion();
    return leading != null && leading.voteCount >= votesNeeded;
  }

  /// Check if voting session has expired
  bool isExpired() {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Get minutes until voting expires
  int getMinutesUntilExpiry() {
    if (expiresAt == null) return 0;
    final now = DateTime.now();
    if (now.isAfter(expiresAt!)) return 0;
    return expiresAt!.difference(now).inMinutes;
  }

  @override
  List<Object?> get props => [
    id,
    minyanId,
    prayerType,
    prayerTime,
    participantIds,
    suggestions,
    status,
    consensusLocation,
    votesNeeded,
    createdAt,
    expiresAt,
    winningReason,
  ];
}
