import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_colors.dart';
import '../../../../core/utils/app_strings.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.locationText,
    required this.onFilterTap,
  });
  final String locationText;
  final VoidCallback onFilterTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: AppColors.cardBackground),
      child: Row(
        children: [
          Icon(
            Icons.location_on_outlined,
            color: AppColors.primary,
            size: 25.sp,
          ),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppStrings.currentLocation,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                locationText,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(width: 8.w),
          const Spacer(),
          InkWell(
            borderRadius: BorderRadius.circular(20.r),
            onTap: onFilterTap,
            child: Container(
              height: 40.r,
              width: 40.r,
              decoration: const BoxDecoration(
                color: AppColors.iconStroke,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.tune,
                color: AppColors.textPrimary,
                size: 25.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
