import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/temperature_utils.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';
import '../../../settings/presentation/bloc/settings_state.dart';
import '../../data/models/weather_model.dart';

class AlertModal extends StatelessWidget {
  final String alertType;
  final WeatherModel weather;
  final VoidCallback onDismiss;
  final VoidCallback onViewDashboard;

  const AlertModal({super.key, required this.alertType, required this.weather, required this.onDismiss, required this.onViewDashboard});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settingsState) {
        final isCelsius = settingsState is SettingsLoaded ? settingsState.settings.isCelsius : true;
        return _buildModal(context, isCelsius);
      },
    );
  }

  Widget _buildModal(BuildContext context, bool isCelsius) {
    final isRainAlert = alertType == AppConstants.alertPayloadRain;
    final title = isRainAlert ? 'Rain Detected' : 'Temperature Alert';
    final subtitle = isRainAlert ? 'Precipitation Spike Observed' : 'Temperature Threshold Exceeded';
    final mainValue = isRainAlert ? '${weather.rainVolume?.toStringAsFixed(1) ?? '0.2'}in' : TemperatureUtils.formatTempWithUnit(weather.temperature, isCelsius);

    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF0D1B2A), Color(0xFF0A1628)]),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.accentCyan.withValues(alpha: 0.2)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Text(
                  'ATMOSPHERIC ALERT',
                  style: TextStyle(color: AppColors.accentCyan, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 2),
                ),
              ),

              const SizedBox(height: 24),

              // Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(color: AppColors.accentCyan.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(24)),
                child: Icon(isRainAlert ? Icons.cloud : Icons.thermostat, color: AppColors.accentCyan, size: 40),
              ),

              const SizedBox(height: 24),

              // Title
              Text(
                '$title:',
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w700),
              ),
              Text(
                mainValue,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 28, fontWeight: FontWeight.w700),
              ),

              const SizedBox(height: 8),

              Text(
                subtitle,
                style: const TextStyle(color: AppColors.accentCyan, fontSize: 14, fontWeight: FontWeight.w500),
              ),

              const SizedBox(height: 16),

              // Description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.5),
                    children: isRainAlert
                        ? [
                            const TextSpan(text: 'Threshold of '),
                            const TextSpan(
                              text: '0.1in',
                              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                            const TextSpan(text: ' exceeded.\nExpect rain for the next '),
                            const TextSpan(
                              text: '2 hours',
                              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                            const TextSpan(text: '.'),
                          ]
                        : [
                            const TextSpan(text: 'Temperature has risen to '),
                            TextSpan(
                              text: TemperatureUtils.formatTempWithUnit(weather.temperature, isCelsius),
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                            const TextSpan(text: '.\nStay hydrated and avoid prolonged sun exposure.'),
                          ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // View Dashboard Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: onViewDashboard,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentCyan,
                      foregroundColor: AppColors.backgroundDark,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: const Text('View Full Dashboard', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Dismiss
              TextButton(
                onPressed: onDismiss,
                child: const Text('Dismiss Alert', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
              ),

              const SizedBox(height: 16),

              // Bottom stats
              Container(
                decoration: BoxDecoration(
                  color: AppColors.backgroundDark.withValues(alpha: 0.5),
                  borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'CONFIDENCE',
                            style: TextStyle(color: AppColors.textTertiary, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Text(
                                '94%',
                                style: TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(width: 8),
                              Icon(Icons.analytics, color: AppColors.accentCyan, size: 20),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(width: 1, height: 40, color: AppColors.cardBorder),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'WIND SPEED',
                              style: TextStyle(color: AppColors.textTertiary, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Text(
                                  '${weather.windSpeed.toStringAsFixed(0)}mph',
                                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(width: 8),
                                Icon(Icons.air, color: AppColors.accentCyan, size: 20),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
