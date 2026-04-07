import '../../data/models/weather_model.dart';
import '../../data/models/forecast_model.dart';

abstract class WeatherRepository {
  Future<WeatherModel> getCurrentWeather(double lat, double lon);
  Future<ForecastModel> getForecast(double lat, double lon);
  Future<WeatherModel?> getCachedWeather();
  Future<ForecastModel?> getCachedForecast();
  Future<DateTime?> getLastUpdated();
}
