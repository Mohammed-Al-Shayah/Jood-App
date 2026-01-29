import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:jood/core/theming/app_colors.dart';
import 'package:jood/core/theming/app_text_styles.dart';
import 'package:jood/core/utils/app_strings.dart';
import 'package:jood/features/offers/domain/entities/offer_entity.dart';

class OfferCard extends StatelessWidget {
  const OfferCard({
    super.key,
    required this.offer,
    required this.isSelected,
    required this.onTap,
    required this.statusLabel,
    required this.statusColor,
  });

  final OfferEntity offer;
  final bool isSelected;
  final VoidCallback? onTap;
  final String statusLabel;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected ? AppColors.primary : Colors.transparent;
    final timeLabel = offer.startTime.isEmpty ? '--' : offer.startTime;
    final titleLabel =
        offer.title.isEmpty ? AppStrings.buffetEntry : offer.title;
    final priceLabel = _formatPrice(offer);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: borderColor, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowColor,
                blurRadius: 10.r,
                offset: Offset(0, 5.h),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50.w,
                    height: 50.w,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.restaurant,
                      color: AppColors.primary,
                      size: 23.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          timeLabel,
                          style: AppTextStyles.cardTitle.copyWith(
                            fontSize: 15.sp,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          titleLabel,
                          style: AppTextStyles.cardMeta.copyWith(
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        priceLabel,
                        style: AppTextStyles.cardPrice.copyWith(
                          fontSize: 18.sp,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        AppStrings.perAdult,
                        style: AppTextStyles.cardMeta.copyWith(
                          fontSize: 13.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Divider(color: AppColors.shadowColor),
              SizedBox(height: 10.h),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      statusLabel,
                      style: AppTextStyles.cardMeta.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 15.sp,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Container(
                      width: 20.w,
                      height: 20.w,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check,
                        size: 12.sp,
                        color: Colors.white,
                      ),
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

String _formatPrice(OfferEntity offer) {
  final value = offer.priceAdult.round();
  final currency = offer.currency.trim();
  if (currency.isEmpty) {
    return '\$$value';
  }
  final isSymbol = currency.length == 1;
  return isSymbol ? '$currency$value' : '$currency $value';
}


