import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:qibla_finder_flutter/providers/qibla_provider.dart';

class CalibrationOverlay extends HookConsumerWidget {
  const CalibrationOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120.w,
              height: 120.w,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: Icon(
                Icons.rotate_right,
                size: 80.sp,
                color: Colors.blue,
              ).animate(
                onPlay: (controller) => controller.repeat(),
              ).rotate(
                duration: 1500.ms,
                curve: Curves.linear,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'Compass Calibration Needed',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w),
              child: Text(
                'Move your device in a figure-8 pattern to calibrate the compass sensors.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 32.h),
            ElevatedButton(
              onPressed: () {
                ref.read(qiblaProvider.notifier).stopCalibration();
              },
              child: const Text('Done'),
            ),
          ],
        ).animate().fadeIn(duration: 300.ms).scale(
          begin: const Offset(0.9, 0.9), 
          duration: 300.ms,
        ),
      ),
    );
  }
} 