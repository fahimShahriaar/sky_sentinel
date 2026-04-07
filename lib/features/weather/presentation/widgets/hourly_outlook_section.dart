import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/weather_icon_helper.dart';
import '../../../../core/utils/temperature_utils.dart';
import '../../data/models/forecast_model.dart';

class HourlyOutlookSection extends StatelessWidget {
  final List<ForecastHour> hours;
  final bool isCelsius;

  const HourlyOutlookSection({super.key, required this.hours, required this.isCelsius});

  @override
  Widget build(BuildContext context) {
    // Take up to 8 hours
    final displayHours = hours.take(8).toList();

    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Hourly Outlook',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
              ),
              GestureDetector(
                onTap: () {
                  // Navigate to full report - can be extended
                },
                child: const Text(
                  'View Full Report',
                  style: TextStyle(color: AppColors.accentCyan, fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(displayHours.length, (index) {
                final hour = displayHours[index];
                final isNow = index == 0;
                final timeFormat = DateFormat('HH:mm');

                return Container(
                  width: 70,
                  margin: EdgeInsets.only(right: index < displayHours.length - 1 ? 8 : 0),
                  child: Column(
                    children: [
                      Text(
                        isNow ? 'NOW' : timeFormat.format(hour.dateTime),
                        style: TextStyle(color: isNow ? AppColors.accentCyan : AppColors.textTertiary, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      Icon(WeatherIconHelper.getIcon(hour.weatherId), color: WeatherIconHelper.getIconColor(hour.weatherId), size: 24),
                      const SizedBox(height: 12),
                      Text(
                        '${TemperatureUtils.formatTemp(hour.temperature, isCelsius)}°',
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
