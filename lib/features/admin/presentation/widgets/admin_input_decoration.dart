import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jood/core/theming/app_colors.dart';

InputDecoration adminInputDecoration(String label) {
  return InputDecoration(
    labelText: label,
    filled: true,
    fillColor: AppColors.iconStroke,
    contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: BorderSide.none,
    ),
  );
}
