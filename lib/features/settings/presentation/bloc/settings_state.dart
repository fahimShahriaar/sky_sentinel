import 'package:equatable/equatable.dart';
import '../../data/models/alert_settings.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {
  const SettingsInitial();
}

class SettingsLoaded extends SettingsState {
  final AlertSettings settings;

  const SettingsLoaded({required this.settings});

  @override
  List<Object?> get props => [settings];
}
