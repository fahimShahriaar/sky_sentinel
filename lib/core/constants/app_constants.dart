class AppConstants {
  AppConstants._();

  static const String appName = 'Sky Sentinel';
  static const String appTagline = 'Atmospheric Intelligence';

  // Shared Preferences Keys
  static const String cachedWeatherKey = 'cached_weather';
  static const String cachedForecastKey = 'cached_forecast';
  static const String cachedLocationNameKey = 'cached_location_name';
  static const String tempThresholdKey = 'temp_threshold';
  static const String rainAlertKey = 'rain_alert_enabled';
  static const String tempUnitCelsiusKey = 'temp_unit_celsius';
  static const String lastUpdatedKey = 'last_updated';

  // Background Task
  static const String backgroundTaskName = 'weatherCheckTask';
  static const Duration backgroundTaskFrequency = Duration(minutes: 15);

  // Default Thresholds
  static const double defaultTempThreshold = 95.0; // Fahrenheit (stored internally)
  static const bool defaultRainAlertEnabled = true;
  static const bool defaultIsCelsius = true;

  // Notification
  static const String notificationChannelId = 'sky_sentinel_alerts';
  static const String notificationChannelName = 'Weather Alerts';
  static const String notificationChannelDescription = 'Notifications for weather threshold alerts';
  static const int notificationId = 1001;

  // Alert trigger key passed via notification payload
  static const String alertPayloadTemp = 'temperature_alert';
  static const String alertPayloadRain = 'rain_alert';
}
