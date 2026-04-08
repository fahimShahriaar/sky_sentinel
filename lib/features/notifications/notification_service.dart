import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/temperature_utils.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  /// Payload from the notification that launched the app (cold start).
  static String? pendingPayload;

  /// Stream that fires when a notification is tapped while the app is running.
  static final StreamController<String> _onTapController = StreamController<String>.broadcast();
  static Stream<String> get onNotificationTap => _onTapController.stream;

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

    // Check if the app was launched by tapping a notification (cold start)
    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    if (launchDetails != null && launchDetails.didNotificationLaunchApp && launchDetails.notificationResponse?.payload != null) {
      pendingPayload = launchDetails.notificationResponse!.payload;
      appLogger.i('App launched from notification: $pendingPayload');
    }

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
    final payload = response.payload;
    appLogger.i('Notification tapped with payload: $payload');
    if (payload != null) {
      _onTapController.add(payload);
    }
  }

  Future<void> showWeatherAlert({
    required int id,
    required String title,
    required String body,
    required String payload,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      AppConstants.notificationChannelId,
      AppConstants.notificationChannelName,
      channelDescription: AppConstants.notificationChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
      styleInformation: BigTextStyleInformation(body),
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    await _plugin.show(
      id,
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
      id: AppConstants.tempNotificationId,
      title: '🌡️ Temperature Alert',
      body: 'Temperature exceeded $thresholdStr! Current: $tempStr',
      payload: AppConstants.alertPayloadTemp,
    );
  }

  Future<void> showRainAlert({double? rainVolume}) async {
    final rainInfo = rainVolume != null ? ' (${rainVolume.toStringAsFixed(1)}mm)' : '';
    await showWeatherAlert(
      id: AppConstants.rainNotificationId,
      title: '🌧️ Rain Alert',
      body: 'Rain expected in your area$rainInfo. Don\'t forget your umbrella!',
      payload: AppConstants.alertPayloadRain,
    );
  }
}
