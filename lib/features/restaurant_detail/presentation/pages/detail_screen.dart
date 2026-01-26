import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/utils/app_strings.dart';
import '../widgets/availability_card.dart';
import '../widgets/buffet_option_card.dart';
import '../widgets/detail_header.dart';
import '../widgets/detail_info_card.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({
    super.key,
    required this.name,
    required this.meta,
    required this.rating,
    required this.image,
  });

  final String name;
  final String meta;
  final String rating;
  final Widget image;

  @override
  Widget build(BuildContext context) {
    final buffetOptions = [
      const BuffetOption(
        title: AppStrings.lunchBuffet,
        description: AppStrings.lunchBuffetDescription,
        oldPrice: AppStrings.lunchBuffetOldPrice,
        price: AppStrings.lunchBuffetPrice,
        badge: AppStrings.buffetDiscountBadge,
      ),
      const BuffetOption(
        title: AppStrings.dinnerBuffet,
        description: AppStrings.dinnerBuffetDescription,
        oldPrice: AppStrings.dinnerBuffetOldPrice,
        price: AppStrings.dinnerBuffetPrice,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.cardBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DetailHeader(
                image: image,
                onBack: () => Navigator.of(context).pop(),
              ),
              Transform.translate(
                offset: Offset(0, -22.h),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DetailInfoCard(
                        name: name,
                        meta: meta,
                        rating: rating,
                      ),
                      SizedBox(height: 14.h),
                      Text(AppStrings.about, style: AppTextStyles.sectionTitle),
                      SizedBox(height: 6.h),
                      Text(
                        AppStrings.aboutDescription,
                        style: AppTextStyles.cardMeta.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      const AvailabilityCard(),
                      SizedBox(height: 16.h),
                      Text(
                        AppStrings.buffetOptions,
                        style: AppTextStyles.sectionTitle,
                      ),
                      SizedBox(height: 10.h),
                      ...buffetOptions.map(
                        (option) => Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: BuffetOptionCard(option: option),
                        ),
                      ),
                      SizedBox(height: 8.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
