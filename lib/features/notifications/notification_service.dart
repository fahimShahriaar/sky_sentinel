import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/temperature_utils.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  static String? pendingPayload;

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    appLogger.i('Notification service initialized');
  }

  /// Request notification permission on Android 13+.
  /// Must be called after the Activity is attached (e.g. after first frame).
  Future<void> requestPermission() async {
    try {
      await _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
      appLogger.i('Notification permission requested');
    } catch (e) {
      appLogger.w('Failed to request notification permission: $e');
    }
  }

  static void _onNotificationTap(NotificationResponse response) {
    appLogger.i('Notification tapped with payload: ${response.payload}');
    pendingPayload = response.payload;
  }

  Future<void> showWeatherAlert({
    required String title,
    required String body,
    required String payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      AppConstants.notificationChannelId,
      AppConstants.notificationChannelName,
      channelDescription: AppConstants.notificationChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
      styleInformation: BigTextStyleInformation(''),
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    await _plugin.show(
      AppConstants.notificationId,
      title,
      body,
      details,
      payload: payload,
    );

    appLogger.i('Weather alert notification shown: $title');
  }

  Future<void> showTemperatureAlert(
    double temperature,
    double threshold, {
    bool isCelsius = true,
  }) async {
    final tempStr = TemperatureUtils.formatTempWithUnit(temperature, isCelsius);
    final thresholdStr = TemperatureUtils.formatTempWithUnit(threshold, isCelsius);
    await showWeatherAlert(
      title: '🌡️ Temperature Alert',
      body: 'Temperature exceeded $thresholdStr! Current: $tempStr',
      payload: AppConstants.alertPayloadTemp,
    );
  }

  Future<void> showRainAlert({double? rainVolume}) async {
    final rainInfo = rainVolume != null ? ' (${rainVolume.toStringAsFixed(1)}in)' : '';
    await showWeatherAlert(
      title: '🌧️ Rain Alert',
      body: 'Rain expected in your area$rainInfo. Don\'t forget your umbrella!',
      payload: AppConstants.alertPayloadRain,
    );
  }
}
