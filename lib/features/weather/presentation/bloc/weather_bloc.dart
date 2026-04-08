import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/repositories/weather_repository.dart';
import 'weather_event.dart';
import 'weather_state.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final WeatherRepository repository;

  WeatherBloc({required this.repository}) : super(const WeatherInitial()) {
    on<FetchCurrentWeather>(_onFetchCurrentWeather);
    on<FetchForecast>(_onFetchForecast);
    on<FetchAllWeatherData>(_onFetchAllWeatherData);
    on<LoadCachedWeather>(_onLoadCachedWeather);
    on<ClearAlertHighlight>(_onClearAlertHighlight);
    on<SetAlertHighlight>(_onSetAlertHighlight);
  }

  Future<void> _onFetchCurrentWeather(FetchCurrentWeather event, Emitter<WeatherState> emit) async {
    final currentState = state;
    emit(WeatherLoading(previousWeather: currentState is WeatherLoaded ? currentState.weather : null, previousForecast: currentState is WeatherLoaded ? currentState.forecast : null));

    try {
      final weather = await repository.getCurrentWeather(event.latitude, event.longitude);
      final lastUpdated = await repository.getLastUpdated();

      if (currentState is WeatherLoaded) {
        emit(currentState.copyWith(weather: weather, lastUpdated: lastUpdated));
      } else {
        emit(WeatherLoaded(weather: weather, lastUpdated: lastUpdated));
      }
    } on CacheException catch (e) {
      emit(WeatherError(message: e.message));
    } on ServerException catch (e) {
      final cached = await repository.getCachedWeather();
      emit(WeatherError(message: e.message, cachedWeather: cached));
    } catch (e) {
      appLogger.e('Unexpected error fetching weather: $e');
      emit(WeatherError(message: 'An unexpected error occurred: $e'));
    }
  }

  Future<void> _onFetchForecast(FetchForecast event, Emitter<WeatherState> emit) async {
    try {
      final forecast = await repository.getForecast(event.latitude, event.longitude);

      final currentState = state;
      if (currentState is WeatherLoaded) {
        emit(currentState.copyWith(forecast: forecast));
      }
    } catch (e) {
      appLogger.e('Error fetching forecast: $e');
    }
  }

  Future<void> _onFetchAllWeatherData(FetchAllWeatherData event, Emitter<WeatherState> emit) async {
    final currentState = state;
    emit(WeatherLoading(previousWeather: currentState is WeatherLoaded ? currentState.weather : null, previousForecast: currentState is WeatherLoaded ? currentState.forecast : null));

    try {
      final results = await Future.wait([
        repository.getCurrentWeather(event.latitude, event.longitude),
        repository.getForecast(event.latitude, event.longitude),
      ]);

      final weather = results[0];
      final forecast = results[1];
      final lastUpdated = await repository.getLastUpdated();
      final alertHighlight = currentState is WeatherLoaded ? currentState.alertHighlight : null;

      // Fetch air quality separately so it doesn't block/fail the main data
      dynamic airQuality;
      try {
        airQuality = await repository.getAirQuality(event.latitude, event.longitude);
      } catch (e) {
        appLogger.w('Air quality fetch failed (non-critical): $e');
      }

      emit(WeatherLoaded(weather: weather as dynamic, forecast: forecast as dynamic, airQuality: airQuality, lastUpdated: lastUpdated, alertHighlight: alertHighlight));
    } on CacheException catch (e) {
      emit(WeatherError(message: e.message));
    } on ServerException catch (e) {
      final cachedWeather = await repository.getCachedWeather();
      final cachedForecast = await repository.getCachedForecast();
      emit(WeatherError(message: e.message, cachedWeather: cachedWeather, cachedForecast: cachedForecast));
    } catch (e) {
      appLogger.e('Unexpected error: $e');
      final cachedWeather = await repository.getCachedWeather();
      final cachedForecast = await repository.getCachedForecast();
      if (cachedWeather != null) {
        emit(WeatherLoaded(weather: cachedWeather, forecast: cachedForecast));
      } else {
        emit(WeatherError(message: 'Failed to load weather data: $e'));
      }
    }
  }

  Future<void> _onLoadCachedWeather(LoadCachedWeather event, Emitter<WeatherState> emit) async {
    final cachedWeather = await repository.getCachedWeather();
    final cachedForecast = await repository.getCachedForecast();
    final lastUpdated = await repository.getLastUpdated();

    if (cachedWeather != null) {
      emit(WeatherLoaded(weather: cachedWeather, forecast: cachedForecast, lastUpdated: lastUpdated));
    }
  }

  void _onClearAlertHighlight(ClearAlertHighlight event, Emitter<WeatherState> emit) {
    final currentState = state;
    if (currentState is WeatherLoaded) {
      emit(currentState.copyWith(clearAlert: true));
    }
  }

  void _onSetAlertHighlight(SetAlertHighlight event, Emitter<WeatherState> emit) {
    final currentState = state;
    if (currentState is WeatherLoaded) {
      emit(currentState.copyWith(alertHighlight: event.alertType));
    }
  }
}
