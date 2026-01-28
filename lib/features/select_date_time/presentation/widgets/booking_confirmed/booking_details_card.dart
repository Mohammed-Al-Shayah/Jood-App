import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theming/app_colors.dart';
import '../../../../../core/theming/app_text_styles.dart';
import '../../../../../core/utils/app_strings.dart';

class BookingDetailsCard extends StatelessWidget {
  const BookingDetailsCard({
    super.key,
    required this.restaurantName,
    required this.dateLabel,
    required this.timeLabel,
    required this.guestsLabel,
    required this.totalPaid,
  });

  final String restaurantName;
  final String dateLabel;
  final String timeLabel;
  final String guestsLabel;
  final String totalPaid;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 10.r,
            offset: Offset(0, 5.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.bookingDetailsTitle,
            style: AppTextStyles.sectionTitle.copyWith(fontSize: 14.sp),
          ),
          SizedBox(height: 10.h),
          Text(
            restaurantName,
            style: AppTextStyles.cardTitle.copyWith(fontSize: 15.sp),
          ),
          SizedBox(height: 4.h),
          Text(
            'West End, Main Street',
            style: AppTextStyles.cardMeta.copyWith(fontSize: 12.sp),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              _InfoChip(
                icon: Icons.calendar_today,
                label: dateLabel,
              ),
              SizedBox(width: 12.w),
              _InfoChip(
                icon: Icons.schedule,
                label: timeLabel,
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              _InfoChip(
                icon: Icons.people,
                label: guestsLabel,
              ),
              const Spacer(),
              Text(
                totalPaid,
                style: AppTextStyles.cardPrice.copyWith(fontSize: 16.sp),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            AppStrings.totalPaid,
            style: AppTextStyles.cardMeta.copyWith(fontSize: 12.sp),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7FB),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14.sp, color: AppColors.primary),
          SizedBox(width: 6.w),
          Text(
            label,
            style: AppTextStyles.cardMeta.copyWith(fontSize: 12.sp),
          ),
        ],
      ),
    );
  }
}
