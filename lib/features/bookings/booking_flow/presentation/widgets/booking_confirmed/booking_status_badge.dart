import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:jood/core/theming/app_colors.dart';

class BookingStatusBadge extends StatelessWidget {
  const BookingStatusBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: const BoxDecoration(
        color: Color(0xFFEFFAF6),
        shape: BoxShape.circle,
      ),
      child: Container(
        width: 80.w,
        height: 80.w,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.check,
          color: Colors.white,
          size: 40.sp,
        ),
      ),
    );
  }
}


