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
import '../../../ads/domain/entities/ad_entity.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import '../utils/home_discovery_service.dart';
import '../widgets/home_ads_carousel.dart';
import '../widgets/home_search_bar.dart';
import '../../../booking_catalog/domain/entities/catalog_item_entity.dart';
import '../../../booking_catalog/domain/entities/catalog_category_type.dart';
import '../../../booking_catalog/presentation/widgets/catalog_category_card.dart';

part 'home_sort_sheet.dart';

final HomeDiscoveryService _homeDiscovery = HomeDiscoveryService(
  distanceBetween: Geolocator.distanceBetween,
);

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
            final items = isLoading
                ? _homeDiscovery.skeletonItems()
                : state.filteredItems;
            final locationText = _homeDiscovery.locationLabel(
              state.userCity,
              state.userCountry,
            );
            final hotDeals = isLoading
                ? items.take(3).toList()
                : _homeDiscovery.hotDeals(items);
            final nearbyItems = isLoading
                ? items.take(3).toList()
                : _homeDiscovery.nearbyItems(
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
    final showNoOffersMessage = _homeDiscovery.showNoOffersTodayMessage(item);
    final price = showNoOffersMessage ? '' : item.priceFrom.trim();
    final discount = showNoOffersMessage ? '' : item.discount.trim();
    final originalPriceValue = _homeDiscovery.normalizeDisplayedPrice(
      _homeDiscovery.stripFromPrice(price),
    );
    final currentPriceValue = _homeDiscovery.normalizeDisplayedPrice(discount);
    final hasDualPrice = price.isNotEmpty && discount.isNotEmpty;
    final discountPercent = _homeDiscovery.discountScore(item);
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
                      _homeDiscovery.discoveryMetaLabel(item),
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
