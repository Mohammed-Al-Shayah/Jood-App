import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../domain/entities/catalog_category_type.dart';

class CatalogCategoryCard extends StatelessWidget {
  const CatalogCategoryCard({
    super.key,
    required this.category,
    required this.onTap,
  });

  final CatalogCategoryType category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final config = _configFor(category);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.r),
        child: Ink(
          width: 220.w,
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: config.gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowColor,
                blurRadius: 16.r,
                offset: Offset(0, 6.h),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40.r,
                height: 40.r,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(config.icon, color: Colors.white, size: 20.sp),
              ),
              SizedBox(height: 12.h),
              Text(
                category.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.cardTitle.copyWith(
                  color: Colors.white,
                  fontSize: 17.sp,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                config.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.cardMeta.copyWith(
                  color: Colors.white.withValues(alpha: 0.92),
                  fontSize: 12.sp,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Text(
                    'Explore',
                    style: AppTextStyles.cardPrice.copyWith(
                      color: Colors.white,
                      fontSize: 13.sp,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 16.sp,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryVisualConfig {
  const _CategoryVisualConfig({
    required this.icon,
    required this.subtitle,
    required this.gradient,
  });

  final IconData icon;
  final String subtitle;
  final List<Color> gradient;
}

_CategoryVisualConfig _configFor(CatalogCategoryType category) {
  switch (category) {
    case CatalogCategoryType.buffet:
      return const _CategoryVisualConfig(
        icon: Icons.restaurant_menu_rounded,
        subtitle: 'Breakfast, lunch, dinner, and optional brunch experiences.',
        gradient: [Color(0xFF0F766E), Color(0xFF14B8A6)],
      );
    case CatalogCategoryType.setMenu:
      return const _CategoryVisualConfig(
        icon: Icons.dinner_dining_rounded,
        subtitle: 'Curated set menus with clean pricing and guided selection.',
        gradient: [Color(0xFF1D4ED8), Color(0xFF3B82F6)],
      );
    case CatalogCategoryType.attraction:
      return const _CategoryVisualConfig(
        icon: Icons.park_rounded,
        subtitle: 'Book packages by date and time with dynamic availability.',
        gradient: [Color(0xFFB45309), Color(0xFFF59E0B)],
      );
  }
}
