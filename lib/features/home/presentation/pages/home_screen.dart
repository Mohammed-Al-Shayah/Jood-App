import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/routing/catalog_route_args.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/utils/extensions.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/restaurant_card.dart';
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

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_handleScroll);
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
            final showEmptyFilter =
                !isLoading && state.items.isNotEmpty && items.isEmpty;
            final showEmptyState =
                !isLoading && state.status == HomeStatus.empty;
            final locationText = _locationLabel(
              state.userCity,
              state.userCountry,
            );

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
                                    SizedBox(height: 24.h),
                                    Text(
                                      AppStrings.bookByCategory,
                                      style: AppTextStyles.sectionTitle,
                                    ),
                                    SizedBox(height: 6.h),
                                    Text(
                                      AppStrings.bookByCategorySubtitle,
                                      style: AppTextStyles.cardMeta.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    SizedBox(height: 14.h),
                                    SizedBox(
                                      height: 176.h,
                                      child: ListView(
                                        scrollDirection: Axis.horizontal,
                                        children: [
                                          CatalogCategoryCard(
                                            category:
                                                CatalogCategoryType.buffet,
                                            onTap: () {
                                              context.pushNamed(
                                                Routes.catalogListScreen,
                                                arguments:
                                                    const CatalogListArgs(
                                                      category:
                                                          CatalogCategoryType
                                                              .buffet,
                                                    ),
                                              );
                                            },
                                          ),
                                          SizedBox(width: 12.w),
                                          CatalogCategoryCard(
                                            category:
                                                CatalogCategoryType.setMenu,
                                            onTap: () {
                                              context.pushNamed(
                                                Routes.catalogListScreen,
                                                arguments:
                                                    const CatalogListArgs(
                                                      category:
                                                          CatalogCategoryType
                                                              .setMenu,
                                                    ),
                                              );
                                            },
                                          ),
                                          SizedBox(width: 12.w),
                                          CatalogCategoryCard(
                                            category:
                                                CatalogCategoryType.attraction,
                                            onTap: () {
                                              context.pushNamed(
                                                Routes.catalogListScreen,
                                                arguments:
                                                    const CatalogListArgs(
                                                      category:
                                                          CatalogCategoryType
                                                              .attraction,
                                                    ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 24.h),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          AppStrings.discoverForYou,
                                          style: AppTextStyles.sectionTitle,
                                        ),
                                        Text(
                                          AppStrings.itemsFound(items.length),
                                          style: AppTextStyles.sectionCount,
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 12.h),
                                    if (showEmptyFilter)
                                      Padding(
                                        padding: EdgeInsets.only(top: 12.h),
                                        child: Text(
                                          AppStrings.noItemsMatchSearch,
                                          style: AppTextStyles.cardMeta,
                                        ),
                                      ),
                                    if (showEmptyState)
                                      Padding(
                                        padding: EdgeInsets.only(top: 12.h),
                                        child: Center(
                                          child: Text(
                                            AppStrings.noItemsAvailableRightNow,
                                            style: AppTextStyles.cardMeta,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            SliverPadding(
                              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 20.h),
                              sliver: SliverList.builder(
                                itemCount: items.length,
                                itemBuilder: (context, index) {
                                  final item = items[index];
                                  return Padding(
                                    padding: EdgeInsets.only(bottom: 14.h),
                                    child: RestaurantCard(
                                      name: item.name,
                                      badge: item.badge,
                                      price: item.priceFrom,
                                      discount: item.discount,
                                      meta: _discoveryMetaLabel(item),
                                      slots: item.slotsLeft,
                                      rating: item.ratingLabel,
                                      image: _RestaurantImage(
                                        url: item.coverImageUrl,
                                        name: item.name,
                                        showLabel: false,
                                      ),
                                      onTap: isLoading
                                          ? null
                                          : () {
                                              context.pushNamed(
                                                Routes.catalogDetailScreen,
                                                arguments: CatalogDetailArgs(
                                                  item: item,
                                                ),
                                              );
                                            },
                                    ),
                                  );
                                },
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
      badge: '20% off',
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
      badge: '15% off',
      priceFrom: r'$110',
      discount: r'$130',
      slotsLeft: '4 slots',
      isActive: true,
    ),
    CatalogItemEntity(
      id: 'skeleton-3',
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
      badge: '10% off',
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
