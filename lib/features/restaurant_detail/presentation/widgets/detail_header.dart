import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';

class DetailHeader extends StatelessWidget {
  const DetailHeader({
    super.key,
    required this.image,
    required this.onBack,
    required this.name,
    required this.rating,
    required this.meta,
  });

  final Widget image;
  final VoidCallback onBack;
  final String name;
  final String rating;
  final String meta;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(height: 240.h, width: double.infinity, child: image),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.55),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 12.h,
          left: 12.w,
          child: _CircleIconButton(icon: Icons.arrow_back, onTap: onBack),
        ),

        Positioned(
          left: 16.w,
          right: 16.w,
          bottom: 16.h,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: AppTextStyles.cardTitle.copyWith(
                  color: Colors.white,
                  fontSize: 20.sp,
                ),
              ),
              SizedBox(height: 6.h),
              Row(
                children: [
                  Icon(Icons.star, color: AppColors.ratingStar, size: 14.sp),
                  SizedBox(width: 4.w),
                  Text(
                    rating,
                    style: AppTextStyles.cardMeta.copyWith(
                      color: Colors.white,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    color: Colors.white.withValues(alpha: 0.9),
                    size: 14.sp,
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Text(
                      meta,
                      style: AppTextStyles.cardMeta.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.92),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(8.w),
          child: Icon(icon, size: 18.sp),
        ),
      ),
    );
  }
}
