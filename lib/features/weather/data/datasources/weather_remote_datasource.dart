import 'dart:convert';

import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/logger.dart';
import '../models/weather_model.dart';
import '../models/forecast_model.dart';
import '../models/air_quality_model.dart';

abstract class WeatherRemoteDataSource {
  Future<WeatherModel> getCurrentWeather(double lat, double lon);
  Future<ForecastModel> getForecast(double lat, double lon);
  Future<AirQualityModel> getAirQuality(double lat, double lon);
}

class WeatherRemoteDataSourceImpl implements WeatherRemoteDataSource {
  final Dio dio;

  WeatherRemoteDataSourceImpl({required this.dio});

  @override
  Future<WeatherModel> getCurrentWeather(double lat, double lon) async {
    try {
      appLogger.i('Fetching current weather for ($lat, $lon)');
      final response = await dio.get(ApiConstants.currentWeather(lat, lon));

      if (response.statusCode == 200) {
        appLogger.i('Data received: ${jsonEncode(response.data)}');
        return WeatherModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw ServerException(message: 'Failed to fetch weather data', statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      appLogger.e('Dio error fetching weather: ${e.message}');
      throw ServerException(message: e.message ?? 'Network error occurred', statusCode: e.response?.statusCode);
    }
  }

  @override
  Future<ForecastModel> getForecast(double lat, double lon) async {
    try {
      appLogger.i('Fetching forecast for ($lat, $lon)');
      final response = await dio.get(ApiConstants.forecast(lat, lon));

      if (response.statusCode == 200) {
        return ForecastModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw ServerException(message: 'Failed to fetch forecast data', statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      appLogger.e('Dio error fetching forecast: ${e.message}');
      throw ServerException(message: e.message ?? 'Network error occurred', statusCode: e.response?.statusCode);
    }
  }

  @override
  Future<AirQualityModel> getAirQuality(double lat, double lon) async {
    try {
      appLogger.i('Fetching air quality for ($lat, $lon)');
      final response = await dio.get(ApiConstants.airPollution(lat, lon));

      if (response.statusCode == 200) {
        return AirQualityModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw ServerException(message: 'Failed to fetch air quality data', statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      appLogger.e('Dio error fetching air quality: ${e.message}');
      throw ServerException(message: e.message ?? 'Network error occurred', statusCode: e.response?.statusCode);
    }
  }
}
