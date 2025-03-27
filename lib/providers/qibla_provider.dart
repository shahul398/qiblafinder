import 'dart:async';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:qibla_finder_flutter/models/qibla_model.dart';
import 'package:qibla_finder_flutter/providers/location_provider.dart';
import 'package:qibla_finder_flutter/repositories/qibla_repository.dart';
import 'package:vibration/vibration.dart';
import 'package:qibla_finder_flutter/providers/settings_provider.dart';
import 'package:flutter/foundation.dart';

final qiblaRepositoryProvider = Provider<QiblaRepository>((ref) {
  return QiblaRepository();
});

final calibrationProvider = StateProvider<bool>((ref) => false);

class QiblaNotifier extends StateNotifier<QiblaModel> {
  final QiblaRepository _repository;
  final Ref _ref;
  StreamSubscription? _compassSubscription;
  StreamSubscription? _sensorAccuracySubscription;
  Timer? _calibrationTimer;
  bool _hasVibrated = false;

  QiblaNotifier(this._repository, this._ref) : super(QiblaModel.initial()) {
    _initialize();
  }

  void _initialize() {
    _listenToCompass();
    _listenToSensorAccuracy();
    _updateQiblaDirection();

    // Listen for location changes to update qibla direction
    _ref.listen(locationProvider, (previous, next) {
      if (previous?.currentLocation.latitude != next.currentLocation.latitude ||
          previous?.currentLocation.longitude != next.currentLocation.longitude) {
        _updateQiblaDirection();
      }
    });
  }

  void _listenToCompass() {
    _compassSubscription = _repository.getCompassStream().listen((direction) {
      // Ensure direction is within 0-360 range
      final normalizedDirection = (direction + 360) % 360;
      
      state = state.copyWith(currentDirection: normalizedDirection);
      _checkQiblaAlignment();
      
      // Debug information
      debugPrint('Current compass: ${normalizedDirection.toStringAsFixed(1)}° | ' 
                'Qibla: ${state.qiblaDirection.toStringAsFixed(1)}°');
    });
  }

  void _listenToSensorAccuracy() {
    _sensorAccuracySubscription = _repository.getSensorAccuracyStream().listen((accuracy) {
      if (accuracy == SensorAccuracy.unreliable && 
          state.sensorAccuracy != SensorAccuracy.unreliable) {
        final settings = _ref.read(settingsProvider);
        if (settings.autoCalibration) {
          _startCalibration();
        }
      }
      
      state = state.copyWith(sensorAccuracy: accuracy);
    });
  }

  void _updateQiblaDirection() {
    final locationState = _ref.read(locationProvider);
    final qiblaDirection = _repository.calculateQiblaDirection(locationState.currentLocation);
    final distance = _repository.calculateDistanceToKaaba(locationState.currentLocation);
    
    state = state.copyWith(
      qiblaDirection: qiblaDirection,
      distanceToKaaba: distance,
    );
  }

  void _checkQiblaAlignment() async {
    final settings = _ref.read(settingsProvider);
    if (!settings.hapticFeedback) return;
    
    // Calculate the difference between current direction and qibla
    var diff = (state.currentDirection - state.qiblaDirection).abs() % 360;
    if (diff > 180) diff = 360 - diff; // Get the smaller angle
    
    final alignmentAccuracy = diff < 5; // Within 5 degrees
    
    // Vibrate when aligned with Qibla
    if (alignmentAccuracy && !_hasVibrated) {
      _hasVibrated = true;
      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(duration: 200);
      }
      debugPrint('ALIGNED WITH QIBLA! Difference: ${diff.toStringAsFixed(1)}°');
    } else if (!alignmentAccuracy && _hasVibrated) {
      _hasVibrated = false;
    }
  }

  void _startCalibration() {
    _ref.read(calibrationProvider.notifier).state = true;
    
    // Stop calibration after 10 seconds
    _calibrationTimer?.cancel();
    _calibrationTimer = Timer(const Duration(seconds: 10), () {
      _ref.read(calibrationProvider.notifier).state = false;
    });
  }

  void stopCalibration() {
    _calibrationTimer?.cancel();
    _ref.read(calibrationProvider.notifier).state = false;
  }

  @override
  void dispose() {
    _compassSubscription?.cancel();
    _sensorAccuracySubscription?.cancel();
    _calibrationTimer?.cancel();
    super.dispose();
  }
}

final qiblaProvider = StateNotifierProvider<QiblaNotifier, QiblaModel>((ref) {
  final repository = ref.watch(qiblaRepositoryProvider);
  return QiblaNotifier(repository, ref);
});
