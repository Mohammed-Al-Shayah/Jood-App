import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/utils/app_strings.dart';

class RestaurantCard extends StatelessWidget {
  const RestaurantCard({
    super.key,
    required this.name,
    required this.badge,
    required this.price,
    required this.discount,
    required this.meta,
    required this.slots,
    required this.rating,
    required this.image,
    this.onTap,
  });

  final String name;
  final String badge;
  final String price;
  final String discount;
  final String meta;
  final String slots;
  final String rating;
  final Widget image;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final trimmedPrice = price.trim();
    final lowerPrice = trimmedPrice.toLowerCase();
    final hasFromLabel = lowerPrice.startsWith('from ');
    final priceLabel = hasFromLabel ? 'From' : '';
    final priceValue = hasFromLabel
        ? trimmedPrice.substring(5).trim()
        : trimmedPrice;
    final hasBadge = badge.trim().isNotEmpty;
    final hasDiscount = discount.trim().isNotEmpty || hasBadge;
    final showDiscountValue = discount.trim().isNotEmpty;
    // final afterDiscountText = showDiscountValue
    //     ? 'After discount ${discount.trim()}'
    //     : '';
    // final slotsText = hasDiscount && afterDiscountText.isNotEmpty
    //     ? afterDiscountText
    //     : slots;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowColor,
                blurRadius: 14.r,
                offset: Offset(0, 6.h),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  SizedBox(
                    height: 160.h,
                    width: double.infinity,
                    child: ClipRRect(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16.r),
                      ),
                      child: SizedBox.expand(child: image),
                    ),
                  ),
                  if (hasBadge)
                    Positioned(
                      top: 12.h,
                      left: 12.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: Color(0xff7c3aed),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(badge, style: AppTextStyles.badge),
                      ),
                    ),
                ],
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 12.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: AppTextStyles.cardTitle,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: AppColors.ratingStar,
                              size: 16.sp,
                            ),
                            SizedBox(width: 4.w),
                            Text(rating, style: AppTextStyles.cardRating),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          color: AppColors.textMuted,
                          size: 14.sp,
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            meta,
                            style: AppTextStyles.cardMeta,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (hasFromLabel)
                          Row(
                            children: [
                              Text(
                                priceLabel,
                                style: AppTextStyles.cardSlots.copyWith(
                                  fontSize: 16.sp,
                                ),
                              ),
                              SizedBox(width: 10.w),
                              Text(
                                priceValue,
                                style: AppTextStyles.cardPrice.copyWith(
                                  fontSize: 18.sp,
                                  color: AppColors.textPrimary,
                                  decoration: hasDiscount
                                      ? TextDecoration.lineThrough
                                      : null,
                                  decorationColor: hasDiscount
                                      ? Colors.red
                                      : null,
                                  decorationThickness: hasDiscount ? 3 : null,
                                ),
                              ),
                              SizedBox(width: 10.w),

                              if (hasDiscount) ...[
                                if (showDiscountValue)
                                  Text(
                                    discount,
                                    style: AppTextStyles.cardDiscount,
                                  ),
                                const Spacer(),
                                if (hasBadge)
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10.w,
                                      vertical: 6.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Color(0xff7c3aed),
                                      borderRadius: BorderRadius.circular(20.r),
                                    ),
                                    child: Text(
                                      badge,
                                      style: AppTextStyles.badge,
                                    ),
                                  ),
                              ],
                            ],
                          ),

                        if (!hasFromLabel && trimmedPrice.isNotEmpty)
                          Text(
                            trimmedPrice,
                            style: AppTextStyles.cardPrice.copyWith(
                              fontSize: 18.sp,
                            ),
                          ),

                        SizedBox(height: 18.h),
                        // Text(slotsText, style: AppTextStyles.cardSlots),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 18.w,
                        vertical: 10.h,
                      ),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.ctaShadow,
                            blurRadius: 10.r,
                            offset: Offset(0, 5.h),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          AppStrings.viewDetails,
                          style: AppTextStyles.cta,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
