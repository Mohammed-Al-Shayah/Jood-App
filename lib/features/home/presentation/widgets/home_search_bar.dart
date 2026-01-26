import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/utils/app_strings.dart';

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.iconStroke,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: TextFormField(
        decoration: InputDecoration(
          hintText: AppStrings.searchHint,
          hintStyle: AppTextStyles.searchHint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.r),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.r),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.r),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: AppColors.iconStroke,
          prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
          contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        ),
        style: AppTextStyles.searchHint.copyWith(
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
