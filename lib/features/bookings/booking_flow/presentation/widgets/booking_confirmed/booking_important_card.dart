import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:jood/core/theming/app_colors.dart';
import 'package:jood/core/theming/app_text_styles.dart';
import 'package:jood/core/utils/app_strings.dart';

class BookingImportantCard extends StatelessWidget {
  const BookingImportantCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.important,
            style: AppTextStyles.sectionTitle.copyWith(fontSize: 13.sp),
          ),
          SizedBox(height: 8.h),
          _Bullet(text: AppStrings.importantItem1),
          SizedBox(height: 6.h),
          _Bullet(text: AppStrings.importantItem2),
          SizedBox(height: 6.h),
          _Bullet(text: AppStrings.importantItem3),
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(top: 6.h),
          width: 6.w,
          height: 6.w,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.cardMeta.copyWith(
              fontSize: 12.sp,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}


