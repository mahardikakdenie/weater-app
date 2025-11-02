// weather_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_app/bloc/weather/weather_event.dart';
import 'package:weather_app/bloc/weather/weather_state.dart';
import 'package:weather_app/model/weather_model.dart';
import 'package:weather_app/services/weather_service.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  WeatherBloc() : super(WeatherInitial()) {
    on<SetWeatherData>(_onSetWeatherData);
  }

  Future<void> _onSetWeatherData(
    SetWeatherData event,
    Emitter<WeatherState> emit,
  ) async {
    emit(WeatherLoading());

    try {
      final WeatherResponse weather = await WeatherService.fetchWeatherData(
        lat: event.lat.toString(),
        lon: event.lon.toString(),
        apiKey: event.apiKey,
      );
      emit(WeatherLoaded(weather: weather));
    } catch (e) {
      emit(WeatherError(message: e.toString()));
    }
  }
}
