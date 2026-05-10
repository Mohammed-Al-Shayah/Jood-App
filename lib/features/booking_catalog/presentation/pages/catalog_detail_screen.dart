import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/routing/catalog_route_args.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/osm_geocoding_service.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/bottom_cta_bar.dart';
import '../../domain/entities/catalog_category_type.dart';
import '../../domain/entities/catalog_item_entity.dart';
import '../../../restaurants/presentation/pages/restaurant_map_screen.dart';
import '../widgets/catalog_image.dart';
import '../widgets/catalog_info_section.dart';

class CatalogDetailScreen extends StatelessWidget {
  const CatalogDetailScreen({super.key, required this.item});

  final CatalogItemEntity item;

  @override
  Widget build(BuildContext context) {
    final usesRestaurantStructuredSections = _usesRestaurantStructuredSections(
      item.category,
    );
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
                  if (usesRestaurantStructuredSections)
                    ..._buildRestaurantCategorySections(item)
                  else ...[
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
                        title: item.category == CatalogCategoryType.combo
                            ? AppStrings.availableCombos
                            : AppStrings.availableOptions,
                        items: item.availableMeals,
                        emptyLabel: AppStrings
                            .optionsWillAppearAutomaticallyWhenConfigured,
                      ),
                  ],
                  if (!usesRestaurantStructuredSections &&
                      item.category == CatalogCategoryType.attraction &&
                      (item.requiresMenuItemSelection ||
                          item.bookingNotes.isNotEmpty)) ...[
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
                              item.category == CatalogCategoryType.combo
                                  ? AppStrings.bookingFlowComboSelectionNote
                                  : AppStrings.bookingFlowSetMenuSelectionNote,
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
    case CatalogCategoryType.combo:
      return AppStrings.comboFallbackDescription;
    case CatalogCategoryType.attraction:
      return AppStrings.attractionFallbackDescription;
  }
}

String _aboutTitle(CatalogCategoryType category) {
  if (category == CatalogCategoryType.setMenu) {
    return AppStrings.setMenuConcept;
  }
  if (category == CatalogCategoryType.combo) {
    return AppStrings.comboConcept;
  }
  return AppStrings.description;
}

String _highlightsTitle(CatalogCategoryType category) {
  return category == CatalogCategoryType.attraction
      ? AppStrings.highlightsTitle
      : AppStrings.experienceHighlights;
}

bool _usesRestaurantStructuredSections(CatalogCategoryType category) {
  return category == CatalogCategoryType.buffet ||
      category == CatalogCategoryType.setMenu ||
      category == CatalogCategoryType.combo ||
      category == CatalogCategoryType.attraction;
}

