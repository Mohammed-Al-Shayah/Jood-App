import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/widgets/currency_amount_text.dart';

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
    final trimmedDiscount = discount.trim();
    final trimmedSlots = slots.trim();
    final strippedPrice = _stripFromPrice(trimmedPrice);
    final normalizedPrice = _normalizeDisplayedPrice(trimmedPrice);
    final normalizedDiscount = _normalizeDisplayedPrice(trimmedDiscount);
    final priceValue = _normalizeDisplayedPrice(strippedPrice);
    final hasFromLabel = strippedPrice != trimmedPrice;
    final hasBadge = badge.trim().isNotEmpty;
    final hasDualPrice = trimmedPrice.isNotEmpty && trimmedDiscount.isNotEmpty;
    final showNoOffersMessage =
        trimmedPrice.isEmpty &&
        trimmedDiscount.isEmpty &&
        trimmedSlots.isNotEmpty &&
        !hasBadge;

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
                    PositionedDirectional(
                      top: 12.h,
                      start: 12.w,
                      child: Container(
                        constraints: BoxConstraints(minHeight: 38.h),
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xff7c3aed),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          badge,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.badge.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 13.sp,
                            height: 1.1,
                          ),
                        ),
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
                        if (showNoOffersMessage)
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 10.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.discountBackground,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: CurrencyAmountInlineText(
                              text: trimmedSlots,
                              style: AppTextStyles.cardMeta.copyWith(
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.w600,
                                height: 1.4,
                              ),
                            ),
                          ),
                        if (hasDualPrice)
                          Wrap(
                            spacing: 8.w,
                            runSpacing: 4.h,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              if (hasFromLabel)
                                Text(
                                  AppStrings.from,
                                  style: AppTextStyles.cardSlots.copyWith(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              CurrencyAmountInlineText(
                                text: normalizedDiscount,
                                style: AppTextStyles.cardDiscount.copyWith(
                                  fontSize: 18.sp,
                                ),
                              ),
                              CurrencyAmountInlineText(
                                text: priceValue,
                                style: AppTextStyles.cardPrice.copyWith(
                                  fontSize: 16.sp,
                                  color: const Color(0xFF5D6875),
                                  fontWeight: FontWeight.w700,
                                  decoration: TextDecoration.lineThrough,
                                  decorationColor: const Color(0xFFE53935),
                                  decorationThickness: 2.6,
                                ),
                              ),
                            ],
                          ),

                        if (!hasDualPrice && trimmedPrice.isNotEmpty)
                          CurrencyAmountInlineText(
                            text: normalizedPrice,
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

String _stripFromPrice(String value) {
  final trimmed = value.trim();
  final localizedPrefix = AppStrings.from.trim();
  if (trimmed.startsWith(localizedPrefix)) {
    return trimmed.substring(localizedPrefix.length).trim();
  }

  const englishPrefix = 'From';
  if (trimmed.toLowerCase().startsWith(englishPrefix.toLowerCase())) {
    return trimmed.substring(englishPrefix.length).trim();
  }

  return trimmed;
}

String _normalizeDisplayedPrice(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return trimmed;

  // ignore: deprecated_member_use
  final match = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(trimmed);
  if (match == null) return trimmed;

  final parsed = double.tryParse(match.group(1)?.replaceAll(',', '') ?? '');
  if (parsed == null) return trimmed;

  return trimmed.replaceRange(
    match.start,
    match.end,
    parsed.toStringAsFixed(1),
  );
}
