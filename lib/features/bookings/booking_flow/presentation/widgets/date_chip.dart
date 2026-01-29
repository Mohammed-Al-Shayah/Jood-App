import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:jood/core/theming/app_colors.dart';
import 'package:jood/core/theming/app_text_styles.dart';
import 'date_utils.dart';

class DateChip extends StatelessWidget {
  const DateChip({
    super.key,
    required this.date,
    required this.isSelected,
    required this.onTap,
  });

  final DateTime date;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final month = monthShort(date.month);
    final day = weekdayShort(date.weekday);
    final background = isSelected ? AppColors.primary : const Color(0xFFEFF1F4);
    final textColor = isSelected ? Colors.white : AppColors.textPrimary;
    final subColor = isSelected ? Colors.white70 : AppColors.textMuted;

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(14.r),
        onTap: onTap,
        child: Container(
          width: 60.w,
          height: 80.h,
          padding: EdgeInsets.symmetric(vertical: 6.h),
          alignment: Alignment.center,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  day,
                  style: AppTextStyles.cardMeta.copyWith(
                    color: subColor,
                    fontSize: 13.sp,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '${date.day}',
                  style: AppTextStyles.cardTitle.copyWith(
                    color: textColor,
                    fontSize: 17.sp,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  month,
                  style: AppTextStyles.cardMeta.copyWith(
                    color: subColor,
                    fontSize: 13.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


