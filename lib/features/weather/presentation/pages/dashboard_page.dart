import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/weather_icon_helper.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';
import '../../../settings/presentation/bloc/settings_state.dart';
import '../bloc/weather_bloc.dart';
import '../bloc/weather_state.dart';
import '../bloc/weather_event.dart';
import '../../../location/presentation/bloc/location_bloc.dart';
import '../../../location/presentation/bloc/location_state.dart';
import '../../../location/presentation/bloc/location_event.dart';
import '../widgets/weather_info_card.dart';
import '../widgets/hourly_outlook_section.dart';
import '../widgets/alert_banner.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<LocationBloc, LocationState>(
      listener: (context, state) {
        if (state is LocationLoaded) {
          context.read<WeatherBloc>().add(FetchAllWeatherData(latitude: state.latitude, longitude: state.longitude));
        }
      },
      child: BlocBuilder<WeatherBloc, WeatherState>(
        builder: (context, weatherState) {
          return RefreshIndicator(
            color: AppColors.accentCyan,
            backgroundColor: AppColors.backgroundCard,
            onRefresh: () async {
              final locationState = context.read<LocationBloc>().state;
              if (locationState is LocationLoaded) {
                context.read<WeatherBloc>().add(FetchAllWeatherData(latitude: locationState.latitude, longitude: locationState.longitude));
              } else {
                context.read<LocationBloc>().add(const FetchCurrentLocation());
              }
              // Wait for state change
              await context.read<WeatherBloc>().stream.firstWhere((s) => s is WeatherLoaded || s is WeatherError);
            },
            child: _buildContent(context, weatherState),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, WeatherState state) {
    if (state is WeatherLoading) {
      return _buildLoadingView(context, state);
    }
    if (state is WeatherError) {
      if (state.cachedWeather != null) {
        return _buildWeatherView(context, state.cachedWeather!, null, null, errorMessage: state.message);
      }
      return _buildErrorView(context, state.message);
    }
    if (state is WeatherLoaded) {
      return _buildWeatherView(context, state.weather, state.forecast, state.lastUpdated, alertHighlight: state.alertHighlight);
    }

    // Initial state - show loading
    return _buildInitialView(context);
  }

  Widget _buildInitialView(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_searching, size: 64, color: AppColors.accentCyan.withValues(alpha: 0.5)),
                const SizedBox(height: 16),
                Text('Getting your location...', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                const SizedBox(height: 24),
                const CircularProgressIndicator(color: AppColors.accentCyan),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingView(BuildContext context, WeatherLoading state) {
    if (state.previousWeather != null) {
      // Show previous data with loading overlay
      return Stack(
        children: [
          _buildWeatherView(context, state.previousWeather!, state.previousForecast, null),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(color: AppColors.accentCyan, backgroundColor: AppColors.backgroundCard),
          ),
        ],
      );
    }

    return CustomScrollView(
      slivers: [
        SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: AppColors.accentCyan),
                const SizedBox(height: 16),
                Text('Fetching weather data...', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorView(BuildContext context, String message) {
    return CustomScrollView(
      slivers: [
        SliverFillRemaining(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cloud_off, size: 64, color: AppColors.alertRed),
                  const SizedBox(height: 16),
                  Text('Unable to load weather', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<LocationBloc>().add(const FetchCurrentLocation());
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentCyan, foregroundColor: AppColors.backgroundDark),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherView(BuildContext context, dynamic weather, dynamic forecast, DateTime? lastUpdated, {String? errorMessage, String? alertHighlight}) {
    final now = DateTime.now();
    String updatedText = 'JUST NOW';
    if (lastUpdated != null) {
      final diff = now.difference(lastUpdated);
      if (diff.inMinutes < 1) {
        updatedText = 'JUST NOW';
      } else if (diff.inMinutes < 60) {
        updatedText = 'UPDATED ${diff.inMinutes}M AGO';
      } else if (diff.inHours < 24) {
        updatedText = 'UPDATED ${diff.inHours}H AGO';
      } else {
        updatedText = 'UPDATED ${diff.inDays}D AGO';
      }
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      children: [
        // Alert banner
        BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, settingsState) {
            if (settingsState is SettingsLoaded) {
              final settings = settingsState.settings;
              final isOverTemp = weather.temperature > settings.temperatureThreshold;
              final isRaining = weather.isRaining && settings.rainAlertEnabled;

              if (isOverTemp || isRaining) {
                return AlertBanner(isTemperatureAlert: isOverTemp, isRainAlert: isRaining, temperature: weather.temperature, threshold: settings.temperatureThreshold, rainVolume: weather.rainVolume);
              }
            }
            return const SizedBox.shrink();
          },
        ),

        if (errorMessage != null)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.alertRed.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.alertRed.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.alertRed, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Using cached data. $errorMessage', style: const TextStyle(color: AppColors.alertRed, fontSize: 12)),
                ),
              ],
            ),
          ),

        const SizedBox(height: 16),

        // Main temperature display
        Center(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${weather.temperature.toStringAsFixed(0)}°',
                    style: TextStyle(fontSize: 96, fontWeight: FontWeight.w200, color: AppColors.textPrimary, height: 1),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      'F',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w300, color: AppColors.accentCyan),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(WeatherIconHelper.getIcon(weather.weatherId), color: WeatherIconHelper.getIconColor(weather.weatherId), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    weather.conditionDescription[0].toUpperCase() + weather.conditionDescription.substring(1),
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w400),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                updatedText,
                style: const TextStyle(color: AppColors.textTertiary, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.5),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Info cards
        _buildAnimatedCard(
          child: WeatherInfoCard(icon: Icons.water_drop_outlined, iconColor: AppColors.accentCyan, label: 'Humidity', value: '${weather.humidity}%', highlighted: false),
          highlighted: alertHighlight == AppConstants.alertPayloadRain,
        ),
        const SizedBox(height: 12),
        _buildAnimatedCard(
          child: WeatherInfoCard(icon: Icons.air, iconColor: AppColors.textSecondary, label: 'Wind Speed', value: '${weather.windSpeed.toStringAsFixed(0)} mph', suffix: weather.windDirection, highlighted: false),
          highlighted: false,
        ),
        const SizedBox(height: 12),
        _buildAnimatedCard(
          child: WeatherInfoCard(icon: Icons.thermostat, iconColor: _getUvColor(weather.temperature), label: 'Feels Like', value: '${weather.feelsLike.toStringAsFixed(0)}°F', suffix: _getFeelsLikeLabel(weather.feelsLike), highlighted: alertHighlight == AppConstants.alertPayloadTemp),
          highlighted: alertHighlight == AppConstants.alertPayloadTemp,
        ),

        const SizedBox(height: 24),

        // Hourly Outlook
        if (forecast != null && forecast.days.isNotEmpty) HourlyOutlookSection(hours: forecast.days.first.hours),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildAnimatedCard({required Widget child, required bool highlighted}) {
    if (highlighted) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: AppColors.accentCyan.withValues(alpha: 0.3), blurRadius: 12, spreadRadius: 2)],
        ),
        child: child,
      );
    }
    return child;
  }

  Color _getUvColor(double temp) {
    if (temp > 95) return AppColors.alertRed;
    if (temp > 85) return AppColors.alertOrange;
    if (temp > 75) return AppColors.alertYellow;
    return AppColors.accentTeal;
  }

  String _getFeelsLikeLabel(double feelsLike) {
    if (feelsLike > 95) return 'Extreme';
    if (feelsLike > 85) return 'High';
    if (feelsLike > 75) return 'Moderate';
    if (feelsLike > 60) return 'Comfortable';
    return 'Cool';
  }
}
