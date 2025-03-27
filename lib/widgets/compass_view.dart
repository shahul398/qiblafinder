import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:qibla_finder_flutter/models/qibla_model.dart';
import 'package:qibla_finder_flutter/providers/settings_provider.dart';
import 'package:qibla_finder_flutter/utils/app_colors.dart';
import 'package:vibration/vibration.dart';

class CompassView extends HookConsumerWidget {
  final double qiblaDirection;
  final double currentDirection;
  final SensorAccuracy accuracy;
  
  const CompassView({
    Key? key,
    required this.qiblaDirection,
    required this.currentDirection,
    required this.accuracy,
  }) : super(key: key);

  // Static variable moved outside the method
  static bool _hasVibrated = false;
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    
    // Scale factor for pinch-to-zoom
    final ValueNotifier<double> scale = ValueNotifier(1.0);
    
    // Calculate relative angle between current direction and qibla
    final qiblaRelativeAngle = (qiblaDirection - currentDirection + 360) % 360;
    
    // Check if aligned with Qibla (within 5 degrees)
    final isAligned = qiblaRelativeAngle < 5 || qiblaRelativeAngle > 355;
    
    // Direction guide text
    final String directionGuide = getDirectionGuide(qiblaRelativeAngle);
    
    // Provide haptic feedback when aligned
    if (isAligned) {
      _provideAlignmentFeedback();
    }
    
    Color getDirectionColor() {
      if (settings.highContrastMode) {
        return Colors.yellow;
      }
      
      switch (accuracy) {
        case SensorAccuracy.high:
          return AppColors.success;
        case SensorAccuracy.medium:
          return AppColors.warning;
        case SensorAccuracy.low:
          return AppColors.accent;
        case SensorAccuracy.unreliable:
          return AppColors.error;
      }
    }
    