List<Widget> _buildRestaurantCategorySections(CatalogItemEntity item) {
  final widgets = <Widget>[
    _BuffetLocationSection(item: item),
    SizedBox(height: 12.h),
  ];

  final sections = switch (item.category) {
    CatalogCategoryType.buffet => [
      _CatalogSectionConfig(
        title: AppStrings.whatsIncluded,
        items: item.inclusions,
      ),
      _CatalogSectionConfig(
        title: AppStrings.availableOptions,
        items: item.availableMeals,
        emptyLabel: AppStrings.optionsWillAppearAutomaticallyWhenConfigured,
        showWhenEmpty: true,
      ),
      _CatalogSectionConfig(
        title: AppStrings.experienceHighlights,
        items: item.highlights,
      ),
      _CatalogSectionConfig(
        title: AppStrings.whatsExcluded,
        items: item.exclusions,
      ),
      _CatalogSectionConfig(
        title: AppStrings.termsAndConditions,
        items: _termsItemsForCategory(item),
      ),
      _CatalogSectionConfig(
        title: AppStrings.cancellationTitle,
        items: item.cancellationPolicy,
      ),
    ],
    CatalogCategoryType.setMenu => [
      _CatalogSectionConfig(
        title: AppStrings.experienceHighlights,
        items: item.highlights,
      ),
      _CatalogSectionConfig(
        title: AppStrings.termsAndConditions,
        items: _termsItemsForCategory(item),
      ),
      _CatalogSectionConfig(
        title: AppStrings.whatsIncluded,
        items: item.inclusions,
      ),
      _CatalogSectionConfig(
        title: AppStrings.cancellationTitle,
        items: item.cancellationPolicy,
      ),
      _CatalogSectionConfig(
        title: AppStrings.availableOptions,
        items: item.availableMeals,
        emptyLabel: AppStrings.optionsWillAppearAutomaticallyWhenConfigured,
        showWhenEmpty: true,
      ),
    ],
    CatalogCategoryType.combo => [
      _CatalogSectionConfig(
        title: AppStrings.experienceHighlights,
        items: item.highlights,
      ),
      _CatalogSectionConfig(
        title: AppStrings.termsAndConditions,
        items: _termsItemsForCategory(item),
      ),
      _CatalogSectionConfig(
        title: AppStrings.whatsIncluded,
        items: item.inclusions,
      ),
      _CatalogSectionConfig(
        title: AppStrings.cancellationTitle,
        items: item.cancellationPolicy,
      ),
      _CatalogSectionConfig(
        title: AppStrings.availableCombos,
        items: item.availableMeals,
        emptyLabel: AppStrings.optionsWillAppearAutomaticallyWhenConfigured,
        showWhenEmpty: true,
      ),
    ],
    CatalogCategoryType.attraction => [
      _CatalogSectionConfig(
        title: AppStrings.experienceHighlights,
        items: item.highlights,
        emptyLabel: AppStrings.highlightsWillAppearHereOnceConfigured,
      ),
      _CatalogSectionConfig(
        title: AppStrings.termsAndConditions,
        items: _termsItemsForCategory(item),
      ),
      _CatalogSectionConfig(
        title: AppStrings.whatsIncluded,
        items: item.inclusions,
        emptyLabel: AppStrings.includedDetailsWillAppearHere,
      ),
      _CatalogSectionConfig(
        title: AppStrings.whatsExcluded,
        items: item.exclusions,
      ),
      _CatalogSectionConfig(
        title: AppStrings.cancellationTitle,
        items: item.cancellationPolicy,
      ),
      _CatalogSectionConfig(
        title: AppStrings.availableOptions,
        items: item.availableMeals,
        emptyLabel: AppStrings.optionsWillAppearAutomaticallyWhenConfigured,
      ),
    ],
  };

  final visibleSections = sections
      .where((section) => section.items.isNotEmpty || section.showWhenEmpty)
      .toList(growable: false);

  for (var index = 0; index < visibleSections.length; index++) {
    final section = visibleSections[index];
    widgets.add(
      CatalogInfoSection(
        title: section.title,
        items: section.items,
        emptyLabel: section.emptyLabel,
        collapsible: true,
        initiallyExpanded: false,
      ),
    );
    if (index != visibleSections.length - 1) {
      widgets.add(SizedBox(height: 12.h));
    }
  }
  return widgets;
}

List<String> _termsItemsForCategory(CatalogItemEntity item) {
  final items = <String>[];
  if (item.category == CatalogCategoryType.setMenu &&
      item.requiresMenuItemSelection) {
    items.add(AppStrings.bookingFlowSetMenuSelectionNote);
  }
  if (item.category == CatalogCategoryType.combo) {
    items.add(AppStrings.bookingFlowComboSelectionNote);
  }
  items.addAll(item.termsAndConditions);
  return _uniqueNonEmptyItems(items);
}

List<String> _uniqueNonEmptyItems(List<String> items) {
  final seen = <String>{};
  final result = <String>[];
  for (final item in items) {
    final normalized = item.trim();
    if (normalized.isEmpty) continue;
    if (seen.add(normalized)) {
      result.add(normalized);
    }
  }
  return result;
}

class _CatalogSectionConfig {
  const _CatalogSectionConfig({
    required this.title,
    required this.items,
    this.emptyLabel,
    this.showWhenEmpty = false,
  });

