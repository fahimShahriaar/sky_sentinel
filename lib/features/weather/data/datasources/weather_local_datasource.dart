import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/logger.dart';
import '../models/weather_model.dart';
import '../models/forecast_model.dart';

abstract class WeatherLocalDataSource {
  Future<WeatherModel> getCachedWeather();
  Future<ForecastModel> getCachedForecast();
  Future<void> cacheWeather(WeatherModel weather);
  Future<void> cacheForecast(ForecastModel forecast);
  Future<String?> getCachedLocationName();
  Future<void> cacheLocationName(String name);
  Future<DateTime?> getLastUpdated();
  Future<void> setLastUpdated(DateTime time);
}

class WeatherLocalDataSourceImpl implements WeatherLocalDataSource {
  final SharedPreferences prefs;

  WeatherLocalDataSourceImpl({required this.prefs});

  @override
  Future<WeatherModel> getCachedWeather() async {
    final jsonString = prefs.getString(AppConstants.cachedWeatherKey);
    if (jsonString != null) {
      try {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        appLogger.i('Loaded cached weather data');
        return WeatherModel.fromJson(json);
      } catch (e) {
        throw const CacheException(message: 'Failed to parse cached weather');
      }
    }
    throw const CacheException(message: 'No cached weather data found');
  }

  @override
  Future<ForecastModel> getCachedForecast() async {
    final jsonString = prefs.getString(AppConstants.cachedForecastKey);
    if (jsonString != null) {
      try {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        appLogger.i('Loaded cached forecast data');
        return ForecastModel.fromJson(json);
      } catch (e) {
        throw const CacheException(message: 'Failed to parse cached forecast');
      }
    }
    throw const CacheException(message: 'No cached forecast data found');
  }

  @override
  Future<void> cacheWeather(WeatherModel weather) async {
    final jsonString = jsonEncode(weather.toJson());
    await prefs.setString(AppConstants.cachedWeatherKey, jsonString);
    appLogger.i('Cached weather data');
  }

  @override
  Future<void> cacheForecast(ForecastModel forecast) async {
    final jsonString = jsonEncode(forecast.toJson());
    await prefs.setString(AppConstants.cachedForecastKey, jsonString);
    appLogger.i('Cached forecast data');
  }

  @override
  Future<String?> getCachedLocationName() async {
    return prefs.getString(AppConstants.cachedLocationNameKey);
  }

  @override
  Future<void> cacheLocationName(String name) async {
    await prefs.setString(AppConstants.cachedLocationNameKey, name);
  }

  @override
  Future<DateTime?> getLastUpdated() async {
    final millis = prefs.getInt(AppConstants.lastUpdatedKey);
    if (millis != null) {
      return DateTime.fromMillisecondsSinceEpoch(millis);
    }
    return null;
  }

  @override
  Future<void> setLastUpdated(DateTime time) async {
    await prefs.setInt(AppConstants.lastUpdatedKey, time.millisecondsSinceEpoch);
  }
}
