import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

Future<void> getCurrentLocation() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    debugPrint('your service location is not active.');
    return;
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      debugPrint('location permission denied.');
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
      debugPrint('error fetched location: $e');
    }
  }
}
