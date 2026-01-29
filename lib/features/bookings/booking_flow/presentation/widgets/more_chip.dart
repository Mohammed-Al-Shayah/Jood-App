import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:jood/core/theming/app_colors.dart';
import 'package:jood/core/theming/app_text_styles.dart';
import 'package:jood/core/utils/app_strings.dart';

class MoreChip extends StatelessWidget {
  const MoreChip({
    super.key,
    required this.isSelected,
    required this.onTap,
  });

  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final background = isSelected ? AppColors.primary : const Color(0xFFEFF1F4);
    final textColor = isSelected ? Colors.white : AppColors.textPrimary;

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(14.r),
        onTap: onTap,
        child: Container(
          width: 60.w,
          height: 80.h,
          alignment: Alignment.center,
          child: Text(
            AppStrings.more,
            style: AppTextStyles.cardTitle.copyWith(
              color: textColor,
              fontSize: 15.sp,
            ),
          ),
        ),
      ),
    );
  }
}


