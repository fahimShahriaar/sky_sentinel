import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
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
        Text(
          'ATMOSPHERIC INTELLIGENCE',
          style: TextStyle(color: AppColors.accentCyan, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 2),
        ),
        const SizedBox(height: 8),
        Text('Settings', style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 4),
        const Text('Configure your weather alert preferences.', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
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
                    decoration: BoxDecoration(color: AppColors.alertOrange.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.thermostat, color: AppColors.alertOrange, size: 22),
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
                        Text('Notify when temperature exceeds threshold', style: TextStyle(color: AppColors.textTertiary, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Threshold', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundDark,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Text(
                      '${settings.temperatureThreshold.toStringAsFixed(0)}°F',
                      style: const TextStyle(color: AppColors.alertOrange, fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SliderTheme(
                data: SliderThemeData(activeTrackColor: AppColors.alertOrange, inactiveTrackColor: AppColors.cardBorder, thumbColor: AppColors.alertOrange, overlayColor: AppColors.alertOrange.withValues(alpha: 0.2), trackHeight: 4),
                child: Slider(
                  value: settings.temperatureThreshold,
                  min: 60,
                  max: 120,
                  divisions: 60,
                  onChanged: (value) {
                    context.read<SettingsBloc>().add(UpdateTemperatureThreshold(threshold: value));
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('60°F', style: TextStyle(color: AppColors.textTertiary, fontSize: 11)),
                  Text('120°F', style: TextStyle(color: AppColors.textTertiary, fontSize: 11)),
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
              const Divider(color: AppColors.divider, height: 24),
              _buildAboutRow('Architecture', 'BLoC + Clean Architecture'),
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
