import 'package:weather_app/model/location_model.dart';
import 'package:weather_app/utils/dio_weather_client.dart';

class LocationRepository {
  static final DioWeatherClient _client = DioWeatherClient();
  static Future<List<LocationModel>> getLocation({
    required String search,
    required String limit,
  }) async {
    try {
      final resp = await _client.get(
        "/geo/1.0/direct",
        queryParameters: {
          "q": search,
          "limit": limit,
          'appid': "ea5e57629b00206a154c5eeb3dade93e",
        },
      );

      return (resp.data as List)
          .map(((res) => LocationModel.fromJson(res)))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
