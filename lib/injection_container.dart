import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/location/data/datasources/location_datasource.dart';
import 'features/location/data/repositories/location_repository_impl.dart';
import 'features/location/domain/repositories/location_repository.dart';
import 'features/location/presentation/bloc/location_bloc.dart';
import 'features/notifications/notification_service.dart';
import 'features/settings/data/datasources/settings_local_datasource.dart';
import 'features/settings/data/repositories/settings_repository_impl.dart';
import 'features/settings/domain/repositories/settings_repository.dart';
import 'features/settings/presentation/bloc/settings_bloc.dart';
import 'features/weather/data/datasources/weather_local_datasource.dart';
import 'features/weather/data/datasources/weather_remote_datasource.dart';
import 'features/weather/data/repositories/weather_repository_impl.dart';
import 'features/weather/domain/repositories/weather_repository.dart';
import 'features/weather/presentation/bloc/weather_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // External
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => prefs);
  sl.registerLazySingleton<Dio>(() => Dio());

  // Notification Service
  final notificationService = NotificationService();
  await notificationService.initialize();
  sl.registerLazySingleton<NotificationService>(() => notificationService);

  // Data Sources
  sl.registerLazySingleton<WeatherRemoteDataSource>(() => WeatherRemoteDataSourceImpl(dio: sl()));
  sl.registerLazySingleton<WeatherLocalDataSource>(() => WeatherLocalDataSourceImpl(prefs: sl()));
  sl.registerLazySingleton<LocationDataSource>(() => LocationDataSourceImpl());
  sl.registerLazySingleton<SettingsLocalDataSource>(() => SettingsLocalDataSourceImpl(prefs: sl()));

  // Repositories
  sl.registerLazySingleton<WeatherRepository>(() => WeatherRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()));
  sl.registerLazySingleton<LocationRepository>(() => LocationRepositoryImpl(dataSource: sl()));
  sl.registerLazySingleton<SettingsRepository>(() => SettingsRepositoryImpl(localDataSource: sl()));

  // BLoCs
  sl.registerFactory<WeatherBloc>(() => WeatherBloc(repository: sl()));
  sl.registerFactory<LocationBloc>(() => LocationBloc(repository: sl()));
  sl.registerFactory<SettingsBloc>(() => SettingsBloc(repository: sl()));
}
