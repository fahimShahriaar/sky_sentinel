import 'package:equatable/equatable.dart';
import '../../data/models/weather_model.dart';
import '../../data/models/forecast_model.dart';
import '../../data/models/air_quality_model.dart';

abstract class WeatherState extends Equatable {
  const WeatherState();

  @override
  List<Object?> get props => [];
}

class WeatherInitial extends WeatherState {
  const WeatherInitial();
}

class WeatherLoading extends WeatherState {
  final WeatherModel? previousWeather;
  final ForecastModel? previousForecast;

  const WeatherLoading({this.previousWeather, this.previousForecast});

  @override
  List<Object?> get props => [previousWeather, previousForecast];
}

class WeatherLoaded extends WeatherState {
  final WeatherModel weather;
  final ForecastModel? forecast;
  final AirQualityModel? airQuality;
  final DateTime? lastUpdated;
  final String? alertHighlight;

  const WeatherLoaded({required this.weather, this.forecast, this.airQuality, this.lastUpdated, this.alertHighlight});

  WeatherLoaded copyWith({WeatherModel? weather, ForecastModel? forecast, AirQualityModel? airQuality, DateTime? lastUpdated, String? alertHighlight, bool clearAlert = false}) {
    return WeatherLoaded(weather: weather ?? this.weather, forecast: forecast ?? this.forecast, airQuality: airQuality ?? this.airQuality, lastUpdated: lastUpdated ?? this.lastUpdated, alertHighlight: clearAlert ? null : (alertHighlight ?? this.alertHighlight));
  }

  @override
  List<Object?> get props => [weather, forecast, airQuality, lastUpdated, alertHighlight];
}

class WeatherError extends WeatherState {
  final String message;
  final WeatherModel? cachedWeather;
  final ForecastModel? cachedForecast;

  const WeatherError({required this.message, this.cachedWeather, this.cachedForecast});

  @override
  List<Object?> get props => [message, cachedWeather, cachedForecast];
}
