enum SensorAccuracy { low, medium, high, unreliable }

class QiblaModel {
  final double qiblaDirection;
  final double currentDirection;
  final double distanceToKaaba;
  final SensorAccuracy sensorAccuracy;

  const QiblaModel({
    required this.qiblaDirection,
    required this.currentDirection,
    required this.distanceToKaaba,
    this.sensorAccuracy = SensorAccuracy.unreliable,
  });

  factory QiblaModel.initial() {
    return const QiblaModel(
      qiblaDirection: 0.0,
      currentDirection: 0.0,
      distanceToKaaba: 0.0,
      sensorAccuracy: SensorAccuracy.unreliable,
    );
  }

  QiblaModel copyWith({
    double? qiblaDirection,
    double? currentDirection,
    double? distanceToKaaba,
    SensorAccuracy? sensorAccuracy,
  }) {
    return QiblaModel(
      qiblaDirection: qiblaDirection ?? this.qiblaDirection,
      currentDirection: currentDirection ?? this.currentDirection,
      distanceToKaaba: distanceToKaaba ?? this.distanceToKaaba,
      sensorAccuracy: sensorAccuracy ?? this.sensorAccuracy,
    );
  }
} 