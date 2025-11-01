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
