import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/weather_icon_helper.dart';
import '../bloc/weather_bloc.dart';
import '../bloc/weather_state.dart';
import '../bloc/weather_event.dart';
import '../../../location/presentation/bloc/location_bloc.dart';
import '../../../location/presentation/bloc/location_state.dart';

class ForecastPage extends StatelessWidget {
  const ForecastPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WeatherBloc, WeatherState>(
      builder: (context, state) {
        if (state is WeatherLoading) {
          return const Center(child: CircularProgressIndicator(color: AppColors.accentCyan));
        }

        if (state is WeatherLoaded && state.forecast != null) {
          return _buildForecastView(context, state);
        }

        if (state is WeatherError && state.cachedForecast != null) {
          return _buildForecastList(context, state.cachedForecast!);
        }

        return _buildEmptyView(context);
      },
    );
  }

  Widget _buildForecastView(BuildContext context, WeatherLoaded state) {
    return RefreshIndicator(
      color: AppColors.accentCyan,
      backgroundColor: AppColors.backgroundCard,
      onRefresh: () async {
        final locationState = context.read<LocationBloc>().state;
        if (locationState is LocationLoaded) {
          context.read<WeatherBloc>().add(FetchAllWeatherData(latitude: locationState.latitude, longitude: locationState.longitude));
          await context.read<WeatherBloc>().stream.firstWhere((s) => s is WeatherLoaded || s is WeatherError);
        }
      },
      child: _buildForecastList(context, state.forecast!),
    );
  }

  Widget _buildForecastList(BuildContext context, dynamic forecast) {
    final days = forecast.days;
    final cityName = forecast.cityName;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      children: [
        // Header
        Text(
          'ATMOSPHERIC INTELLIGENCE',
          style: TextStyle(color: AppColors.accentCyan, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 2),
        ),
        const SizedBox(height: 8),
        Text('Weekly Forecast', style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 4),
        Text('Next ${days.length} days atmospheric outlook for $cityName.', style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        const SizedBox(height: 24),

        // Forecast cards
        ...List.generate(days.length, (index) {
          final day = days[index];
          final isToday = index == 0;
          final dateFormat = DateFormat('MMM d');
          final dayFormat = DateFormat('EEEE');

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              gradient: AppColors.cardGradient,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              children: [
                // Date and day
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isToday ? 'TODAY • ${dateFormat.format(day.date).toUpperCase()}' : dateFormat.format(day.date).toUpperCase(),
                        style: TextStyle(color: isToday ? AppColors.accentCyan : AppColors.textTertiary, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dayFormat.format(day.date),
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),

                // Weather icon
                Icon(WeatherIconHelper.getIcon(day.weatherId), color: WeatherIconHelper.getIconColor(day.weatherId), size: 32),
                const SizedBox(width: 16),

                // Temps
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${day.tempMax.toStringAsFixed(0)}°',
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.w600),
                        ),
                        Text('/${day.tempMin.toStringAsFixed(0)}°', style: const TextStyle(color: AppColors.textTertiary, fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      WeatherIconHelper.getConditionText(day.weatherId),
                      style: TextStyle(color: day.isRaining ? AppColors.accentCyan : AppColors.textTertiary, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),

        const SizedBox(height: 12),

        // Air Quality Card (placeholder)
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
                decoration: BoxDecoration(color: AppColors.accentTeal.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.eco, color: AppColors.accentTeal, size: 22),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'AIR QUALITY',
                    style: TextStyle(color: AppColors.textTertiary, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.circle, size: 8, color: AppColors.accentTeal),
                      const SizedBox(width: 6),
                      const Text(
                        'Good • 24 AQI',
                        style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildEmptyView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today, size: 64, color: AppColors.textTertiary.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          const Text('No forecast data available', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
          const SizedBox(height: 8),
          const Text('Pull to refresh on the dashboard', style: TextStyle(color: AppColors.textTertiary, fontSize: 14)),
        ],
      ),
    );
  }
}
