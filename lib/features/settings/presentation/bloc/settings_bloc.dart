import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yad_app/features/settings/data/datasources/settings_datasource.dart';
import 'package:yad_app/features/settings/domain/models/settings_model.dart';
import 'package:yad_app/features/settings/presentation/bloc/settings_event.dart';
import 'package:yad_app/features/settings/presentation/bloc/settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsDataSource settingsDataSource;

  SettingsBloc({required this.settingsDataSource}) : super(const SettingsInitial()) {
    on<GetSettingsEvent>(_onGetSettings);
    on<SaveSettingsEvent>(_onSaveSettings);
  }

  Future<void> _onGetSettings(
    GetSettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsLoading());
    try {
      final settings = await settingsDataSource.getSettings();
      emit(SettingsLoaded(settings));
    } catch (e) {
      emit(SettingsFailure(e.toString()));
    }
  }

  Future<void> _onSaveSettings(
    SaveSettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsLoading());
    try {
      final settings = SettingsModel(
        language: event.language,
        timeZone: event.timeZone,
        visibility: event.visibility,
        searchRadius: event.searchRadius,
        homeZone: event.homeZone,
      );
      await settingsDataSource.saveSettings(settings);
      emit(SettingsSaved(settings));
    } catch (e) {
      emit(SettingsFailure(e.toString()));
    }
  }
}
