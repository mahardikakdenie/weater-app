import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_app/bloc/forecast/forecast_event.dart';
import 'package:weather_app/bloc/forecast/forecast_state.dart';
import 'package:weather_app/services/weather_service.dart';

class ForecastBloc extends Bloc<ForecastEvent, ForecastState> {
  ForecastBloc() : super(ForecastIntial()) {
    on<SetForecastData>(_featchForecast);
  }

  Future<void> _featchForecast(
    SetForecastData event,
    Emitter<ForecastState> emit,
  ) async {
    emit(ForecastLoading());
    try {
      var resp = await WeatherService.fetchForecastData(
        lat: event.lat.toString(),
        lon: event.lat.toString(),
        apiKey: event.apiKey,
      );

      emit(ForecastLoaded(resp));
    } catch (e) {
      rethrow;
    }
  }
}
