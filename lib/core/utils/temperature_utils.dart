class TemperatureUtils {
  TemperatureUtils._();

  static double fahrenheitToCelsius(double f) => (f - 32) * 5 / 9;
  static double celsiusToFahrenheit(double c) => c * 9 / 5 + 32;

  static String formatTemp(double fahrenheitValue, bool isCelsius) {
    if (isCelsius) {
      return fahrenheitToCelsius(fahrenheitValue).toStringAsFixed(0);
    }
    return fahrenheitValue.toStringAsFixed(0);
  }

  static String unitLabel(bool isCelsius) => isCelsius ? 'C' : 'F';

  static String formatTempWithUnit(double fahrenheitValue, bool isCelsius) {
    return '${formatTemp(fahrenheitValue, isCelsius)}°${unitLabel(isCelsius)}';
  }
}
