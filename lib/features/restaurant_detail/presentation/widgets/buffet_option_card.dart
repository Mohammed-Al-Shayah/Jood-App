import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theming/app_colors.dart';
import '../../../../../core/theming/app_text_styles.dart';
import '../../../../../core/utils/app_strings.dart';

class BuffetOption {
  const BuffetOption({
    required this.title,
    required this.description,
    required this.oldPrice,
    required this.price,
    this.badge,
  });

  final String title;
  final String description;
  final String oldPrice;
  final String price;
  final String? badge;
}

class BuffetOptionCard extends StatelessWidget {
  const BuffetOptionCard({super.key, required this.option});

  final BuffetOption option;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.pageBackground,
        borderRadius: BorderRadius.circular(14.r),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(option.title, style: AppTextStyles.cardTitle),
              if (option.badge != null)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    option.badge!,
                    style: AppTextStyles.badge,
                  ),
                ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            option.description,
            style: AppTextStyles.cardMeta,
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Text(
                option.oldPrice,
                style: AppTextStyles.cardMeta.copyWith(
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              SizedBox(width: 8.w),
              Text(option.price, style: AppTextStyles.cardPrice),
            ],
          ),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                padding: EdgeInsets.symmetric(vertical: 12.h),
                elevation: 0,
              ),
              child: Text(
                AppStrings.checkAvailability,
                style: AppTextStyles.cta,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
