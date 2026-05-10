import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/currency_amount_text.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/routing/catalog_route_args.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/search_text_utils.dart';
import '../../../ads/domain/entities/ad_entity.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import '../widgets/home_ads_carousel.dart';
import '../widgets/home_search_bar.dart';
import '../../../booking_catalog/domain/entities/catalog_item_entity.dart';
import '../../../booking_catalog/domain/entities/catalog_category_type.dart';
import '../../../booking_catalog/presentation/widgets/catalog_category_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.cardBackground,
      body: HomeTab(),
    );
  }
}

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  late final ScrollController _scrollController;
  bool _showScrollToTopButton = false;
  double? _userLatitude;
  double? _userLongitude;
  bool _isResolvingLocation = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_handleScroll);
    unawaited(_resolveUserLocation());
  }

  Future<void> _resolveUserLocation() async {
    if (_isResolvingLocation) return;
    _isResolvingLocation = true;
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled || !mounted) return;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever ||
          !mounted) {
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      if (!mounted) return;

      setState(() {
        _userLatitude = position.latitude;
        _userLongitude = position.longitude;
      });
    } catch (_) {
      // Keep fallback nearby logic when device location is unavailable.
    } finally {
      _isResolvingLocation = false;
    }
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    final shouldShow = _scrollController.offset > 260;
    if (shouldShow == _showScrollToTopButton) return;
    setState(() {
      _showScrollToTopButton = shouldShow;
    });
  }

  Future<void> _scrollToTop() async {
    if (!_scrollController.hasClients) return;
    await _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<HomeCubit>()
        ..fetchHomeItems()
        ..fetchUserLocation()
        ..startListening(),
      child: SafeArea(
        child: BlocBuilder<HomeCubit, HomeState>(
          buildWhen: (previous, current) {
            return previous.status != current.status ||
                previous.errorMessage != current.errorMessage ||
                previous.filteredItems != current.filteredItems ||
                previous.items != current.items ||
                previous.ads != current.ads ||
                previous.userCity != current.userCity ||
                previous.userCountry != current.userCountry;
          },
          builder: (context, state) {
            if (state.status == HomeStatus.failure) {
              return Center(
                child: Text(
                  state.errorMessage ?? AppStrings.failedToLoadDiscoveryItems,
                  style: AppTextStyles.cardMeta,
                ),
              );
            }

            final isLoading = state.status == HomeStatus.loading;
            final items = isLoading ? _skeletonItems() : state.filteredItems;
            final locationText = _locationLabel(
              state.userCity,
              state.userCountry,
            );
            final hotDeals = isLoading
                ? items.take(3).toList()
                : _hotDeals(items);
            final nearbyItems = isLoading
                ? items.take(3).toList()
                : _nearbyItems(
                    items,
                    userCity: state.userCity,
                    userCountry: state.userCountry,
                    userLatitude: _userLatitude,
                    userLongitude: _userLongitude,
                  );
            final categorySpacing = 12.w;
            const visibleCategoryCards = 3.25;
            final categoryCardWidth =
                ((MediaQuery.sizeOf(context).width -
                            (16.w * 2) -
                            (categorySpacing * 3)) /
                        visibleCategoryCards)
                    .clamp(96.w, 132.w)
                    .toDouble();

            return Skeletonizer(
              enabled: isLoading,
              child: Stack(
                children: [
                  Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 14.h),
                        child: ColoredBox(
                          color: AppColors.cardBackground,
                          child: _HomeTopBar(
                            locationText: locationText,
                            onScannerTap: () =>
                                context.pushNamed(Routes.orderQrScannerScreen),
                            onFilterTap: () => _showSortSheet(context),
                          ),
                        ),
                      ),
                      Expanded(
                        child: CustomScrollView(
                          controller: _scrollController,
                          slivers: [
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(
                                  16.w,
                                  16.h,
                                  16.w,
                                  0,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    HomeSearchBar(
                                      onChanged: (value) => context
                                          .read<HomeCubit>()
                                          .updateQuery(value),
                                    ),
                                    SizedBox(height: 18.h),
                                    if (isLoading)
                                      _HomeAdsSkeleton()
                                    else if (state.ads.isNotEmpty)
                                      HomeAdsCarousel(
                                        ads: state.ads,
                                        onTap: (ad) => _openAdTarget(
                                          context,
                                          ad,
                                          state.items,
                                        ),
                                      ),
                                    SizedBox(height: 24.h),
                                    _HomeSectionHeader(
                                      title: AppStrings.bookByCategory,
                                    ),
                                    SizedBox(height: 12.h),
                                    SizedBox(
                                      height: 110.h,
                                      child: ListView.separated(
                                        scrollDirection: Axis.horizontal,
                                        itemCount:
                                            CatalogCategoryType.values.length,
                                        separatorBuilder: (_, _) =>
                                            SizedBox(width: categorySpacing),
                                        itemBuilder: (context, index) {
                                          final category =
                                              CatalogCategoryType.values[index];
                                          return CatalogCategoryCard(
                                            category: category,
                                            width: categoryCardWidth,
                                            onTap: () {
                                              context.pushNamed(
                                                Routes.catalogListScreen,
                                                arguments: CatalogListArgs(
                                                  category: category,
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                    if (hotDeals.isNotEmpty) ...[
                                      SizedBox(height: 26.h),
                                      _HomeSectionHeader(
                                        title: AppStrings.hotDeals,
                                        trailing: AppStrings.itemsFound(
                                          hotDeals.length,
                                        ),
                                      ),
                                      SizedBox(height: 14.h),
                                      SizedBox(
                                        height: 272.h,
                                        child: ListView.separated(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: hotDeals.length,
                                          separatorBuilder: (_, _) =>
                                              SizedBox(width: 14.w),
                                          itemBuilder: (context, index) {
                                            final item = hotDeals[index];
                                            return _ShowcaseCard(
                                              item: item,
                                              width: 256.w,
                                              highlightDeal: true,
                                              onTap: isLoading
                                                  ? null
                                                  : () => _openItemDetails(
                                                      context,
                                                      item,
                                                    ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                    if (nearbyItems.isNotEmpty) ...[
                                      SizedBox(height: 26.h),
                                      _HomeSectionHeader(
                                        title: AppStrings.nearToMe,
                                        trailing: AppStrings.itemsFound(
                                          nearbyItems.length,
                                        ),
                                      ),
                                      SizedBox(height: 14.h),
                                      SizedBox(
                                        height: 236.h,
                                        child: ListView.separated(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: nearbyItems.length,
                                          separatorBuilder: (_, _) =>
                                              SizedBox(width: 14.w),
                                          itemBuilder: (context, index) {
                                            final item = nearbyItems[index];
                                            return _ShowcaseCard(
                                              item: item,
                                              width: 214.w,
                                              highlightDeal: false,
                                              onTap: isLoading
                                                  ? null
                                                  : () => _openItemDetails(
                                                      context,
                                                      item,
                                                    ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                    SizedBox(height: 20.h),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  PositionedDirectional(
                    end: 16.w,
                    bottom: 20.h,
                    child: IgnorePointer(
                      ignoring: !_showScrollToTopButton,
                      child: AnimatedSlide(
                        duration: const Duration(milliseconds: 220),
                        offset: _showScrollToTopButton
                            ? Offset.zero
                            : const Offset(0, 1.3),
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: _showScrollToTopButton ? 1 : 0,
                          child: _ScrollToTopButton(onTap: _scrollToTop),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

void _openItemDetails(BuildContext context, CatalogItemEntity item) {
  context.pushNamed(
    Routes.catalogDetailScreen,
    arguments: CatalogDetailArgs(item: item),
  );
}

void _openAdTarget(
  BuildContext context,
  AdEntity ad,
  List<CatalogItemEntity> items,
) {
  CatalogCategoryType? category;
  for (final value in CatalogCategoryType.values) {
    if (value.routeKey == ad.targetCategory) {
      category = value;
      break;
    }
  }
  if (category == null) {
    showAppSnackBar(
      context,
      'This ad is not linked to a valid category.',
      type: SnackBarType.error,
    );
    return;
  }

  CatalogItemEntity? targetItem;
  for (final item in items) {
    if (item.id == ad.targetVenueId && item.category == category) {
      targetItem = item;
      break;
    }
  }

  if (targetItem == null) {
    showAppSnackBar(
      context,
      'The selected offer is no longer available.',
      type: SnackBarType.error,
    );
    return;
  }

  context.pushNamed(
    Routes.catalogBookingScreen,
    arguments: CatalogBookingArgs(
      item: targetItem,
      preferredOfferId: ad.targetOfferId,
      preferredOfferDate: DateTime.tryParse(ad.targetOfferDate),
    ),
  );
}

class _ScrollToTopButton extends StatelessWidget {
  const _ScrollToTopButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      elevation: 8,
      shadowColor: AppColors.primary.withValues(alpha: 0.24),
      borderRadius: BorderRadius.circular(18.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.keyboard_arrow_up_rounded,
                color: Colors.white,
                size: 22.sp,
              ),
              SizedBox(width: 4.w),
              Text(
                AppStrings.top,
                style: AppTextStyles.cardMeta.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeSectionHeader extends StatelessWidget {
  const _HomeSectionHeader({required this.title, this.trailing});

  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(title, style: AppTextStyles.sectionTitle)),
        if (trailing != null && trailing!.trim().isNotEmpty) ...[
          SizedBox(width: 12.w),
          Padding(
            padding: EdgeInsets.only(top: 2.h),
            child: Text(trailing!, style: AppTextStyles.sectionCount),
          ),
        ],
      ],
    );
  }
}

class _HomeAdsSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 178.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
      ),
    );
  }
}

class _HomeTopBar extends StatelessWidget {
  const _HomeTopBar({
    required this.locationText,
    required this.onFilterTap,
    this.onScannerTap,
  });

  final String locationText;
  final VoidCallback onFilterTap;
  final VoidCallback? onScannerTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.location_on_outlined, color: AppColors.primary, size: 24.sp),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.currentLocation,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                locationText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 8.w),
        if (onScannerTap != null) ...[
          _HomeActionButton(
            size: 40.r,
            iconSize: 22.sp,
            icon: Icons.qr_code_scanner,
            onTap: onScannerTap!,
          ),
          SizedBox(width: 8.w),
        ],
        _HomeActionButton(
          size: 40.r,
          iconSize: 24.sp,
          icon: Icons.tune,
          onTap: onFilterTap,
        ),
      ],
    );
  }
}

class _HomeActionButton extends StatelessWidget {
  const _HomeActionButton({
    required this.size,
    required this.iconSize,
    required this.icon,
    required this.onTap,
  });

  final double size;
  final double iconSize;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(size / 2),
      onTap: onTap,
      child: Container(
        height: size,
        width: size,
        decoration: const BoxDecoration(
          color: AppColors.iconStroke,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.textPrimary, size: iconSize),
      ),
    );
  }
}

class _ShowcaseCard extends StatelessWidget {
  const _ShowcaseCard({
    required this.item,
    required this.width,
    required this.highlightDeal,
    this.onTap,
  });

  final CatalogItemEntity item;
  final double width;
  final bool highlightDeal;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final showNoOffersMessage = _showNoOffersTodayMessage(item);
    final price = showNoOffersMessage ? '' : item.priceFrom.trim();
    final discount = showNoOffersMessage ? '' : item.discount.trim();
    final originalPriceValue = _normalizeDisplayedPrice(_stripFromPrice(price));
    final currentPriceValue = _normalizeDisplayedPrice(discount);
    final hasDualPrice = price.isNotEmpty && discount.isNotEmpty;
    final discountPercent = _discountScore(item);
    final hasDiscountBadge = discountPercent > 0;
    final topEndLabel = hasDiscountBadge
        ? AppStrings.percentOff(discountPercent.round())
        : '';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22.r),
        child: Container(
          width: width,
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(22.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 14.r,
                spreadRadius: -3,
                offset: Offset(0, 9.h),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(22.r),
                      ),
                      child: SizedBox.expand(
                        child: _RestaurantImage(
                          url: item.coverImageUrl,
                          name: item.name,
                          showLabel: false,
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(22.r),
                          ),
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withValues(alpha: 0.02),
                              Colors.black.withValues(alpha: 0.18),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),
                    if (hasDiscountBadge)
                      PositionedDirectional(
                        top: 12.h,
                        end: 12.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 7.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF7C3AED,
                            ).withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(999.r),
                          ),
                          child: Text(
                            topEndLabel,
                            style: AppTextStyles.cardMeta.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 14.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.sectionTitle.copyWith(
                        fontSize: 17.sp,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      _discoveryMetaLabel(item),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.cardMeta,
                    ),
                    SizedBox(height: 12.h),
                    if (hasDualPrice) ...[
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 4.h,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          CurrencyAmountInlineText(
                            text: currentPriceValue,
                            style:
                                (highlightDeal
                                        ? AppTextStyles.cardDiscount
                                        : AppTextStyles.cardPrice)
                                    .copyWith(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                          ),
                          CurrencyAmountInlineText(
                            text: originalPriceValue,
                            style: AppTextStyles.cardMeta.copyWith(
                              color: const Color(0xFF5D6875),
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.lineThrough,
                              decorationColor: const Color(0xFFE53935),
                              decorationThickness: 2.4,
                            ),
                          ),
                        ],
                      ),
                    ] else if (price.isNotEmpty) ...[
                      CurrencyAmountInlineText(
                        text: originalPriceValue,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.cardPrice.copyWith(
                          fontSize: 16.sp,
                        ),
                      ),
                    ] else if (item.slotsLeft.trim().isNotEmpty) ...[
                      CurrencyAmountInlineText(
                        text: item.slotsLeft,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.cardMeta.copyWith(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w700,
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

class _RestaurantImage extends StatelessWidget {
  const _RestaurantImage({
    required this.url,
    required this.name,
    this.showLabel = true,
  });

  final String url;
  final String name;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return _ImagePlaceholder(label: showLabel ? name : null);
    }
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (_, _) => _ImagePlaceholder(label: showLabel ? name : null),
      errorWidget: (_, _, _) =>
          _ImagePlaceholder(label: showLabel ? name : null),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({required this.label});

  final String? label;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFEDF2F7), Color(0xFFDDE5F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: label == null || label!.isEmpty
            ? const SizedBox.shrink()
            : Text(
                label!,
                style: AppTextStyles.sectionTitle.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
      ),
    );
  }
}

String _locationLabel(String? city, String? country) {
  final safeCity = (city ?? '').trim();
  final safeCountry = (country ?? '').trim();
  if (safeCity.isEmpty && safeCountry.isEmpty) {
    return AppStrings.cityName;
  }
  if (safeCity.isEmpty) return safeCountry;
  if (safeCountry.isEmpty) return safeCity;
  return '$safeCity, $safeCountry';
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

  final match = _findNumberSpan(trimmed);
  if (match == null) return trimmed;

  final parsed = double.tryParse(match.value.replaceAll(',', ''));
  if (parsed == null) return trimmed;

  return trimmed.replaceRange(
    match.start,
    match.end,
    parsed.toStringAsFixed(1),
  );
}

List<CatalogItemEntity> _hotDeals(List<CatalogItemEntity> items) {
  final ranked = List<CatalogItemEntity>.from(items)
    ..sort(
      (left, right) => _discountScore(right).compareTo(_discountScore(left)),
    );

  final withDeals = ranked.where((item) => _discountScore(item) > 0).toList();
  final source = withDeals.isNotEmpty ? withDeals : ranked;
  return source.take(6).toList(growable: false);
}

List<CatalogItemEntity> _nearbyItems(
  List<CatalogItemEntity> items, {
  String? userCity,
  String? userCountry,
  double? userLatitude,
  double? userLongitude,
}) {
  if (userLatitude != null && userLongitude != null) {
    final ranked = _rankByDistance(
      items,
      latitude: userLatitude,
      longitude: userLongitude,
    );
    if (ranked.isNotEmpty) return ranked.take(6).toList(growable: false);
  }

  final normalizedCity = normalizeSearchText(userCity ?? '');
  final normalizedCountry = normalizeSearchText(userCountry ?? '');
  final matched = _nearbyTextMatchedItems(
    items,
    normalizedCity: normalizedCity,
    normalizedCountry: normalizedCountry,
  );

  final inferredOrigin = _inferOriginFromMatches(matched);
  if (inferredOrigin != null) {
    final ranked = _rankByDistance(
      items,
      latitude: inferredOrigin.latitude,
      longitude: inferredOrigin.longitude,
    );
    if (ranked.isNotEmpty) return ranked.take(6).toList(growable: false);
  }

  final source =
      matched.isNotEmpty ? matched : List<CatalogItemEntity>.from(items)
        ..sort((left, right) => right.rating.compareTo(left.rating));
  return source.take(6).toList(growable: false);
}

List<CatalogItemEntity> _rankByDistance(
  List<CatalogItemEntity> items, {
  required double latitude,
  required double longitude,
}) {
  final ranked = items.where(_hasUsableCoordinates).toList(growable: false)
    ..sort(
      (left, right) =>
          Geolocator.distanceBetween(
            latitude,
            longitude,
            left.geoLat,
            left.geoLng,
          ).compareTo(
            Geolocator.distanceBetween(
              latitude,
              longitude,
              right.geoLat,
              right.geoLng,
            ),
          ),
    );
  return ranked;
}

List<CatalogItemEntity> _nearbyTextMatchedItems(
  List<CatalogItemEntity> items, {
  required String normalizedCity,
  required String normalizedCountry,
}) {
  return items.where((item) {
    final fields = [
      item.cityId,
      item.cityIdEn,
      item.cityIdAr,
      item.area,
      item.areaEn,
      item.areaAr,
      item.address,
      item.addressEn,
      item.addressAr,
      item.location,
      item.locationEn,
      item.locationAr,
    ];
    final cityMatch =
        normalizedCity.isNotEmpty &&
        fields.any((field) => normalizeSearchText(field) == normalizedCity);
    final areaMatch =
        normalizedCity.isNotEmpty &&
        fields.any(
          (field) => normalizeSearchText(field).contains(normalizedCity),
        );
    final countryMatch =
        normalizedCountry.isNotEmpty &&
        fields.any(
          (field) => normalizeSearchText(field).contains(normalizedCountry),
        );
    return cityMatch || countryMatch || areaMatch;
  }).toList()..sort((left, right) {
    final leftScore = _nearbyTextScore(
      left,
      normalizedCity: normalizedCity,
      normalizedCountry: normalizedCountry,
    );
    final rightScore = _nearbyTextScore(
      right,
      normalizedCity: normalizedCity,
      normalizedCountry: normalizedCountry,
    );
    final scoreCompare = rightScore.compareTo(leftScore);
    if (scoreCompare != 0) return scoreCompare;
    return right.rating.compareTo(left.rating);
  });
}

_GeoPoint? _inferOriginFromMatches(List<CatalogItemEntity> matched) {
  final withCoordinates = matched
      .where(_hasUsableCoordinates)
      .toList(growable: false);
  if (withCoordinates.isEmpty) return null;

  var latitudeSum = 0.0;
  var longitudeSum = 0.0;
  for (final item in withCoordinates) {
    latitudeSum += item.geoLat;
    longitudeSum += item.geoLng;
  }
  return _GeoPoint(
    latitudeSum / withCoordinates.length,
    longitudeSum / withCoordinates.length,
  );
}

class _GeoPoint {
  const _GeoPoint(this.latitude, this.longitude);

  final double latitude;
  final double longitude;
}

int _nearbyTextScore(
  CatalogItemEntity item, {
  required String normalizedCity,
  required String normalizedCountry,
}) {
  final cityFields = [item.cityId, item.cityIdEn, item.cityIdAr]
      .map(normalizeSearchText)
      .where((value) => value.isNotEmpty)
      .toList(growable: false);
  final areaFields = [item.area, item.areaEn, item.areaAr]
      .map(normalizeSearchText)
      .where((value) => value.isNotEmpty)
      .toList(growable: false);
  final addressFields =
      [
            item.address,
            item.addressEn,
            item.addressAr,
            item.location,
            item.locationEn,
            item.locationAr,
          ]
          .map(normalizeSearchText)
          .where((value) => value.isNotEmpty)
          .toList(growable: false);

  var score = 0;
  if (normalizedCity.isNotEmpty) {
    if (cityFields.any((field) => field == normalizedCity)) {
      score += 100;
    }
    if (areaFields.any((field) => field.contains(normalizedCity))) {
      score += 50;
    }
    if (addressFields.any((field) => field.contains(normalizedCity))) {
      score += 25;
    }
  }
  if (normalizedCountry.isNotEmpty &&
      addressFields.any((field) => field.contains(normalizedCountry))) {
    score += 10;
  }
  return score;
}

bool _hasUsableCoordinates(CatalogItemEntity item) {
  final lat = item.geoLat;
  final lng = item.geoLng;
  if (lat == 0 && lng == 0) return false;
  return lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180;
}

double _discountScore(CatalogItemEntity item) {
  if (_showNoOffersTodayMessage(item)) return 0;

  final badgePercent = _extractPercent(item.badge);
  if (badgePercent > 0) return badgePercent;

  final original = _extractAmount(item.priceFrom);
  final current = _extractAmount(item.discount);
  if (original > 0 && current > 0 && original >= current) {
    return ((original - current) / original) * 100;
  }
  return 0;
}

double _extractPercent(String value) {
  final percentIndex = value.indexOf('%');
  if (percentIndex < 0) return 0;
  final match = _findNumberSpan(value.substring(0, percentIndex));
  return double.tryParse(match?.value ?? '') ?? 0;
}

double _extractAmount(String value) {
  final match = _findNumberSpan(value, allowComma: true);
  return double.tryParse(match?.value.replaceAll(',', '') ?? '') ?? 0;
}

_NumberSpan? _findNumberSpan(String value, {bool allowComma = false}) {
  int? start;
  for (var index = 0; index < value.length; index += 1) {
    final code = value.codeUnitAt(index);
    final isDigit = code >= 48 && code <= 57;
    final isSeparator = code == 46 || (allowComma && code == 44);
    if (isDigit || (start != null && isSeparator)) {
      start ??= index;
      continue;
    }
    if (start != null) {
      return _NumberSpan(start, index, value.substring(start, index));
    }
  }
  if (start == null) return null;
  return _NumberSpan(start, value.length, value.substring(start));
}

class _NumberSpan {
  const _NumberSpan(this.start, this.end, this.value);

  final int start;
  final int end;
  final String value;
}

bool _showNoOffersTodayMessage(CatalogItemEntity item) {
  return item.slotsLeft.trim() == AppStrings.noOffersTodayExploreOtherDates;
}

String _discoveryMetaLabel(CatalogItemEntity item) {
  final parts = <String>[_localizedCategoryTitle(item.category)];
  if (item.area.isNotEmpty) parts.add(item.area);
  if (item.cityId.isNotEmpty) parts.add(item.cityId);
  if (parts.isNotEmpty) {
    return parts.join(' | ');
  }
  return item.address;
}

String _localizedCategoryTitle(CatalogCategoryType category) {
  switch (category) {
    case CatalogCategoryType.buffet:
      return AppStrings.buffet;
    case CatalogCategoryType.setMenu:
      return AppStrings.setMenu;
    case CatalogCategoryType.combo:
      return AppStrings.comboCategory;
    case CatalogCategoryType.attraction:
      return AppStrings.attractions;
  }
}

List<CatalogItemEntity> _skeletonItems() {
  return [
    CatalogItemEntity(
      id: 'skeleton-1',
      category: CatalogCategoryType.buffet,
      bookingMode: CatalogCategoryType.buffet.bookingMode,
      sourceCollection: 'restaurants',
      name: 'Restaurant name',
      cityId: 'City',
      area: 'Area',
      address: '',
      rating: 4.6,
      reviewsCount: 0,
      coverImageUrl:
          'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=400&q=80',
      description: '',
      highlights: [],
      inclusions: [],
      availableMeals: [
        AppStrings.breakfast,
        AppStrings.lunch,
        AppStrings.dinner,
      ],
      packageOverview: const [],
      bookingNotes: const [],
      requiresMenuItemSelection: false,
      badge: AppStrings.percentOff(20),
      priceFrom: r'$120',
      discount: r'$150',
      slotsLeft: '6 slots',
      isActive: true,
    ),
    CatalogItemEntity(
      id: 'skeleton-2',
      category: CatalogCategoryType.setMenu,
      bookingMode: CatalogCategoryType.setMenu.bookingMode,
      sourceCollection: 'restaurants',
      name: 'Restaurant name',
      cityId: 'City',
      area: 'Area',
      address: '',
      rating: 4.5,
      reviewsCount: 0,
      coverImageUrl:
          'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=400&q=80',
      description: '',
      highlights: [],
      inclusions: [],
      availableMeals: [AppStrings.breakfastSetMenu, AppStrings.lunchSetMenu],
      packageOverview: const [],
      bookingNotes: const [],
      requiresMenuItemSelection: true,
      badge: AppStrings.percentOff(15),
      priceFrom: r'$110',
      discount: r'$130',
      slotsLeft: '4 slots',
      isActive: true,
    ),
    CatalogItemEntity(
      id: 'skeleton-3',
      category: CatalogCategoryType.combo,
      bookingMode: CatalogCategoryType.combo.bookingMode,
      sourceCollection: 'restaurants',
      name: 'Combo venue',
      cityId: 'City',
      area: 'Area',
      address: '',
      rating: 4.4,
      reviewsCount: 0,
      coverImageUrl:
          'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=400&q=80',
      description: '',
      highlights: [],
      inclusions: [],
      availableMeals: const ['10 pcs Broasted', 'Family Combo'],
      packageOverview: const [],
      bookingNotes: const [],
      requiresMenuItemSelection: false,
      badge: AppStrings.percentOff(10),
      priceFrom: r'$10',
      discount: r'$14',
      slotsLeft: '12 slots',
      isActive: true,
    ),
    CatalogItemEntity(
      id: 'skeleton-4',
      category: CatalogCategoryType.attraction,
      bookingMode: CatalogCategoryType.attraction.bookingMode,
      sourceCollection: 'attractions',
      name: 'Attraction name',
      cityId: 'City',
      area: 'Area',
      address: '',
      rating: 4.4,
      reviewsCount: 0,
      coverImageUrl:
          'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=400&q=80',
      description: '',
      highlights: [],
      inclusions: [],
      availableMeals: const [],
      packageOverview: [AppStrings.packageA, AppStrings.packageB],
      bookingNotes: const [],
      requiresMenuItemSelection: false,
      badge: AppStrings.percentOff(10),
      priceFrom: r'$90',
      discount: r'$120',
      slotsLeft: '2 slots',
      isActive: true,
    ),
  ];
}

void _showSortSheet(BuildContext context) {
  final cubit = context.read<HomeCubit>();
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.cardBackground,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
    ),
    builder: (sheetContext) {
      return BlocProvider.value(
        value: cubit,
        child:
            BlocSelector<
              HomeCubit,
              HomeState,
              ({
                SortField? sortField,
                SortOrder sortOrder,
                CatalogCategoryType? selectedCategory,
              })
            >(
              selector: (state) => (
                sortField: state.sortField,
                sortOrder: state.sortOrder,
                selectedCategory: state.selectedCategory,
              ),
              builder: (context, state) {
                return SafeArea(
                  top: false,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(sheetContext).size.height * 0.82,
                    ),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  AppStrings.sortAndFilter,
                                  style: AppTextStyles.sectionTitle,
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(sheetContext),
                                child: Text(
                                  AppStrings.done,
                                  style: AppTextStyles.cardMeta.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  context
                                      .read<HomeCubit>()
                                      .updateCategoryFilter(null);
                                  context.read<HomeCubit>().updateSort(
                                    field: null,
                                  );
                                },
                                child: Text(
                                  AppStrings.reset,
                                  style: AppTextStyles.cardMeta.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            AppStrings.filterByTypeThenPickSort,
                            style: AppTextStyles.cardMeta,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            AppStrings.type,
                            style: AppTextStyles.sectionTitle.copyWith(
                              fontSize: 14.sp,
                            ),
                          ),
                          SizedBox(height: 10.h),
                          Wrap(
                            spacing: 8.w,
                            runSpacing: 8.h,
                            children: [
                              _TypeChip(
                                label: AppStrings.all,
                                selected: state.selectedCategory == null,
                                onTap: () => context
                                    .read<HomeCubit>()
                                    .updateCategoryFilter(null),
                              ),
                              _TypeChip(
                                label: _localizedCategoryTitle(
                                  CatalogCategoryType.buffet,
                                ),
                                selected:
                                    state.selectedCategory ==
                                    CatalogCategoryType.buffet,
                                onTap: () => context
                                    .read<HomeCubit>()
                                    .updateCategoryFilter(
                                      CatalogCategoryType.buffet,
                                    ),
                              ),
                              _TypeChip(
                                label: _localizedCategoryTitle(
                                  CatalogCategoryType.setMenu,
                                ),
                                selected:
                                    state.selectedCategory ==
                                    CatalogCategoryType.setMenu,
                                onTap: () => context
                                    .read<HomeCubit>()
                                    .updateCategoryFilter(
                                      CatalogCategoryType.setMenu,
                                    ),
                              ),
                              _TypeChip(
                                label: _localizedCategoryTitle(
                                  CatalogCategoryType.attraction,
                                ),
                                selected:
                                    state.selectedCategory ==
                                    CatalogCategoryType.attraction,
                                onTap: () => context
                                    .read<HomeCubit>()
                                    .updateCategoryFilter(
                                      CatalogCategoryType.attraction,
                                    ),
                              ),
                              _TypeChip(
                                label: _localizedCategoryTitle(
                                  CatalogCategoryType.combo,
                                ),
                                selected:
                                    state.selectedCategory ==
                                    CatalogCategoryType.combo,
                                onTap: () => context
                                    .read<HomeCubit>()
                                    .updateCategoryFilter(
                                      CatalogCategoryType.combo,
                                    ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),
                          _SortGroup(
                            icon: Icons.attach_money,
                            title: AppStrings.price,
                            subtitle: AppStrings.priceSortSubtitle,
                            isSelected: state.sortField == SortField.price,
                            order: state.sortOrder,
                            onSelect: (order) {
                              context.read<HomeCubit>().updateSort(
                                field: SortField.price,
                                order: order,
                              );
                            },
                          ),
                          SizedBox(height: 12.h),
                          _SortGroup(
                            icon: Icons.percent,
                            title: AppStrings.discount,
                            subtitle: AppStrings.discountSortSubtitle,
                            isSelected: state.sortField == SortField.discount,
                            order: state.sortOrder,
                            onSelect: (order) {
                              context.read<HomeCubit>().updateSort(
                                field: SortField.discount,
                                order: order,
                              );
                            },
                          ),
                          SizedBox(height: 12.h),
                          _SortGroup(
                            icon: Icons.star_outline,
                            title: AppStrings.rating,
                            subtitle: AppStrings.ratingSortSubtitle,
                            isSelected: state.sortField == SortField.rating,
                            order: state.sortOrder,
                            onSelect: (order) {
                              context.read<HomeCubit>().updateSort(
                                field: SortField.rating,
                                order: order,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      );
    },
  );
}

class _SortGroup extends StatelessWidget {
  const _SortGroup({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.order,
    required this.onSelect,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final SortOrder order;
  final ValueChanged<SortOrder> onSelect;

  @override
  Widget build(BuildContext context) {
    final inactiveColor = AppColors.textMuted;
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.iconStroke,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 40.r,
            width: 40.r,
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.sectionTitle),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: AppTextStyles.cardMeta.copyWith(color: inactiveColor),
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    _SortChip(
                      label: AppStrings.lowToHigh,
                      selected: isSelected && order == SortOrder.asc,
                      onTap: () => onSelect(SortOrder.asc),
                    ),
                    SizedBox(width: 8.w),
                    _SortChip(
                      label: AppStrings.highToLow,
                      selected: isSelected && order == SortOrder.desc,
                      onTap: () => onSelect(SortOrder.desc),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  const _SortChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          label,
          style: AppTextStyles.cardMeta.copyWith(
            color: selected ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.shadowColor,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.cardMeta.copyWith(
            color: selected ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
