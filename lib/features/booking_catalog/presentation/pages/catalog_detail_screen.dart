import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/routing/catalog_route_args.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/bottom_cta_bar.dart';
import '../../domain/entities/catalog_category_type.dart';
import '../../domain/entities/catalog_item_entity.dart';
import '../widgets/catalog_image.dart';
import '../widgets/catalog_info_section.dart';

class CatalogDetailScreen extends StatelessWidget {
  const CatalogDetailScreen({super.key, required this.item});

  final CatalogItemEntity item;

  @override
  Widget build(BuildContext context) {
    final description = item.description.trim().isNotEmpty
        ? item.description.trim()
        : _fallbackDescription(item.category);

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomCtaBar(
        label: AppStrings.continueToBooking,
        onPressed: () {
          context.pushNamed(
            Routes.catalogBookingScreen,
            arguments: CatalogBookingArgs(item: item),
          );
        },
        backgroundColor: AppColors.cardBackground,
        shadowColor: AppColors.ctaShadow,
        textStyle: AppTextStyles.cta,
        buttonColor: AppColors.primary,
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            scrolledUnderElevation: 0,
            elevation: 0,
            pinned: true,
            expandedHeight: 252.h,
            toolbarHeight: kToolbarHeight,
            flexibleSpace: LayoutBuilder(
              builder: (context, constraints) {
                final topPadding = MediaQuery.of(context).padding.top;
                final minHeight = kToolbarHeight + topPadding;
                final maxHeight = 252.h;
                final progress =
                    ((constraints.biggest.height - minHeight) /
                            (maxHeight - minHeight))
                        .clamp(0.0, 1.0);
                final collapsedOpacity = 1.0 - progress;

                return Stack(
                  fit: StackFit.expand,
                  children: [
                    CatalogImage(
                      url: item.coverImageUrl,
                      name: item.name,
                      showLabel: false,
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.10),
                            Colors.black.withValues(alpha: 0.62),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: minHeight + 12.h,
                      child: IgnorePointer(
                        child: ColoredBox(
                          color: Colors.white.withValues(
                            alpha: collapsedOpacity,
                          ),
                        ),
                      ),
                    ),
                    PositionedDirectional(
                      top: topPadding + 8.h,
                      start: 12.w,
                      child: _HeaderBackButton(
                        onTap: () => Navigator.of(context).pop(),
                      ),
                    ),
                    PositionedDirectional(
                      top: topPadding + 16.h,
                      start: 60.w,
                      end: 16.w,
                      child: Opacity(
                        opacity: collapsedOpacity,
                        child: Text(
                          item.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.sectionTitle.copyWith(
                            fontSize: 16.sp,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    PositionedDirectional(
                      start: 16.w,
                      end: 16.w,
                      bottom: 16.h,
                      child: Opacity(
                        opacity: progress,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.cardTitle.copyWith(
                                color: Colors.white,
                                fontSize: 22.sp,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  color: AppColors.ratingStar,
                                  size: 14.sp,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  '${item.ratingLabel} (${AppStrings.reviewsCount(item.reviewsCount)})',
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
                                    item.metaLabel,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.cardMeta.copyWith(
                                      color: Colors.white.withValues(
                                        alpha: 0.9,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _aboutTitle(item.category),
                    style: AppTextStyles.cardTitle,
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    description,
                    style: AppTextStyles.cardMeta.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 13.sp,
                    ),
                  ),
                  SizedBox(height: 18.h),
                  CatalogInfoSection(
                    title: _highlightsTitle(item.category),
                    items: item.highlights,
                    emptyLabel:
                        AppStrings.highlightsWillAppearHereOnceConfigured,
                  ),
                  SizedBox(height: 12.h),
                  CatalogInfoSection(
                    title: AppStrings.whatsIncluded,
                    items: item.inclusions,
                    emptyLabel: AppStrings.includedDetailsWillAppearHere,
                  ),
                  SizedBox(height: 12.h),
                  if (item.category == CatalogCategoryType.attraction)
                    CatalogInfoSection(
                      title: AppStrings.packagesOverview,
                      items: item.packageOverview,
                      emptyLabel: AppStrings
                          .packagesWillBeLoadedFromAttractionConfiguration,
                    )
                  else
                    CatalogInfoSection(
                      title: AppStrings.availableOptions,
                      items: item.availableMeals,
                      emptyLabel: AppStrings
                          .optionsWillAppearAutomaticallyWhenConfigured,
                    ),
                  if (item.requiresMenuItemSelection ||
                      item.bookingNotes.isNotEmpty) ...[
                    SizedBox(height: 12.h),
                    Container(
                      padding: EdgeInsets.all(14.r),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.bookingNotes,
                            style: AppTextStyles.sectionTitle.copyWith(
                              fontSize: 14.sp,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          if (item.requiresMenuItemSelection)
                            Text(
                              AppStrings.bookingFlowSetMenuSelectionNote,
                              style: AppTextStyles.cardMeta.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 12.5.sp,
                              ),
                            ),
                          ...item.bookingNotes.map(
                            (note) => Padding(
                              padding: EdgeInsets.only(top: 8.h),
                              child: Text(
                                '- $note',
                                style: AppTextStyles.cardMeta.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 12.5.sp,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderBackButton extends StatelessWidget {
  const _HeaderBackButton({required this.onTap});

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
          child: IconTheme(
            data: IconThemeData(size: 18.sp, color: AppColors.textPrimary),
            child: const BackButtonIcon(),
          ),
        ),
      ),
    );
  }
}

String _fallbackDescription(CatalogCategoryType category) {
  switch (category) {
    case CatalogCategoryType.buffet:
      return AppStrings.buffetFallbackDescription;
    case CatalogCategoryType.setMenu:
      return AppStrings.setMenuFallbackDescription;
    case CatalogCategoryType.attraction:
      return AppStrings.attractionFallbackDescription;
  }
}

String _aboutTitle(CatalogCategoryType category) {
  return category == CatalogCategoryType.setMenu
      ? AppStrings.setMenuConcept
      : AppStrings.description;
}

String _highlightsTitle(CatalogCategoryType category) {
  return category == CatalogCategoryType.attraction
      ? AppStrings.highlightsTitle
      : AppStrings.experienceHighlights;
}
