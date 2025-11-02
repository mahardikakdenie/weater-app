import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

Future<void> getCurrentLocation() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    debugPrint('Layanan lokasi tidak aktif.');
    return;
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      debugPrint('Izin lokasi ditolak.');
      return;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return;
  }

  if (permission == LocationPermission.whileInUse ||
      permission == LocationPermission.always) {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      debugPrint('Latitude: ${position.latitude}');
      debugPrint('Longitude: ${position.longitude}');
    } catch (e) {
      debugPrint('Error mendapatkan lokasi: $e');
    }
  }
}
