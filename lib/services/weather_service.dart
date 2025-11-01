import 'package:weather_app/model/forecast_model.dart';
import 'package:weather_app/model/weather_model.dart';
import 'package:weather_app/repository/weather_repository.dart';

class WeatherService {
  static Future<WeatherResponse> fetchWeatherData({
    required String lat,
    required String lon,
    required String apiKey,
  }) async {
    return await WeatherRepository.getCurrentWeather(
      lat: lat,
      lon: lon,
      apiKey: apiKey,
    );
  }

  static Future<ForecastResponse> fetchForecastData({
    required String lat,
    required String lon,
    required String apiKey,
  }) async {
    return await WeatherRepository.getForecastWeather(
      lat: lat,
      lon: lon,
      apiKey: apiKey,
    );
  }
}
