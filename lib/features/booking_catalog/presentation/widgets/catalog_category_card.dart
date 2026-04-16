import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/localization/app_localization_controller.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../domain/entities/catalog_category_type.dart';

class CatalogCategoryCard extends StatelessWidget {
  const CatalogCategoryCard({
    super.key,
    required this.category,
    required this.onTap,
    this.width,
  });

  final CatalogCategoryType category;
  final VoidCallback onTap;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final config = _configFor(category);
    // final isRtl = Directionality.of(context) == TextDirection.rtl;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Ink(
          width: width ?? 220.w,
          height: double.infinity,
          padding: EdgeInsets.all(14.r),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: config.gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowColor,
                blurRadius: 12.r,
                offset: Offset(0, 4.h),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 36.r,
                height: 36.r,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(config.icon, color: Colors.white, size: 18.sp),
              ),
              SizedBox(height: 12.h),
              Text(
                _categoryText(category, 'title'),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTextStyles.cardTitle.copyWith(
                  color: Colors.white,
                  fontSize: 13.sp,
                ),
              ),
              // const Spacer(),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     Text(
              //       AppStrings.explore,
              //       style: AppTextStyles.cardPrice.copyWith(
              //         color: Colors.white,
              //         fontSize: 12.sp,
              //       ),
              //     ),
              //     SizedBox(width: 6.w),
              //     Icon(
              //       isRtl
              //           ? Icons.arrow_back_rounded
              //           : Icons.arrow_forward_rounded,
              //       color: Colors.white,
              //       size: 16.sp,
              //     ),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryVisualConfig {
  const _CategoryVisualConfig({required this.icon, required this.gradient});

  final IconData icon;
  final List<Color> gradient;
}

_CategoryVisualConfig _configFor(CatalogCategoryType category) {
  switch (category) {
    case CatalogCategoryType.buffet:
      return const _CategoryVisualConfig(
        icon: Icons.restaurant_menu_rounded,
        gradient: [Color(0xFF0F766E), Color(0xFF14B8A6)],
      );
    case CatalogCategoryType.setMenu:
      return const _CategoryVisualConfig(
        icon: Icons.dinner_dining_rounded,
        gradient: [Color(0xFF1D4ED8), Color(0xFF3B82F6)],
      );
    case CatalogCategoryType.combo:
      return const _CategoryVisualConfig(
        icon: Icons.fastfood_rounded,
        gradient: [Color(0xFFBE185D), Color(0xFFF97316)],
      );
    case CatalogCategoryType.attraction:
      return const _CategoryVisualConfig(
        icon: Icons.park_rounded,
        gradient: [Color(0xFFB45309), Color(0xFFF59E0B)],
      );
  }
}

String _categoryText(CatalogCategoryType category, String suffix) {
  return AppLocalizationController.instance.tr(
    'catalog_category_${category.routeKey}_$suffix',
  );
}
