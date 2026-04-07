import 'package:equatable/equatable.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSettings extends SettingsEvent {
  const LoadSettings();
}

class UpdateTemperatureThreshold extends SettingsEvent {
  final double threshold;

  const UpdateTemperatureThreshold({required this.threshold});

  @override
  List<Object?> get props => [threshold];
}

class ToggleRainAlert extends SettingsEvent {
  final bool enabled;

  const ToggleRainAlert({required this.enabled});

  @override
  List<Object?> get props => [enabled];
}

class ToggleTemperatureUnit extends SettingsEvent {
  final bool isCelsius;

  const ToggleTemperatureUnit({required this.isCelsius});

  @override
  List<Object?> get props => [isCelsius];
}
