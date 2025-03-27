import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:qibla_finder_flutter/models/location_model.dart';
import 'package:geocoding/geocoding.dart';

class LocationRepository {
  Future<bool> requestLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  Future<LocationModel?> getCurrentLocation() async {
    try {
      final hasPermission = await requestLocationPermission();
      if (!hasPermission) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Get place information using reverse geocoding
      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude, 
          position.longitude
        );
        
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          return LocationModel(
            latitude: position.latitude,
            longitude: position.longitude,
            cityName: place.locality ?? place.subAdministrativeArea,
            countryName: place.country,
            accuracy: position.accuracy,
          );
        }
      } catch (e) {
        debugPrint('Error getting placemark: $e');
      }
      
      // Return with just coordinates if geocoding fails
      return LocationModel(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
      );
    } catch (e) {
      debugPrint('Error getting location: $e');
      return null;
    }
  }

  Stream<LocationModel> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).asyncMap((position) async {
      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude, 
          position.longitude
        );
        
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          return LocationModel(
            latitude: position.latitude,
            longitude: position.longitude,
            cityName: place.locality ?? place.subAdministrativeArea,
            countryName: place.country,
            accuracy: position.accuracy,
          );
        }
      } catch (e) {
        debugPrint('Error getting placemark in stream: $e');
      }
      
      return LocationModel(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
      );
    });
  }
} 