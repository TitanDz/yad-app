import 'package:equatable/equatable.dart';

class SettingsModel extends Equatable {
  final String language;
  final String timeZone;
  final String visibility;
  final int searchRadius;
  final String homeZone;

  const SettingsModel({
    required this.language,
    required this.timeZone,
    required this.visibility,
    required this.searchRadius,
    required this.homeZone,
  });

  // Default settings
  factory SettingsModel.defaultSettings() {
    return const SettingsModel(
      language: 'English',
      timeZone: 'America/New_York',
      visibility: 'Active',
      searchRadius: 10,
      homeZone: '',
    );
  }

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      language: json['language'] as String? ?? 'English',
      timeZone: json['timeZone'] as String? ?? 'America/New_York',
      visibility: json['visibility'] as String? ?? 'Active',
      searchRadius: json['searchRadius'] as int? ?? 10,
      homeZone: json['homeZone'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'language': language,
      'timeZone': timeZone,
      'visibility': visibility,
      'searchRadius': searchRadius,
      'homeZone': homeZone,
    };
  }

  SettingsModel copyWith({
    String? language,
    String? timeZone,
    String? visibility,
    int? searchRadius,
    String? homeZone,
  }) {
    return SettingsModel(
      language: language ?? this.language,
      timeZone: timeZone ?? this.timeZone,
      visibility: visibility ?? this.visibility,
      searchRadius: searchRadius ?? this.searchRadius,
      homeZone: homeZone ?? this.homeZone,
    );
  }

  @override
  List<Object?> get props => [language, timeZone, visibility, searchRadius, homeZone];
}
