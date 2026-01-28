import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theming/app_colors.dart';
import '../../../../../core/theming/app_text_styles.dart';
import '../../../../../core/utils/app_strings.dart';

class PaymentSummaryCard extends StatelessWidget {
  const PaymentSummaryCard({
    super.key,
    required this.restaurantName,
    required this.timeLabel,
    required this.totalAmount,
    required this.adultsCount,
    required this.childrenCount,
  });

  final String restaurantName;
  final String timeLabel;
  final String totalAmount;
  final int adultsCount;
  final int childrenCount;

  @override
  Widget build(BuildContext context) {
    final guestsLabel = childrenCount > 0
        ? '$adultsCount ${AppStrings.adults}, $childrenCount ${AppStrings.children}'
        : '$adultsCount ${AppStrings.adults}';

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 12.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            restaurantName,
            style: AppTextStyles.cardTitle.copyWith(
              color: Colors.white,
              fontSize: 18.sp,
            ),
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.white70, size: 20.sp),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  timeLabel,
                  style: AppTextStyles.cardMeta.copyWith(
                    color: Colors.white70,
                    fontSize: 16.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Divider(color: Colors.white24,thickness: 2,),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.totalAmount,
                    style: AppTextStyles.cardMeta.copyWith(
                      color: Colors.white70,
                      fontSize: 16.sp,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    totalAmount,
                    style: AppTextStyles.cardTitle.copyWith(
                      color: Colors.white,
                      fontSize: 20.sp,
                    ),
                  ),
                ],
              ),
              Text(
                guestsLabel,
                style: AppTextStyles.cardMeta.copyWith(
                  color: Colors.white70,
                  fontSize: 16.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
