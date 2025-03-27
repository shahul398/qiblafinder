import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:qibla_finder_flutter/providers/location_provider.dart';
import 'package:qibla_finder_flutter/providers/qibla_provider.dart';
import 'package:qibla_finder_flutter/widgets/compass_view.dart';
import 'package:qibla_finder_flutter/widgets/location_card.dart';
import 'package:qibla_finder_flutter/widgets/status_indicator.dart';
import 'package:qibla_finder_flutter/widgets/calibration_overlay.dart';
import 'package:qibla_finder_flutter/screens/settings_screen.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationState = ref.watch(locationProvider);
    final qiblaState = ref.watch(qiblaProvider);
    final isCalibrating = ref.watch(calibrationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Qibla Finder'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (_) => const SettingsScreen())
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: () => ref.read(locationProvider.notifier).refreshLocation(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.all(16.0.r),
                  child: Column(
                    children: [
                      SizedBox(height: 8.h),
                      LocationCard(
                        location: locationState.currentLocation,
                        distance: qiblaState.distanceToKaaba,
                        isLoading: locationState.isLoading,
                      ),
                      SizedBox(height: 16.h),
                      CompassView(
                        qiblaDirection: qiblaState.qiblaDirection,
                        currentDirection: qiblaState.currentDirection,
                        accuracy: qiblaState.sensorAccuracy,
                      ),
                      SizedBox(height: 16.h),
                      StatusIndicator(
                        locationAccuracy: locationState.accuracy,
                        compassAccuracy: qiblaState.sensorAccuracy,
                      ),
                      SizedBox(height: 8.h),
                    ],
                  ),
                ),
              ),
            ),
            
            // Calibration overlay when needed
            if (isCalibrating) const CalibrationOverlay(),
          ],
        ),
      ),
    );
  }
}
