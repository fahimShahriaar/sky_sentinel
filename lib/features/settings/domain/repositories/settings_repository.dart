import '../../data/models/alert_settings.dart';

abstract class SettingsRepository {
  AlertSettings getSettings();
  Future<void> saveTemperatureThreshold(double threshold);
  Future<void> saveRainAlertEnabled(bool enabled);
  Future<void> saveTemperatureUnit(bool isCelsius);
}
