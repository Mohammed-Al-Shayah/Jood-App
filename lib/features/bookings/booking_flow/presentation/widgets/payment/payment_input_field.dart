import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:jood/core/theming/app_colors.dart';
import 'package:jood/core/theming/app_text_styles.dart';

class PaymentInputField extends StatelessWidget {
  const PaymentInputField({
    super.key,
    required this.hintText,
    this.keyboardType,
  });

  final String hintText;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60.h,
      child: TextFormField(
        keyboardType: keyboardType,
        style: AppTextStyles.cardMeta.copyWith(
          color: AppColors.textPrimary,
          fontSize: 13.sp,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTextStyles.cardMeta.copyWith(
            color: AppColors.textMuted,
            fontSize: 13.sp,
          ),
          filled: true,
          fillColor: const Color(0xFFF6F7FB),
          contentPadding: EdgeInsets.symmetric(horizontal: 14.w),
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
        ),
      ),
    );
  }
}