  final String title;
  final List<String> items;
  final String? emptyLabel;
  final bool showWhenEmpty;
}

class _BuffetLocationSection extends StatelessWidget {
  const _BuffetLocationSection({required this.item});

  final CatalogItemEntity item;

  @override
  Widget build(BuildContext context) {
    final summary = _locationSummary(item);
    final hasMapLocation = _hasUsableCoordinates(item.geoLat, item.geoLng);
    final canOpenMap = hasMapLocation || _locationLookupQuery(item).isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18.r),
        onTap: canOpenMap
            ? () => _openCatalogLocationMap(context, item)
            : null,
        child: Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [const Color(0xFFF1FBFA), AppColors.cardBackground],
            ),
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.18),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowColor,
                blurRadius: 14.r,
                offset: Offset(0, 6.h),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46.w,
                height: 46.w,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(15.r),
                ),
                child: Icon(
                  Icons.location_on_outlined,
                  color: AppColors.primaryDark,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            AppStrings.locationTitle,
                            style: AppTextStyles.sectionTitle.copyWith(
                              fontSize: 15.sp,
                            ),
                          ),
                        ),
                        Text(
                          AppStrings.map,
                          style: AppTextStyles.cardPrice.copyWith(
                            fontSize: 12.sp,
                            color: canOpenMap
                                ? AppColors.primary
                                : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      summary,
                      style: AppTextStyles.cardMeta.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 13.sp,
                        height: 1.45,
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

Future<void> _openCatalogLocationMap(
  BuildContext context,
  CatalogItemEntity item,
) async {
  if (!_hasUsableCoordinates(item.geoLat, item.geoLng)) {
    final query = _locationLookupQuery(item);
    if (query.isEmpty) {
      showAppSnackBar(
        context,
        AppStrings.unableToOpenMapForLocation,
        type: SnackBarType.error,
      );
      return;
    }

    try {
      final results = await OsmGeocodingService.searchPlaces(
        query,
        limit: 1,
        languageCode: Localizations.localeOf(context).languageCode,
      );
      if (!context.mounted) return;
      if (results.isEmpty) {
        showAppSnackBar(
          context,
          AppStrings.unableToOpenMapForLocation,
          type: SnackBarType.error,
        );
        return;
      }
      final point = results.first.point;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => RestaurantMapScreen(
            restaurantName: item.name,
            latitude: point.latitude,
            longitude: point.longitude,
          ),
        ),
      );
      return;
    } on OsmGeocodingException {
      if (!context.mounted) return;
      showAppSnackBar(
        context,
        AppStrings.unableToOpenMapForLocation,
        type: SnackBarType.error,
      );
      return;
    }
  }

  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => RestaurantMapScreen(
        restaurantName: item.name,
        latitude: item.geoLat,
        longitude: item.geoLng,
      ),
    ),
  );
}

bool _hasUsableCoordinates(double latitude, double longitude) {
  if (!latitude.isFinite || !longitude.isFinite) return false;
  if (latitude == 0 && longitude == 0) return false;
  return latitude >= -90 &&
      latitude <= 90 &&
      longitude >= -180 &&
      longitude <= 180;
}

String _locationSummary(CatalogItemEntity item) {
  final location = item.location.trim();
  if (location.isNotEmpty) return location;
  final address = item.address.trim();
  if (address.isNotEmpty) return address;
  final meta = item.metaLabel.trim();
  if (meta.isNotEmpty) return meta;
  return AppStrings.noDetailsAvailableYet;
}

String _locationLookupQuery(CatalogItemEntity item) {
  final parts = <String>[];
  final location = item.location.trim();
  final address = item.address.trim();
  final area = item.area.trim();
  final city = item.cityId.trim();
  if (location.isNotEmpty) parts.add(location);
  if (address.isNotEmpty && address != location) parts.add(address);
  if (area.isNotEmpty) parts.add(area);
  if (city.isNotEmpty && city != area) parts.add(city);
  return parts.join(', ');
}
