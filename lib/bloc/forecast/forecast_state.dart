import 'package:weather_app/model/forecast_model.dart';

abstract class ForecastState {}

class ForecastIntial extends ForecastState {}

class ForecastLoading extends ForecastState {}

class ForecastLoaded extends ForecastState {
  final ForecastResponse data;

  ForecastLoaded(this.data);
}
