import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theming/app_colors.dart';
import '../../../../../core/theming/app_text_styles.dart';
import '../../../../../core/utils/app_strings.dart';

class AvailabilityCard extends StatelessWidget {
  const AvailabilityCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.todayAvailability,
                style: AppTextStyles.cardMeta.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                AppStrings.nextSlotLabel,
                style: AppTextStyles.cardMeta,
              ),
              Text(
                AppStrings.nextSlotTime,
                style: AppTextStyles.cardTitle.copyWith(
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                AppStrings.remainingLabel,
                style: AppTextStyles.cardMeta,
              ),
              Text(
                AppStrings.remainingSpots,
                style: AppTextStyles.cardTitle.copyWith(
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
