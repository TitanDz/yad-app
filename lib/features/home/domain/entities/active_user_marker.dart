/// Represents an active user for display on the map
class ActiveUserMarker {
  final String userId;
  final String name;
  final double latitude;
  final double longitude;
  final String address;
  final bool isAvailable;
  final int minutesUnavailable; // 0 if available
  final String? avatarUrl;
  final DateTime lastSeen;
  final double? distance; // in miles
  final String? lastPrayerType; // What they were looking for

  ActiveUserMarker({
    required this.userId,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.isAvailable,
    this.minutesUnavailable = 0,
    this.avatarUrl,
    DateTime? lastSeen,
    this.distance,
    this.lastPrayerType,
  }) : lastSeen = lastSeen ?? DateTime.now();

  /// Get marker label (name or "Praying for Mincha")
  String get markerLabel => lastPrayerType ?? name;

  /// Check if user is recent (seen in last 15 minutes)
  bool get isRecent {
    return DateTime.now().difference(lastSeen).inMinutes < 15;
  }

  /// Copy with optional field replacement
  ActiveUserMarker copyWith({
    String? userId,
    String? name,
    double? latitude,
    double? longitude,
    String? address,
    bool? isAvailable,
    int? minutesUnavailable,
    String? avatarUrl,
    DateTime? lastSeen,
    double? distance,
    String? lastPrayerType,
  }) {
    return ActiveUserMarker(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      isAvailable: isAvailable ?? this.isAvailable,
      minutesUnavailable: minutesUnavailable ?? this.minutesUnavailable,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      lastSeen: lastSeen ?? this.lastSeen,
      distance: distance ?? this.distance,
      lastPrayerType: lastPrayerType ?? this.lastPrayerType,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
    'userId': userId,
    'name': name,
    'latitude': latitude,
    'longitude': longitude,
    'address': address,
    'isAvailable': isAvailable,
    'minutesUnavailable': minutesUnavailable,
    'avatarUrl': avatarUrl,
    'lastSeen': lastSeen.toIso8601String(),
    'distance': distance,
    'lastPrayerType': lastPrayerType,
  };

  /// Create from JSON
  factory ActiveUserMarker.fromJson(Map<String, dynamic> json) {
    return ActiveUserMarker(
      userId: json['userId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      address: json['address'] as String? ?? '',
      isAvailable: json['isAvailable'] as bool? ?? true,
      minutesUnavailable: json['minutesUnavailable'] as int? ?? 0,
      avatarUrl: json['avatarUrl'] as String?,
      lastSeen: json['lastSeen'] != null
          ? DateTime.parse(json['lastSeen'] as String)
          : null,
      distance: (json['distance'] as num?)?.toDouble(),
      lastPrayerType: json['lastPrayerType'] as String?,
    );
  }
}
