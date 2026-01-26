import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_colors.dart';

class AppTextStyles {
  const AppTextStyles._();

  static TextStyle get locationLabel => TextStyle(
        color: AppColors.textMuted,
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get locationValue => TextStyle(
        color: AppColors.textPrimary,
        fontSize: 16.sp,
        fontWeight: FontWeight.w700,
      );

  static TextStyle get searchHint => TextStyle(
        color: AppColors.textMuted,
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get sectionTitle => TextStyle(
        color: AppColors.textPrimary,
        fontSize: 16.sp,
        fontWeight: FontWeight.w700,
      );

  static TextStyle get sectionCount => TextStyle(
        color: AppColors.textMuted,
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get cardTitle => TextStyle(
        color: AppColors.textPrimary,
        fontSize: 16.sp,
        fontWeight: FontWeight.w700,
      );

  static TextStyle get cardMeta => TextStyle(
        color: AppColors.textMuted,
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get cardRating => TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 12.sp,
      );

  static TextStyle get cardPrice => TextStyle(
        color: AppColors.primary,
        fontWeight: FontWeight.w700,
        fontSize: 13.sp,
      );

  static TextStyle get cardSlots => TextStyle(
        color: AppColors.textSecondary,
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get cardDiscount => TextStyle(
        color: AppColors.primaryDark,
        fontWeight: FontWeight.w700,
        fontSize: 11.sp,
      );

  static TextStyle get badge => TextStyle(
        color: AppColors.badgeText,
        fontWeight: FontWeight.w700,
        fontSize: 12.sp,
      );

  static TextStyle get cta => TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w700,
        fontSize: 16.sp,
      );
}
