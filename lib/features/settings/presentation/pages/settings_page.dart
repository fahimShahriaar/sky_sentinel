import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/temperature_utils.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        if (state is SettingsLoaded) {
          return _buildSettings(context, state);
        }
        return const Center(child: CircularProgressIndicator(color: AppColors.accentCyan));
      },
    );
  }

  Widget _buildSettings(BuildContext context, SettingsLoaded state) {
    final settings = state.settings;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      children: [
        // Header
        const SizedBox(height: 8),
        Text('Settings', style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 4),
        const Text('Configure your weather alert preferences.', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        const SizedBox(height: 32),

        // Temperature Unit Section
        const Text(
          'TEMPERATURE UNIT',
          style: TextStyle(color: AppColors.textTertiary, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.5),
        ),
        const SizedBox(height: 16),

        Container(
          decoration: BoxDecoration(
            gradient: AppColors.cardGradient,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
          ),
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: AppColors.accentBlue.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.thermostat_auto, color: AppColors.accentBlue, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Display Unit',
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text('Choose temperature display unit', style: TextStyle(color: AppColors.textTertiary, fontSize: 12)),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.backgroundDark,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (!settings.isCelsius) {
                          context.read<SettingsBloc>().add(const ToggleTemperatureUnit(isCelsius: true));
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(color: settings.isCelsius ? AppColors.accentBlue : Colors.transparent, borderRadius: BorderRadius.circular(8)),
                        child: Text(
                          '°C',
                          style: TextStyle(color: settings.isCelsius ? AppColors.backgroundDark : AppColors.textSecondary, fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (settings.isCelsius) {
                          context.read<SettingsBloc>().add(const ToggleTemperatureUnit(isCelsius: false));
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(color: !settings.isCelsius ? AppColors.accentBlue : Colors.transparent, borderRadius: BorderRadius.circular(8)),
                        child: Text(
                          '°F',
                          style: TextStyle(color: !settings.isCelsius ? AppColors.backgroundDark : AppColors.textSecondary, fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Alert Thresholds Section
        const Text(
          'ALERT THRESHOLDS',
          style: TextStyle(color: AppColors.textTertiary, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.5),
        ),
        const SizedBox(height: 16),

        // Temperature Threshold
        Container(
          decoration: BoxDecoration(
            gradient: AppColors.cardGradient,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.alertOrange.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.thermostat,
                      color: AppColors.alertOrange,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Temperature Alert',
                          style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Notify when temperature exceeds threshold',
                          style: TextStyle(color: AppColors.textTertiary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Threshold',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundDark,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Text(
                      TemperatureUtils.formatTempWithUnit(settings.temperatureThreshold, settings.isCelsius),
                      style: const TextStyle(color: AppColors.alertOrange, fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SliderTheme(
                data: SliderThemeData(activeTrackColor: AppColors.alertOrange, inactiveTrackColor: AppColors.cardBorder, thumbColor: AppColors.alertOrange, overlayColor: AppColors.alertOrange.withValues(alpha: 0.2), trackHeight: 4),
                child: settings.isCelsius
                    ? Slider(
                        value: TemperatureUtils.fahrenheitToCelsius(settings.temperatureThreshold).roundToDouble().clamp(0, 49),
                        min: 0,
                        max: 50,
                        divisions: 50,
                        onChanged: (value) {
                          final fahrenheit = TemperatureUtils.celsiusToFahrenheit(value);
                          context.read<SettingsBloc>().add(UpdateTemperatureThreshold(threshold: fahrenheit));
                        },
                      )
                    : Slider(
                        value: settings.temperatureThreshold,
                        min: 0,
                        max: 120,
                        divisions: 120,
                        onChanged: (value) {
                          context.read<SettingsBloc>().add(UpdateTemperatureThreshold(threshold: value));
                        },
                      ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    settings.isCelsius ? '0°C' : '32°F',
                    style: const TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    settings.isCelsius ? '50°C' : '120°F',
                    style: const TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Rain Alert Toggle
        Container(
          decoration: BoxDecoration(
            gradient: AppColors.cardGradient,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
          ),
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: AppColors.accentCyan.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.water_drop, color: AppColors.accentCyan, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Rain Alert',
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text('Get notified when rain is detected', style: TextStyle(color: AppColors.textTertiary, fontSize: 12)),
                  ],
                ),
              ),
              Switch(
                value: settings.rainAlertEnabled,
                activeColor: AppColors.accentCyan,
                activeTrackColor: AppColors.accentCyan.withValues(alpha: 0.3),
                inactiveThumbColor: AppColors.textTertiary,
                inactiveTrackColor: AppColors.cardBorder,
                onChanged: (value) {
                  context.read<SettingsBloc>().add(ToggleRainAlert(enabled: value));
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // About Section
        const Text(
          'ABOUT',
          style: TextStyle(color: AppColors.textTertiary, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.5),
        ),
        const SizedBox(height: 16),

        Container(
          decoration: BoxDecoration(
            gradient: AppColors.cardGradient,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildAboutRow('App', 'Sky Sentinel v1.0.0'),
              const Divider(color: AppColors.divider, height: 24),
              _buildAboutRow('Data Source', 'OpenWeatherMap API'),
              const Divider(color: AppColors.divider, height: 24),
              _buildAboutRow('Background Check', 'Every 15 minutes'),
              // const Divider(color: AppColors.divider, height: 24),
              // _buildAboutRow('Architecture', 'BLoC + Clean Architecture'),
            ],
          ),
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildAboutRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        Text(
          value,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
