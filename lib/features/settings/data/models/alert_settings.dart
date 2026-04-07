import 'package:equatable/equatable.dart';
import '../../../../core/constants/app_constants.dart';

class AlertSettings extends Equatable {
  final double temperatureThreshold;
  final bool rainAlertEnabled;
  final bool isCelsius;

  const AlertSettings({
    this.temperatureThreshold = AppConstants.defaultTempThreshold,
    this.rainAlertEnabled = AppConstants.defaultRainAlertEnabled,
    this.isCelsius = AppConstants.defaultIsCelsius,
  });

  AlertSettings copyWith({double? temperatureThreshold, bool? rainAlertEnabled, bool? isCelsius}) {
    return AlertSettings(
      temperatureThreshold: temperatureThreshold ?? this.temperatureThreshold,
      rainAlertEnabled: rainAlertEnabled ?? this.rainAlertEnabled,
      isCelsius: isCelsius ?? this.isCelsius,
    );
  }

  @override
  List<Object?> get props => [temperatureThreshold, rainAlertEnabled, isCelsius];
}
