import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/temperature_utils.dart';

class AlertBanner extends StatelessWidget {
  final bool isTemperatureAlert;
  final bool isRainAlert;
  final double temperature;
  final double threshold;
  final double? rainVolume;
  final bool isCelsius;

  const AlertBanner({
    super.key,
    required this.isTemperatureAlert,
    required this.isRainAlert,
    required this.temperature,
    required this.threshold,
    this.rainVolume,
    required this.isCelsius,
  });

  @override
  Widget build(BuildContext context) {
    String message;
    if (isRainAlert && isTemperatureAlert) {
      message = 'Rain threshold: ${rainVolume?.toStringAsFixed(1) ?? '0.1'}mm met • Temp: ${TemperatureUtils.formatTempWithUnit(temperature, isCelsius)}';
    } else if (isRainAlert) {
      message = 'Rain threshold: ${rainVolume?.toStringAsFixed(1) ?? '0.1'}mm met';
    } else {
      message = 'Temperature: ${TemperatureUtils.formatTempWithUnit(temperature, isCelsius)} exceeds ${TemperatureUtils.formatTempWithUnit(threshold, isCelsius)}';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: AppColors.alertBannerGradient,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accentCyan.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(
            isRainAlert ? Icons.water_drop : Icons.thermostat,
            color: AppColors.accentCyan,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          /* const Icon(
            Icons.close,
            color: AppColors.textTertiary,
            size: 16,
          ), */
        ],
      ),
    );
  }
}
