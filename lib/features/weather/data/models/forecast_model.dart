import 'package:equatable/equatable.dart';

class ForecastModel extends Equatable {
  final List<ForecastDay> days;
  final String cityName;

  const ForecastModel({required this.days, required this.cityName});

  factory ForecastModel.fromJson(Map<String, dynamic> json) {
    final list = json['list'] as List<dynamic>;
    final city = json['city'] as Map<String, dynamic>;
    final cityName = city['name'] as String;

    // Group forecast items by day
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (final item in list) {
      final map = item as Map<String, dynamic>;
      final dt = DateTime.fromMillisecondsSinceEpoch((map['dt'] as int) * 1000);
      final dayKey = '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
      grouped.putIfAbsent(dayKey, () => []).add(map);
    }

    final days = grouped.entries
        .map((entry) {
          return ForecastDay.fromGroup(entry.key, entry.value);
        })
        .take(5)
        .toList();

    return ForecastModel(days: days, cityName: cityName);
  }

  Map<String, dynamic> toJson() {
    final List<Map<String, dynamic>> allItems = [];
    for (final day in days) {
      allItems.addAll(day.rawItems);
    }
    return {
      'list': allItems,
      'city': {'name': cityName},
    };
  }

  @override
  List<Object?> get props => [days, cityName];
}

class ForecastDay extends Equatable {
  final String dateKey;
  final DateTime date;
  final double tempMax;
  final double tempMin;
  final String condition;
  final String conditionDescription;
  final String icon;
  final int weatherId;
  final List<ForecastHour> hours;
  final List<Map<String, dynamic>> rawItems;

  const ForecastDay({
    required this.dateKey,
    required this.date,
    required this.tempMax,
    required this.tempMin,
    required this.condition,
    required this.conditionDescription,
    required this.icon,
    required this.weatherId,
    required this.hours,
    required this.rawItems,
  });

  bool get isRaining {
    return (weatherId >= 200 && weatherId < 400) || (weatherId >= 500 && weatherId < 600);
  }

  factory ForecastDay.fromGroup(String dateKey, List<Map<String, dynamic>> items) {
    double maxTemp = double.negativeInfinity;
    double minTemp = double.infinity;

    // Use the midday entry (or first) for condition representation
    Map<String, dynamic> representative = items.first;
    for (final item in items) {
      final dt = DateTime.fromMillisecondsSinceEpoch((item['dt'] as int) * 1000);
      if (dt.hour >= 11 && dt.hour <= 14) {
        representative = item;
      }
      final main = item['main'] as Map<String, dynamic>;
      final temp = (main['temp'] as num).toDouble();
      if (temp > maxTemp) maxTemp = temp;
      if (temp < minTemp) minTemp = temp;
    }

    final weather = representative['weather'][0] as Map<String, dynamic>;
    final parsedDate = DateTime.parse(dateKey);

    final hours = items.map((item) => ForecastHour.fromJson(item)).toList();

    return ForecastDay(
      dateKey: dateKey,
      date: parsedDate,
      tempMax: maxTemp,
      tempMin: minTemp,
      condition: weather['main'] as String,
      conditionDescription: weather['description'] as String,
      icon: weather['icon'] as String,
      weatherId: weather['id'] as int,
      hours: hours,
      rawItems: items,
    );
  }

  @override
  List<Object?> get props => [dateKey, tempMax, tempMin, condition, weatherId];
}

class ForecastHour extends Equatable {
  final DateTime dateTime;
  final double temperature;
  final String condition;
  final String icon;
  final int weatherId;

  const ForecastHour({
    required this.dateTime,
    required this.temperature,
    required this.condition,
    required this.icon,
    required this.weatherId,
  });

  factory ForecastHour.fromJson(Map<String, dynamic> json) {
    final weather = json['weather'][0] as Map<String, dynamic>;
    final main = json['main'] as Map<String, dynamic>;

    return ForecastHour(
      dateTime: DateTime.fromMillisecondsSinceEpoch((json['dt'] as int) * 1000),
      temperature: (main['temp'] as num).toDouble(),
      condition: weather['main'] as String,
      icon: weather['icon'] as String,
      weatherId: weather['id'] as int,
    );
  }

  @override
  List<Object?> get props => [dateTime, temperature, condition, icon];
}
