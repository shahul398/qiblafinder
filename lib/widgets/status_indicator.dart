import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:qibla_finder_flutter/models/qibla_model.dart';

class StatusIndicator extends HookConsumerWidget {
  final double locationAccuracy;
  final SensorAccuracy compassAccuracy;
  
  const StatusIndicator({
    Key? key,
    required this.locationAccuracy,
    required this.compassAccuracy,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildIndicator(
          context,
          'Location',
          locationAccuracy <= 0 ? 0.0 : _getLocationAccuracyPercentage(),
          locationAccuracy <= 0 ? Colors.grey : _getLocationAccuracyColor(context),
          Icons.location_on,
        ),
        SizedBox(width: 24.w),
        _buildIndicator(
          context,
          'Compass',
          _getCompassAccuracyPercentage(),
          _getCompassAccuracyColor(context),
          Icons.explore,
        ),
      ],
    );
  }

  Widget _buildIndicator(
    BuildContext context,
    String label,
    double accuracyPercent,
    Color color,
    IconData icon,
  ) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 60.w,
              height: 60.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.withOpacity(0.1),
              ),
            ),
            SizedBox(
              width: 60.w,
              height: 60.w,
              child: CircularProgressIndicator(
                value: accuracyPercent,
                backgroundColor: Colors.grey.withOpacity(0.2),
                color: color,
                strokeWidth: 6.w,
              ),
            ),
            Icon(
              icon,
              size: 28.sp,
              color: color,
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    )
    .animate()
    .fade(duration: 500.ms)
    .scale(begin: const Offset(0.8, 0.8), duration: 500.ms);
  }

  double _getLocationAccuracyPercentage() {
    if (locationAccuracy <= 0) return 0.0;
    // Lower values are better for location accuracy
    if (locationAccuracy < 5) return 1.0;
    if (locationAccuracy < 10) return 0.9;
    if (locationAccuracy < 20) return 0.7;
    if (locationAccuracy < 50) return 0.5;
    if (locationAccuracy < 100) return 0.3;
    return 0.2;
  }

  Color _getLocationAccuracyColor(BuildContext context) {
    if (locationAccuracy < 5) return Colors.green;
    if (locationAccuracy < 20) return Colors.amber;
    if (locationAccuracy < 50) return Colors.orange;
    return Colors.red;
  }

  double _getCompassAccuracyPercentage() {
    switch (compassAccuracy) {
      case SensorAccuracy.high:
        return 1.0;
      case SensorAccuracy.medium:
        return 0.7;
      case SensorAccuracy.low:
        return 0.4;
      case SensorAccuracy.unreliable:
        return 0.1;
    }
  }

  Color _getCompassAccuracyColor(BuildContext context) {
    switch (compassAccuracy) {
      case SensorAccuracy.high:
        return Colors.green;
      case SensorAccuracy.medium:
        return Colors.amber;
      case SensorAccuracy.low:
        return Colors.orange;
      case SensorAccuracy.unreliable:
        return Colors.red;
    }
  }
} 