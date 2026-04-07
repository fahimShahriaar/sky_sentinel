import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';
import 'core/utils/logger.dart';
import 'features/background/background_worker.dart';
import 'injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.light, systemNavigationBarColor: Color(0xFF0A0E21), systemNavigationBarIconBrightness: Brightness.light));

  // Initialize dependencies
  await initDependencies();
  appLogger.i('Dependencies initialized');

  // Initialize background worker
  await BackgroundWorker.initialize();
  await BackgroundWorker.registerPeriodicTask();
  appLogger.i('Background worker registered');

  runApp(const SkySentinelApp());
}
