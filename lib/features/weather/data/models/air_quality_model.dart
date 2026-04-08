import 'package:equatable/equatable.dart';

class AirQualityModel extends Equatable {
  final int aqi; // 1-5 (Good, Fair, Moderate, Poor, Very Poor)
  final double pm25;
  final double pm10;
  final double o3;
  final double no2;

  const AirQualityModel({
    required this.aqi,
    required this.pm25,
    required this.pm10,
    required this.o3,
    required this.no2,
  });

  factory AirQualityModel.fromJson(Map<String, dynamic> json) {
    final list = json['list'] as List;
    final entry = list.first as Map<String, dynamic>;
    final main = entry['main'] as Map<String, dynamic>;
    final components = entry['components'] as Map<String, dynamic>;

    return AirQualityModel(
      aqi: (main['aqi'] as num).toInt(),
      pm25: (components['pm2_5'] as num?)?.toDouble() ?? 0,
      pm10: (components['pm10'] as num?)?.toDouble() ?? 0,
      o3: (components['o3'] as num?)?.toDouble() ?? 0,
      no2: (components['no2'] as num?)?.toDouble() ?? 0,
    );
  }

  String get label {
    switch (aqi) {
      case 1:
        return 'Good';
      case 2:
        return 'Fair';
      case 3:
        return 'Moderate';
      case 4:
        return 'Poor';
      case 5:
        return 'Very Poor';
      default:
        return 'Unknown';
    }
  }

  @override
  List<Object?> get props => [aqi, pm25, pm10, o3, no2];
}
