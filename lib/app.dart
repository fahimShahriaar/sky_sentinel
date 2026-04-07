import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'features/location/presentation/bloc/location_bloc.dart';
import 'features/location/presentation/bloc/location_event.dart';
import 'features/location/presentation/bloc/location_state.dart';
import 'features/notifications/notification_service.dart';
import 'features/settings/presentation/bloc/settings_bloc.dart';
import 'features/settings/presentation/bloc/settings_event.dart';
import 'features/weather/presentation/bloc/weather_bloc.dart';
import 'features/weather/presentation/bloc/weather_event.dart';
import 'features/weather/presentation/bloc/weather_state.dart';
import 'features/weather/presentation/pages/dashboard_page.dart';
import 'features/weather/presentation/pages/forecast_page.dart';
import 'features/weather/presentation/widgets/alert_modal.dart';
import 'features/settings/presentation/pages/settings_page.dart';
import 'injection_container.dart';

class SkySentinelApp extends StatelessWidget {
  const SkySentinelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<WeatherBloc>(create: (_) => sl<WeatherBloc>()),
        BlocProvider<LocationBloc>(create: (_) => sl<LocationBloc>()..add(const FetchCurrentLocation())),
        BlocProvider<SettingsBloc>(create: (_) => sl<SettingsBloc>()..add(const LoadSettings())),
      ],
      child: MaterialApp(title: AppConstants.appName, theme: AppTheme.darkTheme, debugShowCheckedModeBanner: false, home: const AppShell()),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;
  bool _showAlertModal = false;
  String? _alertPayload;

  final List<Widget> _pages = const [DashboardPage(), ForecastPage(), SettingsPage()];

  @override
  void initState() {
    super.initState();
    _checkPendingNotification();
  }

  void _checkPendingNotification() {
    final payload = NotificationService.pendingPayload;
    if (payload != null) {
      NotificationService.pendingPayload = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _showAlertModal = true;
          _alertPayload = payload;
        });
        context.read<WeatherBloc>().add(SetAlertHighlight(alertType: payload));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // App Bar
                _buildAppBar(context),
                // Page content
                Expanded(child: _pages[_currentIndex]),
              ],
            ),

            // Alert Modal Overlay
            if (_showAlertModal && _alertPayload != null)
              BlocBuilder<WeatherBloc, WeatherState>(
                builder: (context, state) {
                  if (state is WeatherLoaded) {
                    return AlertModal(
                      alertType: _alertPayload!,
                      weather: state.weather,
                      onDismiss: () {
                        setState(() {
                          _showAlertModal = false;
                          _alertPayload = null;
                        });
                      },
                      onViewDashboard: () {
                        setState(() {
                          _showAlertModal = false;
                          _currentIndex = 0;
                        });
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          // Search icon
          Icon(Icons.search, color: AppColors.textSecondary, size: 22),
          const SizedBox(width: 12),

          // Location name
          Expanded(
            child: BlocBuilder<WeatherBloc, WeatherState>(
              builder: (context, state) {
                String cityName = 'Loading...';
                if (state is WeatherLoaded) {
                  cityName = state.weather.cityName;
                } else if (state is WeatherError && state.cachedWeather != null) {
                  cityName = state.cachedWeather!.cityName;
                }
                return Text(
                  cityName,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600),
                );
              },
            ),
          ),

          // Notification bell
          BlocBuilder<LocationBloc, LocationState>(
            builder: (context, state) {
              return GestureDetector(
                onTap: () {
                  if (state is LocationLoaded) {
                    context.read<WeatherBloc>().add(FetchAllWeatherData(latitude: state.latitude, longitude: state.longitude));
                  } else {
                    context.read<LocationBloc>().add(const FetchCurrentLocation());
                  }
                },
                child: const Icon(Icons.notifications_outlined, color: AppColors.textSecondary, size: 22),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.backgroundDark,
        border: Border(top: BorderSide(color: AppColors.cardBorder, width: 0.5)),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), activeIcon: Icon(Icons.bar_chart), label: 'Analytics'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), activeIcon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
