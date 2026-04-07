import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/logger.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  static String? pendingPayload;

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    const darwinSettings = DarwinInitializationSettings(requestAlertPermission: true, requestBadgePermission: true, requestSoundPermission: true);

    const initSettings = InitializationSettings(android: androidSettings, iOS: darwinSettings);

    await _plugin.initialize(initSettings, onDidReceiveNotificationResponse: _onNotificationTap);

    // Request permissions on Android 13+
    await _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();

    appLogger.i('Notification service initialized');
  }

  static void _onNotificationTap(NotificationResponse response) {
    appLogger.i('Notification tapped with payload: ${response.payload}');
    pendingPayload = response.payload;
  }

  Future<void> showWeatherAlert({required String title, required String body, required String payload}) async {
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

    const darwinDetails = DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true);

    const details = NotificationDetails(android: androidDetails, iOS: darwinDetails);

    await _plugin.show(AppConstants.notificationId, title, body, details, payload: payload);

    appLogger.i('Weather alert notification shown: $title');
  }

  Future<void> showTemperatureAlert(double temperature, double threshold) async {
    await showWeatherAlert(title: '🌡️ Temperature Alert', body: 'Temperature exceeded ${threshold.toStringAsFixed(0)}°F! Current: ${temperature.toStringAsFixed(0)}°F', payload: AppConstants.alertPayloadTemp);
  }

  Future<void> showRainAlert({double? rainVolume}) async {
    final rainInfo = rainVolume != null ? ' (${rainVolume.toStringAsFixed(1)}in)' : '';
    await showWeatherAlert(title: '🌧️ Rain Alert', body: 'Rain expected in your area$rainInfo. Don\'t forget your umbrella!', payload: AppConstants.alertPayloadRain);
  }
}
