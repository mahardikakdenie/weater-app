// lib/models/favorite_city.dart
import 'dart:convert';

class FavoriteCity {
  final String id;
  final String name;
  final double lat;
  final double lon;

  FavoriteCity({
    required this.id,
    required this.name,
    required this.lat,
    required this.lon,
  });

  // Konversi dari Map (Firestore)
  factory FavoriteCity.fromMap(String docId, Map<String, dynamic> data) {
    return FavoriteCity(
      id: docId,
      name: data['name'] ?? 'Unknown',
      lat: (data['lat'] as num?)?.toDouble() ?? 0.0,
      lon: (data['lon'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {"id": id, "name": name, "lat": lat, "lon": lon};
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}