    return GestureDetector(
      onDoubleTap: () {
        scale.value = 1.0; // Reset scale on double tap
      },
      onScaleUpdate: (ScaleUpdateDetails details) {
        scale.value = (details.scale).clamp(0.8, 1.5);
      },
      child: ValueListenableBuilder<double>(
        valueListenable: scale,
        builder: (context, scaleValue, _) {
          return Container(
            height: 360.h,
            width: 360.w,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Static Qibla indicator (fixed at the top)
                Positioned(
                  top: 0,
                  child: Column(
                    children: [
                      Container(
                        width: 40.w,
                        height: 40.h,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(4.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(Icons.mosque, color: Colors.white, size: 24.sp),
                      ),
                      SizedBox(height: 5.h),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text(
                          'QIBLA',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ).animate(
                    // Add pulsing animation when aligned
                    target: isAligned ? 1 : 0,
                  ).scale(
                    begin: const Offset(1.0, 1.0),
                    end: const Offset(1.1, 1.1),
                    duration: 500.ms,
                    curve: Curves.easeInOut,
                  ).then(
                    delay: 250.ms,
                  ).scale(
                    begin: const Offset(1.1, 1.1),
                    end: const Offset(1.0, 1.0),
                    duration: 500.ms,
                    curve: Curves.easeInOut,
                  ),
                ),
            
                // Main Compass Container
                Transform.scale(
                  scale: scaleValue,
                  child: Container(
                    height: 280.h,
                    width: 280.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer compass circle
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                Colors.white,
                                Colors.grey.shade100,
                              ],
                              stops: const [0.7, 1.0],
                            ),
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 500.ms)
                        .scale(begin: const Offset(0.8, 0.8), duration: 500.ms),
                        
                        // Progress arc showing how close to Qibla direction
                        CustomPaint(
                          size: Size(280.w, 280.h),
                          painter: QiblaProgressArcPainter(
                            progress: _calculateProgress(qiblaRelativeAngle),
                            color: AppColors.primary.withOpacity(0.3),
                          ),
                        ),
                        
                        // Rotating compass face - rotates based on device orientation
                        TweenAnimationBuilder(
                          tween: Tween<double>(begin: -currentDirection, end: -currentDirection),
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOutCubic,
                          builder: (_, double angle, child) {
                            return Transform.rotate(
                              angle: angle * (pi / 180),
                              child: child,
                            );
                          },
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Cardinal directions and degree markings
                              ...List.generate(360 ~/ 15, (index) {
                                final angle = index * 15;
                                final isCardinal = angle % 90 == 0;
                                final isHalfCardinal = angle % 45 == 0 && !isCardinal;
                                
                                String? label;
                                if (angle == 0) label = 'N';
                                if (angle == 90) label = 'E';
                                if (angle == 180) label = 'S';
                                if (angle == 270) label = 'W';
                                
                                return Transform.rotate(
                                  angle: angle * (pi / 180),
                                  child: Align(
                                    alignment: const Alignment(0, -0.9),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          height: isCardinal ? 14.h : (isHalfCardinal ? 10.h : 6.h),
                                          width: isCardinal ? 2.w : (isHalfCardinal ? 1.5.w : 1.w),
                                          color: isCardinal ? AppColors.textPrimary : 
                                                (isHalfCardinal ? Colors.black87 : Colors.black54),
                                        ),
                                        if (label != null) 
                                          Padding(
                                            padding: EdgeInsets.only(top: 4.h),
                                            child: Text(
                                              label,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16.sp,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                          ),
                                        if (isCardinal && label == null)
                                          Padding(
                                            padding: EdgeInsets.only(top: 4.h),
                                            child: Text(
                                              angle.toString(),
                                              style: TextStyle(
                                                fontSize: 10.sp,
                                                color: Colors.black54,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                              
                              // Qibla direction indicator with arrow
                              Transform.rotate(
                                angle: qiblaDirection * (pi / 180),
                                child: Align(
                                  alignment: const Alignment(0, -0.7),
                                  child: Container(
                                    width: 32.w,
                                    height: 32.h,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColors.primary,
                                          AppColors.primary.withGreen(AppColors.primary.green + 30),
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.arrow_upward,
                                      color: Colors.white,
                                      size: 24.sp,
                                    ),
                                  ),
                                ),
                              ),
                              
                              // Enhanced directional needle with gradient
                              Align(
                                alignment: const Alignment(0, 0),
                                child: Container(
                                  width: 220.w,
                                  height: 220.h,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // North pointer (red gradient)
                                      Align(
                                        alignment: const Alignment(0, -0.5),
                                        child: Container(
                                          width: 4.w,
                                          height: 100.h,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Colors.red,
                                                Colors.red.withOpacity(0.5),
                                                Colors.red.withOpacity(0),
                                              ],
                                              stops: const [0.0, 0.7, 1.0],
                                            ),
                                            borderRadius: BorderRadius.circular(2.r),
                                          ),
                                        ),
                                      ),
                                      
                                      // South pointer (grey gradient)
                                      Align(
                                        alignment: const Alignment(0, 0.5),
                                        child: Container(
                                          width: 4.w,
                                          height: 100.h,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.bottomCenter,
                                              end: Alignment.topCenter,
                                              colors: [
                                                Colors.grey,
                                                Colors.grey.withOpacity(0.5),
                                                Colors.grey.withOpacity(0),
                                              ],
                                              stops: const [0.0, 0.7, 1.0],
                                            ),
                                            borderRadius: BorderRadius.circular(2.r),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Center pivot
                        Container(
                          width: 20.w,
                          height: 20.h,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                Colors.white,
                                Colors.grey.shade300,
                              ],
                              stops: const [0.7, 1.0],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                        
                        // Display degrees text at bottom
                        Align(
                          alignment: const Alignment(0, 0.85),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              '${currentDirection.toStringAsFixed(1)}°',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Direction guide text
                if (directionGuide.isNotEmpty && !isAligned)
                  Positioned(
                    bottom: 70.h,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getDirectionIcon(qiblaRelativeAngle),
                            color: Colors.white,
                            size: 18.sp,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            directionGuide,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ).animate().fade(duration: 300.ms).slideY(
                      begin: 0.2,
                      duration: 300.ms,
                    ),
                  ),
                
                // Accuracy indicator
                Positioned(
                  bottom: -60,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          getDirectionColor(),
                          getDirectionColor().withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color: getDirectionColor().withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      accuracy == SensorAccuracy.high 
                          ? 'High Accuracy'
                          : accuracy == SensorAccuracy.medium
                              ? 'Medium Accuracy'
                              : accuracy == SensorAccuracy.low
                                  ? 'Low Accuracy'
                                  : 'Please Calibrate',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  // Calculate progress percentage for the progress arc
  double _calculateProgress(double relativeAngle) {
    if (relativeAngle > 180) {
      relativeAngle = 360 - relativeAngle;
    }
    return 1 - (relativeAngle / 180);
  }
  
  // Get direction guide text based on angle
  String getDirectionGuide(double angle) {
    if (angle < 5 || angle > 355) {
      return ""; // Already aligned
    } else if (angle > 180) {
      return "Turn left to find Qibla";
    } else {
      return "Turn right to find Qibla";
    }
  }
  
  // Get direction icon based on angle
  IconData _getDirectionIcon(double angle) {
    if (angle > 180) {
      return Icons.arrow_back;
    } else {
      return Icons.arrow_forward;
    }
  }
  
  // Provide haptic feedback when aligned with Qibla
  void _provideAlignmentFeedback() async {
    if (!_hasVibrated) {
      _hasVibrated = true;
      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(duration: 200);
        Future.delayed(const Duration(seconds: 2), () {
          _hasVibrated = false;
        });
      }
    }
  }
}

// Custom painter for the progress arc
class QiblaProgressArcPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0
  final Color color;
  
  QiblaProgressArcPainter({
    required this.progress,
    required this.color,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: size.width / 2,
    );
    
    const startAngle = -pi / 2; // Start from top (270 degrees)
    final sweepAngle = 2 * pi * progress; // Full circle is 2*pi
    
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.round;
    
    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
  }
  
  @override
  bool shouldRepaint(QiblaProgressArcPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
} 