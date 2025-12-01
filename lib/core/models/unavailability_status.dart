/// Represents user unavailability status for 30-minute feature
class UnavailabilityStatus {
  final String userId;
  final bool isUnavailable;
  final DateTime? unavailableUntil;
  final String reason;
  final DateTime createdAt;
  final DateTime updatedAt;

  UnavailabilityStatus({
    required this.userId,
    this.isUnavailable = false,
    this.unavailableUntil,
    this.reason = 'Do not disturb',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Check if currently unavailable (considering expiration)
  bool get isCurrentlyUnavailable {
    if (!isUnavailable) return false;
    if (unavailableUntil == null) return false;
    return DateTime.now().isBefore(unavailableUntil!);
  }

  /// Get remaining unavailability duration
  Duration? get remainingDuration {
    if (!isCurrentlyUnavailable || unavailableUntil == null) return null;
    final remaining = unavailableUntil!.difference(DateTime.now());
    return remaining.isNegative ? null : remaining;
  }

  /// Get remaining minutes as integer
  int? get remainingMinutes {
    final duration = remainingDuration;
    if (duration == null) return null;
    return duration.inMinutes;
  }

  /// Create unavailability for 30 minutes from now
  factory UnavailabilityStatus.thirtyMinutes({
    required String userId,
    String reason = 'Do not disturb',
  }) {
    final now = DateTime.now();
    return UnavailabilityStatus(
      userId: userId,
      isUnavailable: true,
      unavailableUntil: now.add(const Duration(minutes: 30)),
      reason: reason,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Create available status
  factory UnavailabilityStatus.available({required String userId}) {
    return UnavailabilityStatus(
      userId: userId,
      isUnavailable: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Copy with optional field replacement
  UnavailabilityStatus copyWith({
    String? userId,
    bool? isUnavailable,
    DateTime? unavailableUntil,
    String? reason,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UnavailabilityStatus(
      userId: userId ?? this.userId,
      isUnavailable: isUnavailable ?? this.isUnavailable,
      unavailableUntil: unavailableUntil ?? this.unavailableUntil,
      reason: reason ?? this.reason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
    'userId': userId,
    'isUnavailable': isUnavailable,
    'unavailableUntil': unavailableUntil?.toIso8601String(),
    'reason': reason,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  /// Create from JSON
  factory UnavailabilityStatus.fromJson(Map<String, dynamic> json) {
    return UnavailabilityStatus(
      userId: json['userId'] as String? ?? '',
      isUnavailable: json['isUnavailable'] as bool? ?? false,
      unavailableUntil: json['unavailableUntil'] != null
          ? DateTime.parse(json['unavailableUntil'] as String)
          : null,
      reason: json['reason'] as String? ?? 'Do not disturb',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }
}
