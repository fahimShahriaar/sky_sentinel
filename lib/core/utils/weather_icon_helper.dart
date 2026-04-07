import 'package:flutter/material.dart';

class WeatherIconHelper {
  WeatherIconHelper._();

  static IconData getIcon(int weatherId, {bool isNight = false}) {
    if (weatherId >= 200 && weatherId < 300) {
      return Icons.thunderstorm;
    } else if (weatherId >= 300 && weatherId < 400) {
      return Icons.grain;
    } else if (weatherId >= 500 && weatherId < 600) {
      return Icons.water_drop;
    } else if (weatherId >= 600 && weatherId < 700) {
      return Icons.ac_unit;
    } else if (weatherId >= 700 && weatherId < 800) {
      return Icons.foggy;
    } else if (weatherId == 800) {
      return isNight ? Icons.nightlight_round : Icons.wb_sunny;
    } else if (weatherId == 801) {
      return isNight ? Icons.nights_stay : Icons.wb_cloudy;
    } else if (weatherId >= 802 && weatherId <= 804) {
      return Icons.cloud;
    }
    return Icons.wb_sunny;
  }

  static Color getIconColor(int weatherId) {
    if (weatherId >= 200 && weatherId < 300) {
      return const Color(0xFFFFEB3B); // Thunderstorm - yellow
    } else if (weatherId >= 300 && weatherId < 400) {
      return const Color(0xFF90CAF9); // Drizzle - light blue
    } else if (weatherId >= 500 && weatherId < 600) {
      return const Color(0xFF42A5F5); // Rain - blue
    } else if (weatherId >= 600 && weatherId < 700) {
      return Colors.white; // Snow - white
    } else if (weatherId >= 700 && weatherId < 800) {
      return const Color(0xFF78909C); // Fog - grey
    } else if (weatherId == 800) {
      return const Color(0xFFFFD54F); // Clear - sunny yellow
    } else if (weatherId >= 801 && weatherId <= 804) {
      return const Color(0xFFB0BEC5); // Clouds - grey
    }
    return const Color(0xFFFFD54F);
  }

  static String getConditionText(int weatherId) {
    if (weatherId >= 200 && weatherId < 300) return 'THUNDERSTORM';
    if (weatherId >= 300 && weatherId < 400) return 'DRIZZLE';
    if (weatherId >= 500 && weatherId < 510) return 'RAIN';
    if (weatherId >= 510 && weatherId < 520) return 'FREEZING RAIN';
    if (weatherId >= 520 && weatherId < 600) return 'SHOWERS';
    if (weatherId >= 600 && weatherId < 700) return 'SNOW';
    if (weatherId >= 700 && weatherId < 800) return 'FOGGY';
    if (weatherId == 800) return 'CLEAR';
    if (weatherId == 801) return 'PARTLY CLOUDY';
    if (weatherId == 802) return 'SCATTERED CLOUDS';
    if (weatherId == 803) return 'BROKEN CLOUDS';
    if (weatherId == 804) return 'OVERCAST';
    return 'CLEAR';
  }
}
