import 'package:flutter/foundation.dart'; // untuk debugPrint
import 'package:weather_app/model/forecast_model.dart';
import 'package:weather_app/model/weather_model.dart';
import 'package:weather_app/utils/dio_weather_client.dart';

class WeatherRepository {
  static final DioWeatherClient _client = DioWeatherClient();

  static Future<WeatherResponse> getCurrentWeather({
    required String lat,
    required String lon,
    required String apiKey,
  }) async {
    try {
      debugPrint("Fetching weather data...");
      final response = await _client.get(
        'data/2.5/weather',
        queryParameters: {
          'lat': lat,
          'lon': lon,
          'appid': apiKey,
          'units': 'metric',
        },
      );

      // Pastikan response.data adalah Map<String, dynamic>
      final weatherResponse = WeatherResponse.fromJson(response.data);
      return weatherResponse;
    } catch (e) {
      debugPrint("Error in WeatherRepository: $e");
      rethrow;
    }
  }

  static Future<ForecastResponse> getForecastWeather({
    required String lat,
    required String lon,
    required String apiKey,
  }) async {
    try {
      debugPrint("Fetching weather data...");
      final response = await _client.get(
        '/data/2.5/forecast',
        queryParameters: {
          'lat': lat,
          'lon': lon,
          'appid': apiKey,
          'units': 'metric',
        },
      );

      // Pastikan response.data adalah Map<String, dynamic>
      final foreCastResp = ForecastResponse.fromJson(response.data);
      return foreCastResp;
    } catch (e) {
      debugPrint("Error in WeatherRepository: $e");
      rethrow;
    }
  }
}
