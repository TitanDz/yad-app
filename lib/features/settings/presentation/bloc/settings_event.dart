import 'package:equatable/equatable.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class GetSettingsEvent extends SettingsEvent {
  const GetSettingsEvent();
}

class SaveSettingsEvent extends SettingsEvent {
  final String language;
  final String timeZone;
  final String visibility;
  final int searchRadius;
  final String homeZone;

  const SaveSettingsEvent({
    required this.language,
    required this.timeZone,
    required this.visibility,
    required this.searchRadius,
    required this.homeZone,
  });

  @override
  List<Object?> get props => [language, timeZone, visibility, searchRadius, homeZone];
}
