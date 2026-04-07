import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_datasource.dart';
import '../models/alert_settings.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource localDataSource;

  SettingsRepositoryImpl({required this.localDataSource});

  @override
  AlertSettings getSettings() {
    return localDataSource.getSettings();
  }

  @override
  Future<void> saveTemperatureThreshold(double threshold) async {
    await localDataSource.saveTemperatureThreshold(threshold);
  }

  @override
  Future<void> saveRainAlertEnabled(bool enabled) async {
    await localDataSource.saveRainAlertEnabled(enabled);
  }

  @override
  Future<void> saveTemperatureUnit(bool isCelsius) async {
    await localDataSource.saveTemperatureUnit(isCelsius);
  }
}
