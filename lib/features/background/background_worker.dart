import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import '../../core/constants/api_constants.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/logger.dart';
import '../notifications/notification_service.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    appLogger.i('Background task started: $task');

    try {
      final prefs = await SharedPreferences.getInstance();

      // Get settings
      final tempThreshold = prefs.getDouble(AppConstants.tempThresholdKey) ?? AppConstants.defaultTempThreshold;
      final rainAlertEnabled = prefs.getBool(AppConstants.rainAlertKey) ?? AppConstants.defaultRainAlertEnabled;
      final isCelsius = prefs.getBool(AppConstants.tempUnitCelsiusKey) ?? AppConstants.defaultIsCelsius;

      // Get location — try last known first (instant), then fresh fix
      Position? position;
      try {
        final hasPermission = await Geolocator.checkPermission();
        if (hasPermission == LocationPermission.always || hasPermission == LocationPermission.whileInUse) {
          position = await Geolocator.getLastKnownPosition();
          position ??= await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.low,
              timeLimit: Duration(seconds: 30),
            ),
          );
        }
      } catch (e) {
        appLogger.w('Background: Could not get location: $e');
      }

      if (position == null) {
        appLogger.w('Background: No location available, skipping');
        return true;
      }

      // Fetch weather
      final dio = Dio();
      final response = await dio.get(
        ApiConstants.currentWeather(
          position.latitude,
          position.longitude,
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        // Cache weather
        await prefs.setString(AppConstants.cachedWeatherKey, jsonEncode(data));
        await prefs.setInt(AppConstants.lastUpdatedKey, DateTime.now().millisecondsSinceEpoch);

        final main = data['main'] as Map<String, dynamic>;
        final temperature = (main['temp'] as num).toDouble();
        final weatherList = data['weather'] as List<dynamic>;
        final weather = weatherList[0] as Map<String, dynamic>;
        final weatherId = weather['id'] as int;
        final rain = data['rain'] as Map<String, dynamic>?;
        final rainVolume = rain != null ? (rain['1h'] as num?)?.toDouble() : null;

        final isRaining = (weatherId >= 200 && weatherId < 400) || (weatherId >= 500 && weatherId < 600);

        // Initialize notifications for background
        final notificationService = NotificationService();
        await notificationService.initialize();

        // Check temperature threshold
        if (temperature > tempThreshold) {
          appLogger.i('Background: Temperature $temperature > $tempThreshold, alerting');
          await notificationService.showTemperatureAlert(temperature, tempThreshold, isCelsius: isCelsius);
        }

        // Check rain
        if (rainAlertEnabled && isRaining) {
          appLogger.i('Background: Rain detected, alerting');
          await notificationService.showRainAlert(rainVolume: rainVolume);
        }
      }

      return true;
    } catch (e) {
      appLogger.e('Background task error: $e');
      return false;
    }
  });
}

class BackgroundWorker {
  static Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: true,
    );
    appLogger.i('Background worker initialized');
  }

  static Future<void> registerPeriodicTask() async {
    await Workmanager().registerPeriodicTask(
      AppConstants.backgroundTaskName,
      AppConstants.backgroundTaskName,
      frequency: AppConstants.backgroundTaskFrequency,
      constraints: Constraints(networkType: NetworkType.connected),
    );
    appLogger.i('Periodic background task registered');
  }

  static Future<void> cancelAll() async {
    await Workmanager().cancelAll();
    appLogger.i('All background tasks cancelled');
  }
}
