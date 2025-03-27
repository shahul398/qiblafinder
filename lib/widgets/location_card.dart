import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:qibla_finder_flutter/models/location_model.dart';
import 'package:qibla_finder_flutter/providers/settings_provider.dart';
import 'package:qibla_finder_flutter/utils/app_colors.dart';

class LocationCard extends HookConsumerWidget {
  final LocationModel location;
  final double distance;
  final bool isLoading;
  
  const LocationCard({
    Key? key,
    required this.location,
    required this.distance,
    required this.isLoading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final textScaleFactor = settings.largeText ? 1.2 : 1.0;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      elevation: 8,
      shadowColor: Colors.black26,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          color: AppColors.cardBackground,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(12.r),
          child: isLoading 
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: AppColors.secondary,
                        size: 24.r,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          location.cityName != null 
                            ? '${location.cityName}, ${location.countryName ?? ""}'
                            : 'Current Location',
                          style: TextStyle(
                            fontSize: 18.sp * textScaleFactor,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Divider(height: 1, color: Colors.grey.withOpacity(0.3)),
                  SizedBox(height: 8.h),
                  
                  // Coordinates section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Latitude
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.north, 
                                size: 16.sp,
                                color: AppColors.textSecondary,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                'Latitude',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '${location.latitude.toStringAsFixed(6)}°',
                            style: TextStyle(
                              fontSize: 18.sp * textScaleFactor,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      
                      // Longitude
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.east, 
                                size: 16.sp,
                                color: AppColors.textSecondary,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                'Longitude',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '${location.longitude.toStringAsFixed(6)}°',
                            style: TextStyle(
                              fontSize: 18.sp * textScaleFactor,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Divider(height: 1, color: Colors.grey.withOpacity(0.3)),
                  SizedBox(height: 8.h),
                  
                  // Distance section
                  Row(
                    children: [
                      Icon(
                        Icons.mosque,
                        color: AppColors.secondary,
                        size: 24.r,
                      ),
                      SizedBox(width: 12.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Distance to Kaaba',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '${distance.toStringAsFixed(2)} km',
                            style: TextStyle(
                              fontSize: 18.sp * textScaleFactor,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ).animate().fade(duration: 300.ms).slideY(
                begin: 0.2, 
                duration: 300.ms, 
                curve: Curves.easeOut
              ),
        ),
      ),
    );
  }
} 