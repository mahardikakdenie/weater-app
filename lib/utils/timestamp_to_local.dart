// import 'package:intl/intl.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/model/forecast_model.dart';

String formatTimestampToLocal(
  int? timestamp,
  int? timezoneOffset, {
  String formatDate = 'dd MMMM yyyy, HH.mm',
}) {
  if (timestamp == null) return '–';
  final utc = DateTime.fromMillisecondsSinceEpoch(
    timestamp * 1000,
    isUtc: true,
  );
  final local = utc.add(Duration(seconds: timezoneOffset ?? 25200));
  return DateFormat(formatDate, 'id_ID').format(local);
}

List<ForecastListItem> filterTodayWeather(List<ForecastListItem> forecastList) {
  final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

  final filtered = forecastList.where((item) {
    final itemDate = item.dtTxt.split(' ')[0];
    return itemDate == today;
  }).toList();

  return filtered;
}

List<ForecastListItem> filterTomorrowWeather(ForecastResponse response) {
  final items = response.list ?? [];
  if (items.isEmpty) return [];

  final now = DateTime.now();
  final tomorrow = DateTime(now.year, now.month, now.day + 1);

  return items.where((item) {
    final itemDate = DateTime.fromMillisecondsSinceEpoch(item.dt * 1000);
    return itemDate.day == tomorrow.day &&
        itemDate.month == tomorrow.month &&
        itemDate.year == tomorrow.year;
  }).toList();
}

String getWeatherIconFromMain(String main) {
  switch (main) {
    case 'Clear':
      return '☀️';
    case 'Clouds':
      return '☁️';
    case 'Rain':
    case 'Drizzle':
      return '🌧️';
    case 'Thunderstorm':
      return '⛈️';
    case 'Snow':
      return '🌨️';
    case 'Mist':
    case 'Fog':
    case 'Haze':
    case 'Smoke':
      return '🌫️';
    default:
      return '❓';
  }
}

extension StringExtension on String {
  String capitalize() {
    return isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
  }
}
