// weather_state.dart
import 'package:weather_app/model/weather_model.dart';

abstract class WeatherState {}

class WeatherInitial extends WeatherState {}

class WeatherLoading extends WeatherState {}

class WeatherLoaded extends WeatherState {
  final WeatherResponse weather;

  WeatherLoaded({required this.weather});
}

class WeatherError extends WeatherState {
  final String message;

  WeatherError({required this.message});
}
