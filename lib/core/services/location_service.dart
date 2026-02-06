import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;

/// Result from [LocationService.currentCityAndTemp].
class LocationInfo {
  const LocationInfo({required this.city, required this.tempC});
  final String city;
  final double tempC;
}

/// Lightweight location + weather helper.
///
/// *Uses the free Open-Meteo API; no key required.*
class LocationService {
  /// Gets current city name and ambient temperature in °C.
  ///
  /// Throws if location permission is missing.
  Future<LocationInfo> currentCityAndTemp() async {
    // 1 ─ position
    final pos = await Geolocator.getCurrentPosition();

    // 2 ─ city via reverse-geocoding
    final placemarks =
    await placemarkFromCoordinates(pos.latitude, pos.longitude);
    final city = placemarks.first.locality ?? placemarks.first.subAdministrativeArea ?? 'Unknown';

    // 3 ─ temp via Open-Meteo
    final uri = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=${pos.latitude}'
            '&longitude=${pos.longitude}&current_weather=true');
    final res = await http.get(uri);
    final temp = jsonDecode(res.body)['current_weather']['temperature'] as num;

    return LocationInfo(city: city, tempC: temp.toDouble());
  }
}
