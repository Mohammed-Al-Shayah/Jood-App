import 'package:cached_network_image/cached_network_image.dart';
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
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import '../widgets/home_header.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/restaurant_card.dart';
import '../../../restaurants/domain/entities/restaurant_entity.dart';

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

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<HomeCubit>()
        ..fetchRestaurants()
        ..fetchUserLocation(),
      child: SafeArea(
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            if (state.status == HomeStatus.failure) {
              return Center(
                child: Text(
                  state.errorMessage ?? 'Failed to load restaurants.',
                  style: AppTextStyles.cardMeta,
                ),
              );
            }
            if (state.status == HomeStatus.empty) {
              return Center(
                child: Text(
                  'No restaurants available.',
                  style: AppTextStyles.cardMeta,
                ),
              );
            }
            final isLoading = state.status == HomeStatus.loading;
            final items = isLoading
                ? _skeletonRestaurants()
                : state.filteredRestaurants;
            final showEmptyFilter =
                !isLoading && state.restaurants.isNotEmpty && items.isEmpty;
            return Skeletonizer(
              enabled: isLoading,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          HomeHeader(
                            locationText: _locationLabel(
                              state.userCity,
                              state.userCountry,
                            ),
                            onFilterTap: () => _showSortSheet(context),
                          ),
                          SizedBox(height: 24.h),
                          HomeSearchBar(
                            onChanged: (value) =>
                                context.read<HomeCubit>().updateQuery(value),
                          ),
                          SizedBox(height: 24.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppStrings.sectionTitle,
                                style: AppTextStyles.sectionTitle,
                              ),
                              Text(
                                '${items.length} found',
                                style: AppTextStyles.sectionCount,
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          if (showEmptyFilter)
                            Padding(
                              padding: EdgeInsets.only(top: 12.h),
                              child: Text(
                                'No restaurants match your search.',
                                style: AppTextStyles.cardMeta,
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
                            meta: _metaLabel(item),
                            slots: item.slotsLeft,
                            rating: _formatRating(item.rating),
                            image: _RestaurantImage(
                              url: item.coverImageUrl,
                              name: item.name,
                              showLabel: false,
                            ),
                            onTap: isLoading
                                ? null
                                : () {
                                    context.pushNamed(
                                      Routes.detailScreen,
                                      arguments: DetailScreenArgs(
                                        id: item.id,
                                        name: item.name,
                                        meta: _metaLabel(item),
                                        rating: _formatRating(item.rating),
                                        image: _RestaurantImage(
                                          url: item.coverImageUrl,
                                          name: item.name,
                                          showLabel: false,
                                        ),
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
            );
          },
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

String _metaLabel(RestaurantEntity restaurant) {
  final parts = <String>[];
  if (restaurant.area.isNotEmpty) parts.add(restaurant.area);
  if (restaurant.cityId.isNotEmpty) parts.add(restaurant.cityId);
  if (parts.isNotEmpty) {
    return parts.join(' • ');
  }
  return restaurant.address;
}

String _formatRating(double rating) {
  if (rating <= 0) return '0.0';
  return rating.toStringAsFixed(1);
}

List<RestaurantEntity> _skeletonRestaurants() {
  return [
    RestaurantEntity(
      id: 'skeleton-1',
      name: 'Restaurant name',
      cityId: 'City',
      area: 'Area',
      rating: 4.6,
      reviewsCount: 0,
      coverImageUrl:
          'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=400&q=80',
      about: '',
      phone: '',
      address: '',
      geoLat: 0,
      geoLng: 0,
      openFrom: '',
      openTo: '',
      highlights: [],
      inclusions: [],
      exclusions: [],
      cancellationPolicy: [],
      knowBeforeYouGo: [],
      isActive: true,
      createdAt: DateTime(2000),
      badge: '20% off',
      priceFrom: r'$120',
      discount: r'$150',
      slotsLeft: '6 slots',
    ),
    RestaurantEntity(
      id: 'skeleton-2',
      name: 'Restaurant name',
      cityId: 'City',
      area: 'Area',
      rating: 4.5,
      reviewsCount: 0,
      coverImageUrl:
          'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=400&q=80',
      about: '',
      phone: '',
      address: '',
      geoLat: 0,
      geoLng: 0,
      openFrom: '',
      openTo: '',
      highlights: [],
      inclusions: [],
      exclusions: [],
      cancellationPolicy: [],
      knowBeforeYouGo: [],
      isActive: true,
      createdAt: DateTime(2000),
      badge: '15% off',
      priceFrom: r'$110',
      discount: r'$130',
      slotsLeft: '4 slots',
    ),
    RestaurantEntity(
      id: 'skeleton-3',
      name: 'Restaurant name',
      cityId: 'City',
      area: 'Area',
      rating: 4.4,
      reviewsCount: 0,
      coverImageUrl:
          'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=400&q=80',
      about: '',
      phone: '',
      address: '',
      geoLat: 0,
      geoLng: 0,
      openFrom: '',
      openTo: '',
      highlights: [],
      inclusions: [],
      exclusions: [],
      cancellationPolicy: [],
      knowBeforeYouGo: [],
      isActive: true,
      createdAt: DateTime(2000),
      badge: '10% off',
      priceFrom: r'$90',
      discount: r'$120',
      slotsLeft: '2 slots',
    ),
  ];
}

void _showSortSheet(BuildContext context) {
  final cubit = context.read<HomeCubit>();
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.cardBackground,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
    ),
    builder: (sheetContext) {
      return BlocProvider.value(
        value: cubit,
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            return Padding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Sort & order',
                          style: AppTextStyles.sectionTitle,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          context.read<HomeCubit>().updateSort(field: null);
                          Navigator.pop(sheetContext);
                        },
                        child: Text(
                          'Reset',
                          style: AppTextStyles.cardMeta.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Pick a field and the order you want.',
                    style: AppTextStyles.cardMeta,
                  ),
                  SizedBox(height: 16.h),
                  _SortGroup(
                    icon: Icons.attach_money,
                    title: 'Price',
                    subtitle: 'From lowest to highest or the opposite',
                    isSelected: state.sortField == SortField.price,
                    order: state.sortOrder,
                    onSelect: (order) {
                      context.read<HomeCubit>().updateSort(
                        field: SortField.price,
                        order: order,
                      );
                      Navigator.pop(sheetContext);
                    },
                  ),
                  SizedBox(height: 12.h),
                  _SortGroup(
                    icon: Icons.percent,
                    title: 'Discount',
                    subtitle: 'Based on percent or computed savings',
                    isSelected: state.sortField == SortField.discount,
                    order: state.sortOrder,
                    onSelect: (order) {
                      context.read<HomeCubit>().updateSort(
                        field: SortField.discount,
                        order: order,
                      );
                      Navigator.pop(sheetContext);
                    },
                  ),
                  SizedBox(height: 12.h),
                  _SortGroup(
                    icon: Icons.star_outline,
                    title: 'Rating',
                    subtitle: 'Higher rated restaurants first or last',
                    isSelected: state.sortField == SortField.rating,
                    order: state.sortOrder,
                    onSelect: (order) {
                      context.read<HomeCubit>().updateSort(
                        field: SortField.rating,
                        order: order,
                      );
                      Navigator.pop(sheetContext);
                    },
                  ),
                ],
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
                      label: 'Low → High',
                      selected: isSelected && order == SortOrder.asc,
                      onTap: () => onSelect(SortOrder.asc),
                    ),
                    SizedBox(width: 8.w),
                    _SortChip(
                      label: 'High → Low',
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
