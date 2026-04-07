import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/logger.dart';
import '../models/alert_settings.dart';

abstract class SettingsLocalDataSource {
  AlertSettings getSettings();
  Future<void> saveTemperatureThreshold(double threshold);
  Future<void> saveRainAlertEnabled(bool enabled);
}

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  final SharedPreferences prefs;

  SettingsLocalDataSourceImpl({required this.prefs});

  @override
  AlertSettings getSettings() {
    final tempThreshold = prefs.getDouble(AppConstants.tempThresholdKey) ?? AppConstants.defaultTempThreshold;
    final rainEnabled = prefs.getBool(AppConstants.rainAlertKey) ?? AppConstants.defaultRainAlertEnabled;

    appLogger.i('Settings loaded: temp=$tempThreshold, rain=$rainEnabled');

    return AlertSettings(temperatureThreshold: tempThreshold, rainAlertEnabled: rainEnabled);
  }

  @override
  Future<void> saveTemperatureThreshold(double threshold) async {
    await prefs.setDouble(AppConstants.tempThresholdKey, threshold);
    appLogger.i('Saved temperature threshold: $threshold');
  }

  @override
  Future<void> saveRainAlertEnabled(bool enabled) async {
    await prefs.setBool(AppConstants.rainAlertKey, enabled);
    appLogger.i('Saved rain alert enabled: $enabled');
  }
}
