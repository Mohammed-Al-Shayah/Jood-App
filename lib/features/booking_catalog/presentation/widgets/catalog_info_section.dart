import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/utils/app_strings.dart';

class CatalogInfoSection extends StatelessWidget {
  const CatalogInfoSection({
    super.key,
    required this.title,
    required this.items,
    this.emptyLabel,
    this.collapsible = false,
    this.initiallyExpanded = false,
  });

  final String title;
  final List<String> items;
  final String? emptyLabel;
  final bool collapsible;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final values = items.where((item) => item.trim().isNotEmpty).toList();
    final effectiveEmptyLabel =
        emptyLabel ?? AppStrings.noDetailsAvailableYet;
    final decoration = BoxDecoration(
      color: AppColors.cardBackground,
      borderRadius: BorderRadius.circular(16.r),
      boxShadow: [
        BoxShadow(
          color: AppColors.shadowColor,
          blurRadius: 12.r,
          offset: Offset(0, 5.h),
        ),
      ],
    );

    if (!collapsible) {
      return Container(
        padding: EdgeInsets.all(14.r),
        decoration: decoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.sectionTitle),
            SizedBox(height: 12.h),
            ..._buildItems(values, effectiveEmptyLabel),
          ],
        ),
      );
    }

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Container(
        decoration: decoration,
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          tilePadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 2.h),
          childrenPadding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 14.h),
          iconColor: AppColors.textMuted,
          collapsedIconColor: AppColors.textMuted,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Text(title, style: AppTextStyles.sectionTitle),
          children: _buildItems(values, effectiveEmptyLabel),
        ),
      ),
    );
  }

  List<Widget> _buildItems(List<String> values, String effectiveEmptyLabel) {
    if (values.isEmpty) {
      return [
        Text(
          effectiveEmptyLabel,
          style: AppTextStyles.cardMeta.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ];
    }

    return values
        .map(
          (item) => Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(top: 6.h),
                  width: 6.w,
                  height: 6.w,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    item,
                    style: AppTextStyles.cardMeta.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 12.5.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
        .toList(growable: false);
  }
}
