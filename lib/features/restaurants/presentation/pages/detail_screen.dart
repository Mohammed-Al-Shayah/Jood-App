import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/utils/extensions.dart';
import 'package:jood/features/restaurants/domain/entities/restaurant_entity.dart';
import '../cubit/restaurant_detail_cubit.dart';
import '../cubit/restaurant_detail_state.dart';
import '../widgets/detail_header.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({
    super.key,
    required this.id,
    required this.name,
    required this.meta,
    required this.rating,
    required this.image,
  });

  final String id;
  final String name;
  final String meta;
  final String rating;
  final Widget image;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<RestaurantDetailCubit>()..load(id),
      child: BlocBuilder<RestaurantDetailCubit, RestaurantDetailState>(
        builder: (context, state) {
          final details = state.restaurant;
          final ratingValue = details?.rating.toStringAsFixed(1) ?? rating;
          final reviewsLabel = details == null
              ? AppStrings.detailsReviewsCount
              : '${details.reviewsCount} reviews';
          final ratingLabel = '$ratingValue ($reviewsLabel)';
          final metaLabel = _metaLabel(details, meta);
          final openLabel =
              _openHoursLabel(details) ?? AppStrings.detailsOpenTime;
          final aboutText = _aboutLabel(details);
          final addressLabel = details?.address.isNotEmpty == true
              ? details!.address
              : AppStrings.detailsAddressValue;
          final highlights = _listOrFallback(
            details?.highlights,
            AppStrings.highlightsItems,
          );
          final inclusions = _listOrFallback(
            details?.inclusions,
            AppStrings.inclusionsItems,
          );
          final exclusions = _listOrFallback(
            details?.exclusions,
            AppStrings.exclusionsItems,
          );
          final cancellation = _listOrFallback(
            details?.cancellationPolicy,
            AppStrings.cancellationItems,
          );
          final knowBefore = _listOrFallback(
            details?.knowBeforeYouGo,
            AppStrings.knowBeforeItems,
          );

          return Scaffold(
            backgroundColor: Colors.white,
            bottomNavigationBar: Container(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.ctaShadow,
                    blurRadius: 16.r,
                    offset: Offset(0, -6.h),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      context.pushNamed(
                        Routes.selectDateTimeScreen,
                        arguments: SelectDateTimeArgs(
                          restaurantId: id,
                          name: details?.name ?? name,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      elevation: 0,
                    ),
                    child: Text(
                      AppStrings.checkAvailability,
                      style: AppTextStyles.cta,
                    ),
                  ),
                ),
              ),
            ),
            body: SafeArea(
              child: Skeletonizer(
                enabled: state.status == RestaurantDetailStatus.loading,
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DetailHeader(
                        image: image,
                        onBack: () => Navigator.of(context).pop(),
                        name: details?.name ?? name,
                        rating: ratingLabel,
                        meta: metaLabel,
                      ),
                      if (state.status == RestaurantDetailStatus.failure)
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Text(
                            state.errorMessage ?? 'Failed to load details.',
                            style: AppTextStyles.cardMeta,
                          ),
                        ),
                      SizedBox(height: 12.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 16.h),
                            Text(
                              AppStrings.about,
                              style: AppTextStyles.cardTitle,
                            ),
                            SizedBox(height: 10.h),
                            Text(
                              aboutText,
                              style: AppTextStyles.cardMeta.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            SizedBox(height: 16.h),
                            _InfoRow(
                              icon: Icons.schedule,
                              title: AppStrings.detailsOpenToday,
                              subtitle: openLabel,
                            ),
                            SizedBox(height: 12.h),
                            _InfoRow(
                              icon: Icons.location_on_outlined,
                              title: AppStrings.detailsAddressLabel,
                              subtitle: addressLabel,
                              trailingLabel: AppStrings.map,
                            ),
                            SizedBox(height: 18.h),
                            _DetailAccordion(
                              title: AppStrings.highlightsTitle,
                              items: highlights,
                            ),
                            _DetailAccordion(
                              title: AppStrings.inclusionsTitle,
                              items: inclusions,
                            ),
                            _DetailAccordion(
                              title: AppStrings.exclusionsTitle,
                              items: exclusions,
                            ),
                            _DetailAccordion(
                              title: AppStrings.cancellationTitle,
                              items: cancellation,
                            ),
                            _DetailAccordion(
                              title: AppStrings.knowBeforeTitle,
                              items: knowBefore,
                            ),
                            SizedBox(height: 12.h),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

String _metaLabel(RestaurantEntity? details, String fallback) {
  if (details == null) return fallback;
  final parts = <String>[];
  if (details.area.isNotEmpty) parts.add(details.area);
  if (details.cityId.isNotEmpty) parts.add(details.cityId);
  return parts.isEmpty ? fallback : parts.join(' • ');
}

String _aboutLabel(RestaurantEntity? details) {
  if (details == null) return AppStrings.aboutDescription;
  final about = details.about.trim();
  return about.isEmpty ? AppStrings.aboutDescription : about;
}

String? _openHoursLabel(RestaurantEntity? details) {
  if (details == null) return null;
  if (details.openFrom.isEmpty || details.openTo.isEmpty) return null;
  return '${details.openFrom} - ${details.openTo}';
}

List<String> _listOrFallback(List<String>? value, List<String> fallback) {
  if (value == null || value.isEmpty) return fallback;
  return value;
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailingLabel,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? trailingLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 18.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.cardMeta.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: AppTextStyles.cardMeta.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 13.sp,
                  ),
                ),
              ],
            ),
          ),
          if (trailingLabel != null)
            Text(
              trailingLabel!,
              style: AppTextStyles.cardPrice.copyWith(fontSize: 12.sp),
            ),
        ],
      ),
    );
  }
}

class _DetailAccordion extends StatelessWidget {
  const _DetailAccordion({required this.title, required this.items});

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 10.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
          childrenPadding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.h),
          iconColor: AppColors.textMuted,
          collapsedIconColor: AppColors.textMuted,
          title: Text(
            title,
            style: AppTextStyles.sectionTitle.copyWith(fontSize: 14.sp),
          ),
          children: items
              .map(
                (item) => Padding(
                  padding: EdgeInsets.only(top: 8.h),
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
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
