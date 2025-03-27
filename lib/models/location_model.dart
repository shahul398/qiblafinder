class LocationModel {
  final double latitude;
  final double longitude;
  final String? cityName;
  final String? countryName;
  final double accuracy;

  const LocationModel({
    required this.latitude,
    required this.longitude,
    this.cityName,
    this.countryName,
    this.accuracy = 0.0,
  });

  factory LocationModel.initial() {
    return const LocationModel(
      latitude: 0.0,
      longitude: 0.0,
    );
  }

  LocationModel copyWith({
    double? latitude,
    double? longitude,
    String? cityName,
    String? countryName,
    double? accuracy,
  }) {
    return LocationModel(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      cityName: cityName ?? this.cityName,
      countryName: countryName ?? this.countryName,
      accuracy: accuracy ?? this.accuracy,
    );
  }
} 