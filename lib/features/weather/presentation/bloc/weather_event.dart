import 'package:equatable/equatable.dart';

abstract class WeatherEvent extends Equatable {
  const WeatherEvent();

  @override
  List<Object?> get props => [];
}

class FetchCurrentWeather extends WeatherEvent {
  final double latitude;
  final double longitude;

  const FetchCurrentWeather({required this.latitude, required this.longitude});

  @override
  List<Object?> get props => [latitude, longitude];
}

class FetchForecast extends WeatherEvent {
  final double latitude;
  final double longitude;

  const FetchForecast({required this.latitude, required this.longitude});

  @override
  List<Object?> get props => [latitude, longitude];
}

class FetchAllWeatherData extends WeatherEvent {
  final double latitude;
  final double longitude;

  const FetchAllWeatherData({required this.latitude, required this.longitude});

  @override
  List<Object?> get props => [latitude, longitude];
}

class LoadCachedWeather extends WeatherEvent {
  const LoadCachedWeather();
}

class ClearAlertHighlight extends WeatherEvent {
  const ClearAlertHighlight();
}

class SetAlertHighlight extends WeatherEvent {
  final String alertType;

  const SetAlertHighlight({required this.alertType});

  @override
  List<Object?> get props => [alertType];
}
