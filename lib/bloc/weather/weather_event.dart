abstract class WeatherEvent {}

class SetWeatherData extends WeatherEvent {
  final double lat;
  final double lon;
  final String apiKey;

  SetWeatherData({required this.lat, required this.lon, required this.apiKey});
}
