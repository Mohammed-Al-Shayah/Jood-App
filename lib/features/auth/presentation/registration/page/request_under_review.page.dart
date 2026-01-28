import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jood/core/theming/app_colors.dart';
import 'package:jood/core/theming/app_text_styles.dart';

class RequestUnderReviewPage extends StatefulWidget {
  const RequestUnderReviewPage({super.key});

  @override
  State<RequestUnderReviewPage> createState() => _RequestUnderReviewPageState();
}

class _RequestUnderReviewPageState extends State<RequestUnderReviewPage> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120.r,
                  height: 120.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.15),
                  ),
                  child: Center(
                    child: Container(
                      width: 80.r,
                      height: 80.r,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                      ),
                      child:
                          Icon(Icons.check, size: 40.r, color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(height: 30.h),
                Text(
                  'Request Under Review',
                  style: AppTextStyles.sectionTitle.copyWith(fontSize: 20.sp),
                ),
                SizedBox(height: 12.h),
                Text(
                  'Your data has been submitted and is under review.',
                  style: AppTextStyles.cardMeta.copyWith(
                    fontSize: 13.sp,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
