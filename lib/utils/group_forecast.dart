// lib/utils/group_forecast.dart
import 'package:weather_app/model/forecast_model.dart';
import 'dart:math' as math;

List<ForecastDayGroup> groupForecastByDay(List<ForecastListItem> items) {
  if (items.isEmpty) return [];

  Map<String, List<ForecastListItem>> grouped = {};
  for (var item in items) {
    final date = DateTime.fromMillisecondsSinceEpoch(
      item.dt * 1000,
    ).toIso8601String().split('T')[0];

    grouped.putIfAbsent(date, () => []).add(item);
  }

  return grouped.entries
      .map((e) => ForecastDayGroup(date: e.key, items: e.value))
      .toList()
      .sublist(0, 5);
}

class ForecastDayGroup {
  final String date;
  final List<ForecastListItem> items;

  ForecastDayGroup({required this.date, required this.items});

  // Ambil suhu rata-rata atau min/max
  double get minTemp => items.map((i) => i.main.tempMin).reduce(math.min);
  double get maxTemp => items.map((i) => i.main.tempMax).reduce(math.max);
  String get mainCondition =>
      items.isNotEmpty ? items[0].weather[0].main : 'Clear';
}
