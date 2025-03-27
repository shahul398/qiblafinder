import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:qibla_finder_flutter/models/location_model.dart';
import 'package:qibla_finder_flutter/models/qibla_model.dart';
import 'package:sensors_plus/sensors_plus.dart';

class QiblaRepository {
  // Mecca coordinates
  final double kaabaLatitude = 21.4225;
  final double kaabaLongitude = 39.8262;
  
  Stream<double> getCompassStream() {
    return FlutterCompass.events?.map((event) => event.heading ?? 0.0) ?? 
      Stream.value(0.0);
  }
  
  Stream<SensorAccuracy> getSensorAccuracyStream() {
    return accelerometerEvents.map((event) {
      final magnitude = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
      
      if (magnitude > 9.7 && magnitude < 10.3) {
        return SensorAccuracy.high;
      } else if (magnitude > 9.5 && magnitude < 10.5) {
        return SensorAccuracy.medium;
      } else if (magnitude > 9.0 && magnitude < 11.0) {
        return SensorAccuracy.low;
      } else {
        return SensorAccuracy.unreliable;
      }
    });
  }

  double calculateQiblaDirection(LocationModel location) {
    try {
      if (location.latitude == 0 && location.longitude == 0) {
        return 0.0; // Return default if location is not valid
      }
      
      // Convert to radians
      final lat1 = location.latitude * pi / 180;
      final lon1 = location.longitude * pi / 180;
      final lat2 = kaabaLatitude * pi / 180;
      final lon2 = kaabaLongitude * pi / 180;
      
      // Formula for qibla direction
      final y = sin(lon2 - lon1);
      final x = cos(lat1) * tan(lat2) - sin(lat1) * cos(lon2 - lon1);
      
      // Calculate qibla direction in radians
      var qiblaRad = atan2(y, x);
      
      // Convert to degrees and normalize to 0-360
      var qiblaDeg = qiblaRad * 180 / pi;
      qiblaDeg = (qiblaDeg + 360) % 360;
      
      debugPrint('Qibla direction for ${location.latitude},${location.longitude}: $qiblaDeg°');
      
      return qiblaDeg;
    } catch (e) {
      debugPrint('Error calculating qibla direction: $e');
      return 0.0;
    }
  }
  
  double calculateDistanceToKaaba(LocationModel location) {
    try {
      const earthRadius = 6371.0; // Earth radius in kilometers
      
      // Convert to radians
      final lat1 = location.latitude * pi / 180;
      final lon1 = location.longitude * pi / 180;
      final lat2 = kaabaLatitude * pi / 180;
      final lon2 = kaabaLongitude * pi / 180;
      
      // Haversine formula
      final dLat = lat2 - lat1;
      final dLon = lon2 - lon1;
      
      final a = sin(dLat / 2) * sin(dLat / 2) +
                cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
      final c = 2 * atan2(sqrt(a), sqrt(1 - a));
      
      // Distance in kilometers
      return earthRadius * c;
    } catch (e) {
      debugPrint('Error calculating distance to Kaaba: $e');
      return 0.0;
    }
  }
} 