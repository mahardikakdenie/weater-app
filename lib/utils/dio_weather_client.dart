import 'dart:developer';
import 'package:dio/dio.dart';

class DioWeatherClient {
  static final DioWeatherClient _instance = DioWeatherClient._internal();
  factory DioWeatherClient() => _instance;
  late Dio _dio;

  DioWeatherClient._internal() {
    _dio = Dio()
      ..options.baseUrl = 'https://api.openweathermap.org/'
      ..options.followRedirects = false
      ..options.validateStatus = (status) => status != null && status < 500;
  }

  Future<Response> _request(
    String method,
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.request(
        path,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
        options: Options(method: method),
      );

      if (response.statusCode == 404) {
        log('@res: 404 Not found');
      } else {
        log('@res: ${response.data}');
      }

      return response;
    } catch (e) {
      log('Dio request error: $e');
      final message = e is DioException ? e.message : 'Koneksi terputus';
      return Response(
        requestOptions: RequestOptions(path: path),
        data: {'status': 999, 'message': message},
        statusCode: 999,
        statusMessage: message,
      );
    }
  }

  // Public methods
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) => _request(
    'GET',
    path,
    queryParameters: queryParameters,
    cancelToken: cancelToken,
  );

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) => _request(
    'POST',
    path,
    data: data,
    queryParameters: queryParameters,
    cancelToken: cancelToken,
  );

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) => _request(
    'PUT',
    path,
    data: data,
    queryParameters: queryParameters,
    cancelToken: cancelToken,
  );

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) => _request(
    'DELETE',
    path,
    data: data,
    queryParameters: queryParameters,
    cancelToken: cancelToken,
  );
}
