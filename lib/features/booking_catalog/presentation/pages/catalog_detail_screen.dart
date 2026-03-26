import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/routing/catalog_route_args.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/bottom_cta_bar.dart';
import '../../../restaurants/presentation/widgets/detail_header.dart';
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DetailHeader(
                image: CatalogImage(
                  url: item.coverImageUrl,
                  name: item.name,
                  showLabel: false,
                ),
                onBack: () => Navigator.of(context).pop(),
                name: item.name,
                rating: '${item.ratingLabel} (${item.reviewsCount} reviews)',
                meta: item.metaLabel,
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 0),
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
                                  'â€¢ $note',
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
            ],
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
  return category == CatalogCategoryType.setMenu ? 'Set Menu Concept' : 'Description';
}

String _highlightsTitle(CatalogCategoryType category) {
  return category == CatalogCategoryType.attraction ? 'Highlights' : 'Experience Highlights';
}
