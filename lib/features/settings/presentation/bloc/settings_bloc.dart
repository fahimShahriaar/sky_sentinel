import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/repositories/settings_repository.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository repository;

  SettingsBloc({required this.repository}) : super(const SettingsInitial()) {
    on<LoadSettings>(_onLoadSettings);
    on<UpdateTemperatureThreshold>(_onUpdateTemperatureThreshold);
    on<ToggleRainAlert>(_onToggleRainAlert);
  }

  void _onLoadSettings(LoadSettings event, Emitter<SettingsState> emit) {
    final settings = repository.getSettings();
    appLogger.i('Settings loaded: $settings');
    emit(SettingsLoaded(settings: settings));
  }

  Future<void> _onUpdateTemperatureThreshold(UpdateTemperatureThreshold event, Emitter<SettingsState> emit) async {
    await repository.saveTemperatureThreshold(event.threshold);
    final settings = repository.getSettings();
    emit(SettingsLoaded(settings: settings));
  }

  Future<void> _onToggleRainAlert(ToggleRainAlert event, Emitter<SettingsState> emit) async {
    await repository.saveRainAlertEnabled(event.enabled);
    final settings = repository.getSettings();
    emit(SettingsLoaded(settings: settings));
  }
}
