import 'dart:convert';
// untuk debugPrint

class LocationModel {
  String? name;
  Map<String, String>? localNames; // ✅ Diperbaiki: bukan List!
  double? lat;
  double? lon;
  String? country;
  String? state;

  LocationModel({
    this.name,
    this.localNames,
    this.lat,
    this.lon,
    this.country,
    this.state,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      name: json['name'],
      // Konversi local_names dengan aman
      localNames: json['local_names'] != null
          ? (json['local_names'] as Map<String, dynamic>).map(
              (key, value) => MapEntry(key, value.toString()),
            )
          : null,
      // Gunakan double untuk lat/lon karena API kirim number (bukan string)
      lat: json['lat'] is num ? (json['lat'] as num).toDouble() : null,
      lon: json['lon'] is num ? (json['lon'] as num).toDouble() : null,
      country: json['country'] ?? '',
      state: json['state'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "local_names": localNames,
      "lat": lat,
      "lon": lon,
      "country": country,
      "state": state,
    };
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}
