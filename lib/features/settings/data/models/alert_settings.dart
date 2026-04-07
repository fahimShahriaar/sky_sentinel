import 'package:equatable/equatable.dart';
import '../../../../core/constants/app_constants.dart';

class AlertSettings extends Equatable {
  final double temperatureThreshold;
  final bool rainAlertEnabled;

  const AlertSettings({this.temperatureThreshold = AppConstants.defaultTempThreshold, this.rainAlertEnabled = AppConstants.defaultRainAlertEnabled});

  AlertSettings copyWith({double? temperatureThreshold, bool? rainAlertEnabled}) {
    return AlertSettings(temperatureThreshold: temperatureThreshold ?? this.temperatureThreshold, rainAlertEnabled: rainAlertEnabled ?? this.rainAlertEnabled);
  }

  @override
  List<Object?> get props => [temperatureThreshold, rainAlertEnabled];
}
