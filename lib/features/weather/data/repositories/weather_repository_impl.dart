import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/repositories/weather_repository.dart';
import '../datasources/weather_remote_datasource.dart';
import '../datasources/weather_local_datasource.dart';
import '../models/weather_model.dart';
import '../models/forecast_model.dart';
import '../models/air_quality_model.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherRemoteDataSource remoteDataSource;
  final WeatherLocalDataSource localDataSource;

  WeatherRepositoryImpl({required this.remoteDataSource, required this.localDataSource});

  @override
  Future<WeatherModel> getCurrentWeather(double lat, double lon) async {
    try {
      final weather = await remoteDataSource.getCurrentWeather(lat, lon);
      await localDataSource.cacheWeather(weather);
      await localDataSource.cacheLocationName(weather.cityName);
      await localDataSource.setLastUpdated(DateTime.now());
      return weather;
    } on ServerException catch (e) {
      appLogger.w('Remote fetch failed, trying cache: ${e.message}');
      try {
        return await localDataSource.getCachedWeather();
      } on CacheException {
        rethrow;
      }
    }
  }

  @override
  Future<ForecastModel> getForecast(double lat, double lon) async {
    try {
      final forecast = await remoteDataSource.getForecast(lat, lon);
      await localDataSource.cacheForecast(forecast);
      return forecast;
    } on ServerException catch (e) {
      appLogger.w('Remote forecast failed, trying cache: ${e.message}');
      try {
        return await localDataSource.getCachedForecast();
      } on CacheException {
        rethrow;
      }
    }
  }

  @override
  Future<WeatherModel?> getCachedWeather() async {
    try {
      return await localDataSource.getCachedWeather();
    } on CacheException {
      return null;
    }
  }

  @override
  Future<ForecastModel?> getCachedForecast() async {
    try {
      return await localDataSource.getCachedForecast();
    } on CacheException {
      return null;
    }
  }

  @override
  Future<DateTime?> getLastUpdated() async {
    return await localDataSource.getLastUpdated();
  }

  @override
  Future<AirQualityModel> getAirQuality(double lat, double lon) async {
    try {
      return await remoteDataSource.getAirQuality(lat, lon);
    } on ServerException catch (e) {
      appLogger.w('Failed to fetch air quality: ${e.message}');
      rethrow;
    }
  }
}
