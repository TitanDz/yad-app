/// User preferences model for storing auto-detected settings
class UserPreferences {
  final String userId;
  final String? timeZone;
  final double? latitude;
  final double? longitude;
  final String? address;
  final String visibility;
  final int searchRadiusMiles;
  final String? homeZone;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isUnavailable;
  final DateTime? unavailableUntil;

  UserPreferences({
    required this.userId,
    this.timeZone,
    this.latitude,
    this.longitude,
    this.address,
    this.visibility = 'Active',
    this.searchRadiusMiles = 10,
    this.homeZone,
    this.createdAt,
    this.updatedAt,
    this.isUnavailable = false,
    this.unavailableUntil,
  });

  /// Returns the timezone string formatted for display
  String get timeZoneDisplay => timeZone ?? 'Not Set';

  /// Returns whether location is available
  bool get hasLocation => latitude != null && longitude != null;

  /// Returns whether user is currently unavailable
  bool get isCurrentlyUnavailable {
    if (!isUnavailable) return false;
    if (unavailableUntil == null) return false;
    return DateTime.now().isBefore(unavailableUntil!);
  }

  /// Creates a copy of this object with optional replaced fields
  UserPreferences copyWith({
    String? userId,
    String? timeZone,
    double? latitude,
    double? longitude,
    String? address,
    String? visibility,
    int? searchRadiusMiles,
    String? homeZone,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isUnavailable,
    DateTime? unavailableUntil,
  }) {
    return UserPreferences(
      userId: userId ?? this.userId,
      timeZone: timeZone ?? this.timeZone,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      visibility: visibility ?? this.visibility,
      searchRadiusMiles: searchRadiusMiles ?? this.searchRadiusMiles,
      homeZone: homeZone ?? this.homeZone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isUnavailable: isUnavailable ?? this.isUnavailable,
      unavailableUntil: unavailableUntil ?? this.unavailableUntil,
    );
  }

  /// Convert to JSON for API calls
  Map<String, dynamic> toJson() => {
    'userId': userId,
    'timeZone': timeZone,
    'latitude': latitude,
    'longitude': longitude,
    'address': address,
    'visibility': visibility,
    'searchRadiusMiles': searchRadiusMiles,
    'homeZone': homeZone,
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    'isUnavailable': isUnavailable,
    'unavailableUntil': unavailableUntil?.toIso8601String(),
  };

  /// Create from JSON
  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      userId: json['userId'] as String? ?? '',
      timeZone: json['timeZone'] as String?,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      address: json['address'] as String?,
      visibility: json['visibility'] as String? ?? 'Active',
      searchRadiusMiles: json['searchRadiusMiles'] as int? ?? 10,
      homeZone: json['homeZone'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      isUnavailable: json['isUnavailable'] as bool? ?? false,
      unavailableUntil: json['unavailableUntil'] != null
          ? DateTime.parse(json['unavailableUntil'] as String)
          : null,
    );
  }
}
