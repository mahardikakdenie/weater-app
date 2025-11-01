// lib/model/forecast_model.dart

import 'dart:convert';

class ForecastResponse {
  final String? cod;
  final int? message;
  final int? cnt;
  final List<ForecastListItem>? list;
  final City? city;

  ForecastResponse({this.cod, this.message, this.cnt, this.list, this.city});

  factory ForecastResponse.fromJson(Map<String, dynamic> json) {
    return ForecastResponse(
      cod: json['cod'],
      message: json['message'],
      cnt: json['cnt'],
      list: json['list'] != null
          ? (json['list'] as List)
                .map((e) => ForecastListItem.fromJson(e))
                .toList()
          : [],
      city: City.fromJson(json['city']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'cod': cod, "message": message, "cnt": cnt, "list": list};
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}

class ForecastListItem {
  final int dt;
  final Main main;
  final List<Weather> weather;
  final Clouds clouds;
  final Wind wind;
  final int visibility;
  final double pop;
  final Rain? rain;
  final Sys sys;
  final String dtTxt;

  ForecastListItem({
    required this.dt,
    required this.main,
    required this.weather,
    required this.clouds,
    required this.wind,
    required this.visibility,
    required this.pop,
    this.rain,
    required this.sys,
    required this.dtTxt,
  });

  factory ForecastListItem.fromJson(Map<String, dynamic> json) {
    return ForecastListItem(
      dt: json['dt'],
      main: Main.fromJson(json['main']),
      weather: (json['weather'] as List)
          .map((e) => Weather.fromJson(e))
          .toList(),
      clouds: Clouds.fromJson(json['clouds']),
      wind: Wind.fromJson(json['wind']),
      visibility: json['visibility'],
      pop: json['pop'].toDouble(),
      rain: json['rain'] != null ? Rain.fromJson(json['rain']) : null,
      sys: Sys.fromJson(json['sys']),
      dtTxt: json['dt_txt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dt': dt,
      'main': main.toJson(), // ✅
      'weather': weather.map((w) => w.toJson()).toList(), // ✅
      'clouds': clouds.toJson(), // ✅
      'wind': wind.toJson(), // ✅
      'visibility': visibility,
      'pop': pop,
      'rain': rain?.toJson(), // ✅ (nullable)
      'sys': sys.toJson(), // ✅
      'dt_txt': dtTxt,
    };
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}

class Main {
  final double temp;
  final double feelsLike;
  final double tempMin;
  final double tempMax;
  final int pressure;
  final int seaLevel;
  final int grndLevel;
  final int humidity;
  final double tempKf;

  Main({
    required this.temp,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.pressure,
    required this.seaLevel,
    required this.grndLevel,
    required this.humidity,
    required this.tempKf,
  });

  factory Main.fromJson(Map<String, dynamic> json) {
    return Main(
      temp: json['temp'].toDouble(),
      feelsLike: json['feels_like'].toDouble(),
      tempMin: json['temp_min'].toDouble(),
      tempMax: json['temp_max'].toDouble(),
      pressure: json['pressure'],
      seaLevel: json['sea_level'],
      grndLevel: json['grnd_level'],
      humidity: json['humidity'],
      tempKf: json['temp_kf'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temp': temp,
      'feels_like': feelsLike,
      'temp_min': tempMin,
      'temp_max': tempMax,
      'pressure': pressure,
      'sea_level': seaLevel,
      'grnd_level': grndLevel,
      'humidity': humidity,
      'temp_kf': tempKf,
    };
  }
}

class Weather {
  final int id;
  final String main;
  final String description;
  final String icon;

  Weather({
    required this.id,
    required this.main,
    required this.description,
    required this.icon,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      id: json['id'],
      main: json['main'],
      description: json['description'],
      icon: json['icon'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'main': main, 'description': description, 'icon': icon};
  }
}

class Clouds {
  final int all;

  Clouds({required this.all});

  factory Clouds.fromJson(Map<String, dynamic> json) {
    return Clouds(all: json['all']);
  }

  Map<String, dynamic> toJson() {
    return {'all': all};
  }
}

class Wind {
  final double speed;
  final int deg;
  final double? gust;

  Wind({required this.speed, required this.deg, this.gust});

  factory Wind.fromJson(Map<String, dynamic> json) {
    return Wind(
      speed: json['speed'].toDouble(),
      deg: json['deg'],
      gust: json['gust']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'speed': speed, 'deg': deg, 'gust': gust};
  }
}

class Rain {
  final double? threeHour; // '3h' is not valid Dart identifier

  Rain({this.threeHour});

  factory Rain.fromJson(Map<String, dynamic> json) {
    // Handle key "3h"
    final threeH = json['3h'];
    return Rain(threeHour: threeH?.toDouble());
  }

  Map<String, dynamic> toJson() {
    return {'3h': threeHour}; // Sesuai format API
  }
}

class Sys {
  final String pod; // 'd' = day, 'n' = night

  Sys({required this.pod});

  factory Sys.fromJson(Map<String, dynamic> json) {
    return Sys(pod: json['pod']);
  }

  Map<String, dynamic> toJson() {
    return {'pod': pod};
  }
}

class City {
  final int id;
  final String name;
  final Coord coord;
  final String country;
  final int population;
  final int timezone;
  final int sunrise;
  final int sunset;

  City({
    required this.id,
    required this.name,
    required this.coord,
    required this.country,
    required this.population,
    required this.timezone,
    required this.sunrise,
    required this.sunset,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'],
      name: json['name'],
      coord: Coord.fromJson(json['coord']),
      country: json['country'],
      population: json['population'],
      timezone: json['timezone'],
      sunrise: json['sunrise'],
      sunset: json['sunset'],
    );
  }
}

class Coord {
  final double lat;
  final double lon;

  Coord({required this.lat, required this.lon});

  factory Coord.fromJson(Map<String, dynamic> json) {
    return Coord(lat: json['lat'].toDouble(), lon: json['lon'].toDouble());
  }
}
