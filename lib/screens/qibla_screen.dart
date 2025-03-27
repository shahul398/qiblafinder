import 'package:qibla_finder_flutter/widgets/location_card.dart';
import 'package:qibla_finder_flutter/widgets/status_indicators.dart';
import 'package:qibla_finder_flutter/utils/app_colors.dart';

@override
Widget build(BuildContext context, WidgetRef ref) {
  return Scaffold(
    backgroundColor: AppColors.background,
    body: SafeArea(
      child: Column(
        children: [
          SizedBox(height: 16.h),
          
          // Status indicators
          StatusIndicators(
            hasLocation: locationState.hasLocation,
            hasCompass: compassState.hasCompass,
          ),
          
          // Location card
          if (locationState.hasLocation)
            LocationCard(
              location: locationState.addressName ?? "Unknown Location",
              latitude: locationState.latitude,
              longitude: locationState.longitude,
              distanceToKaaba: locationState.distanceToKaaba,
            ),
            
          // Compass view
          if (locationState.hasLocation && compassState.hasCompass)
            CompassView(
              qiblaDirection: qiblaState.qiblaDirection,
              currentDirection: compassState.direction,
              accuracy: compassState.accuracy,
            ),
        ],
      ),
    ),
  );
} 