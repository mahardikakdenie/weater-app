abstract class ForecastEvent {}

class SetForecastData extends ForecastEvent {
  final double lat;
  final double lon;
  final String apiKey;

  SetForecastData(this.lat, this.lon, this.apiKey);
}
