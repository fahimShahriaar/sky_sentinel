import 'package:equatable/equatable.dart';

class WeatherModel extends Equatable {
  final double temperature;
  final double feelsLike;
  final double tempMin;
  final double tempMax;
  final int humidity;
  final double windSpeed;
  final String windDirection;
  final String condition;
  final String conditionDescription;
  final String icon;
  final int weatherId;
  final String cityName;
  final int visibility;
  final int pressure;
  final double? uvIndex;
  final double? rainVolume;
  final DateTime timestamp;
  final int sunrise;
  final int sunset;

  const WeatherModel({
    required this.temperature,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.humidity,
    required this.windSpeed,
    required this.windDirection,
    required this.condition,
    required this.conditionDescription,
    required this.icon,
    required this.weatherId,
    required this.cityName,
    required this.visibility,
    required this.pressure,
    this.uvIndex,
    this.rainVolume,
    required this.timestamp,
    required this.sunrise,
    required this.sunset,
  });

  bool get isRaining {
    final id = weatherId;
    // Weather IDs 2xx = Thunderstorm, 3xx = Drizzle, 5xx = Rain
    return (id >= 200 && id < 400) || (id >= 500 && id < 600);
  }

  String get windDirectionLabel {
    return windDirection;
  }

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final weather = json['weather'][0] as Map<String, dynamic>;
    final main = json['main'] as Map<String, dynamic>;
    final wind = json['wind'] as Map<String, dynamic>;
    final sys = json['sys'] as Map<String, dynamic>?;
    final rain = json['rain'] as Map<String, dynamic>?;

    return WeatherModel(
      temperature: (main['temp'] as num).toDouble(),
      feelsLike: (main['feels_like'] as num).toDouble(),
      tempMin: (main['temp_min'] as num).toDouble(),
      tempMax: (main['temp_max'] as num).toDouble(),
      humidity: main['humidity'] as int,
      windSpeed: (wind['speed'] as num).toDouble(),
      windDirection: _degreesToDirection((wind['deg'] as num?)?.toDouble() ?? 0),
      condition: weather['main'] as String,
      conditionDescription: weather['description'] as String,
      icon: weather['icon'] as String,
      weatherId: weather['id'] as int,
      cityName: json['name'] as String? ?? '',
      visibility: json['visibility'] as int? ?? 0,
      pressure: main['pressure'] as int? ?? 0,
      rainVolume: rain != null ? (rain['1h'] as num?)?.toDouble() : null,
      timestamp: DateTime.fromMillisecondsSinceEpoch((json['dt'] as int) * 1000),
      sunrise: sys?['sunrise'] as int? ?? 0,
      sunset: sys?['sunset'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'weather': [
        {'id': weatherId, 'main': condition, 'description': conditionDescription, 'icon': icon},
      ],
      'main': {'temp': temperature, 'feels_like': feelsLike, 'temp_min': tempMin, 'temp_max': tempMax, 'humidity': humidity, 'pressure': pressure},
      'wind': {'speed': windSpeed, 'deg': _directionToDegrees(windDirection)},
      'visibility': visibility,
      'name': cityName,
      'dt': timestamp.millisecondsSinceEpoch ~/ 1000,
      'sys': {'sunrise': sunrise, 'sunset': sunset},
      if (rainVolume != null) 'rain': {'1h': rainVolume},
    };
  }

  static String _degreesToDirection(double degrees) {
    const directions = ['N', 'NNE', 'NE', 'ENE', 'E', 'ESE', 'SE', 'SSE', 'S', 'SSW', 'SW', 'WSW', 'W', 'WNW', 'NW', 'NNW'];
    final index = ((degrees + 11.25) / 22.5).floor() % 16;
    return directions[index];
  }

  static double _directionToDegrees(String direction) {
    const map = {'N': 0.0, 'NNE': 22.5, 'NE': 45.0, 'ENE': 67.5, 'E': 90.0, 'ESE': 112.5, 'SE': 135.0, 'SSE': 157.5, 'S': 180.0, 'SSW': 202.5, 'SW': 225.0, 'WSW': 247.5, 'W': 270.0, 'WNW': 292.5, 'NW': 315.0, 'NNW': 337.5};
    return map[direction] ?? 0.0;
  }

  @override
  List<Object?> get props => [temperature, feelsLike, tempMin, tempMax, humidity, windSpeed, windDirection, condition, conditionDescription, icon, weatherId, cityName, visibility, pressure, uvIndex, rainVolume, timestamp, sunrise, sunset];
}
