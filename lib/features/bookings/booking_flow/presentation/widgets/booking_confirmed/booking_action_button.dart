import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:jood/core/theming/app_colors.dart';

class BookingActionButton extends StatelessWidget {
  const BookingActionButton({
    super.key,
    required this.label,
    this.icon,
    required this.filled,
    required this.onTap,
  });

  final String label;
  final IconData? icon;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        // icon: Icon(icon, size: 18.sp),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: filled ? AppColors.primary : Colors.white,
          foregroundColor: filled ? Colors.white : AppColors.primary,
          side: filled ? null : BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
          padding: EdgeInsets.symmetric(vertical: 14.h),
          elevation: 0,
        ),
      ),
    );
  }
}


