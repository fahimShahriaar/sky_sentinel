class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://api.openweathermap.org/data/2.5';

  // Provided at build time via: --dart-define=OWM_API_KEY=your_key
  static const String apiKey = String.fromEnvironment('OWM_API_KEY');

  static String currentWeather(double lat, double lon) => '$baseUrl/weather?lat=$lat&lon=$lon&appid=$apiKey&units=imperial';

  static String forecast(double lat, double lon) => '$baseUrl/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=imperial';

  static String airPollution(double lat, double lon) => '$baseUrl/air_pollution?lat=$lat&lon=$lon&appid=$apiKey';
}
