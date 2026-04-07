class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://api.openweathermap.org/data/2.5';

  // Replace with your OpenWeatherMap API key
  static const String apiKey = '96c6f35e1bcacd49136cf060a8f892d7';

  static String currentWeather(double lat, double lon) => '$baseUrl/weather?lat=$lat&lon=$lon&appid=$apiKey&units=imperial';

  static String forecast(double lat, double lon) => '$baseUrl/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=imperial';
}
