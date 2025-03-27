import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:qibla_finder_flutter/models/location_model.dart';
import 'package:qibla_finder_flutter/repositories/location_repository.dart';

class LocationState {
  final LocationModel currentLocation;
  final bool isLoading;
  final String? errorMessage;
  final double accuracy;

  LocationState({
    required this.currentLocation,
    this.isLoading = false,
    this.errorMessage,
    this.accuracy = 0.0,
  });

  LocationState copyWith({
    LocationModel? currentLocation,
    bool? isLoading,
    String? errorMessage,
    double? accuracy,
  }) {
    return LocationState(
      currentLocation: currentLocation ?? this.currentLocation,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      accuracy: accuracy ?? this.accuracy,
    );
  }
}

class LocationNotifier extends StateNotifier<LocationState> {
  final LocationRepository _repository;
  
  LocationNotifier(this._repository) : super(LocationState(
    currentLocation: LocationModel.initial(),
    isLoading: true,
  )) {
    _initialize();
  }

  void _initialize() async {
    await refreshLocation();
    _listenToLocationUpdates();
  }

  Future<void> refreshLocation() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      final location = await _repository.getCurrentLocation();
      
      if (location != null) {
        state = state.copyWith(
          currentLocation: location,
          isLoading: false,
          accuracy: location.accuracy,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Could not get location. Please check permissions.',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error: ${e.toString()}',
      );
    }
  }

  void _listenToLocationUpdates() {
    _repository.getLocationStream().listen((location) {
      state = state.copyWith(
        currentLocation: location,
        accuracy: location.accuracy,
      );
    }, onError: (error) {
      state = state.copyWith(
        errorMessage: 'Location update error: ${error.toString()}',
      );
    });
  }
}

final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  return LocationRepository();
});

final locationProvider = StateNotifierProvider<LocationNotifier, LocationState>((ref) {
  final repository = ref.watch(locationRepositoryProvider);
  return LocationNotifier(repository);
}); 