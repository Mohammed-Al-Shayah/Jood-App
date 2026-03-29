import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/routing/catalog_route_args.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
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
        label: 'Continue to Booking',
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
                final progress = ((constraints.biggest.height - minHeight) /
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
                          color: Colors.white.withValues(alpha: collapsedOpacity),
                        ),
                      ),
                    ),
                    Positioned(
                      top: topPadding + 8.h,
                      left: 12.w,
                      child: _HeaderBackButton(
                        onTap: () => Navigator.of(context).pop(),
                      ),
                    ),
                    Positioned(
                      top: topPadding + 16.h,
                      left: 60.w,
                      right: 16.w,
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
                    Positioned(
                      left: 16.w,
                      right: 16.w,
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
                                  '${item.ratingLabel} (${item.reviewsCount} reviews)',
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
                                      color: Colors.white.withValues(alpha: 0.9),
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
                    emptyLabel: 'Highlights will appear here once configured.',
                  ),
                  SizedBox(height: 12.h),
                  CatalogInfoSection(
                    title: "What's Included",
                    items: item.inclusions,
                    emptyLabel: 'Included details will appear here.',
                  ),
                  SizedBox(height: 12.h),
                  if (item.category == CatalogCategoryType.attraction)
                    CatalogInfoSection(
                      title: 'Packages Overview',
                      items: item.packageOverview,
                      emptyLabel:
                          'Packages will be loaded from attraction configuration.',
                    )
                  else
                    CatalogInfoSection(
                      title: 'Available Options',
                      items: item.availableMeals,
                      emptyLabel:
                          'Options will appear automatically when configured.',
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
                            'Booking Notes',
                            style: AppTextStyles.sectionTitle.copyWith(
                              fontSize: 14.sp,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          if (item.requiresMenuItemSelection)
                            Text(
                              'Set menu selection is currently treated as the priced booking option. Actual item choices can be completed later.',
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
          child: Icon(
            Icons.arrow_back,
            size: 18.sp,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

String _fallbackDescription(CatalogCategoryType category) {
  switch (category) {
    case CatalogCategoryType.buffet:
      return 'Explore a premium buffet experience with flexible meal-based booking and live availability.';
    case CatalogCategoryType.setMenu:
      return 'Choose a fixed set menu experience with clear pricing and a smooth booking flow.';
    case CatalogCategoryType.attraction:
      return 'Discover attraction experiences with time-based entry and package selection.';
  }
}

String _aboutTitle(CatalogCategoryType category) {
  return category == CatalogCategoryType.setMenu
      ? 'Set Menu Concept'
      : 'Description';
}

String _highlightsTitle(CatalogCategoryType category) {
  return category == CatalogCategoryType.attraction
      ? 'Highlights'
      : 'Experience Highlights';
}
