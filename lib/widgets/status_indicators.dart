import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qibla_finder_flutter/utils/app_colors.dart';

class StatusIndicators extends StatelessWidget {
  final bool hasLocation;
  final bool hasCompass;

  const StatusIndicators({
    Key? key,
    required this.hasLocation,
    required this.hasCompass,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Location indicator
        Container(
          width: 100.w,
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            gradient: hasLocation 
                ? AppColors.accentGradient 
                : LinearGradient(
                    colors: [Colors.grey, Colors.grey.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            borderRadius: BorderRadius.circular(30.r),
            boxShadow: [
              BoxShadow(
                color: (hasLocation ? AppColors.accent : Colors.grey).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(
                Icons.location_on,
                color: Colors.white,
                size: 28.sp,
              ),
              SizedBox(height: 4.h),
              Text(
                'Location',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 40.w),
        // Compass indicator
        Container(
          width: 100.w,
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            gradient: hasCompass 
                ? AppColors.primaryGradient 
                : LinearGradient(
                    colors: [Colors.grey, Colors.grey.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            borderRadius: BorderRadius.circular(30.r),
            boxShadow: [
              BoxShadow(
                color: (hasCompass ? AppColors.primary : Colors.grey).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(
                Icons.explore,
                color: Colors.white,
                size: 28.sp,
              ),
              SizedBox(height: 4.h),
              Text(
                'Compass',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
} 