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
import '../../domain/entities/restaurant.dart';

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
                : state.restaurants;
            return Skeletonizer(
              enabled: isLoading,
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HomeHeader(
                      locationText: _locationLabel(
                        state.userCity,
                        state.userCountry,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    const HomeSearchBar(),
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
                    ...items.map(
                      (item) => Padding(
                        padding: EdgeInsets.only(bottom: 14.h),
                        child: RestaurantCard(
                          name: item.name,
                          badge: item.badge,
                          price: item.priceFrom,
                          discount: item.discount,
                          meta: item.meta,
                          slots: item.slotsLeft,
                          rating: item.rating,
                          image: _RestaurantImage(
                            url: item.imageUrl,
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
                                      meta: item.meta,
                                      rating: item.rating,
                                      image: _RestaurantImage(
                                        url: item.imageUrl,
                                        name: item.name,
                                        showLabel: false,
                                      ),
                                    ),
                                  );
                                },
                        ),
                      ),
                    ),
                  ],
                ),
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

List<Restaurant> _skeletonRestaurants() {
  return const [
    Restaurant(
      id: 'skeleton-1',
      name: 'Restaurant name',
      meta: 'City • Area',
      rating: '4.6',
      badge: '20% off',
      priceFrom: r'$120',
      discount: r'$150',
      slotsLeft: '6 slots',
      imageUrl:
          'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=400&q=80',
    ),
    Restaurant(
      id: 'skeleton-2',
      name: 'Restaurant name',
      meta: 'City • Area',
      rating: '4.5',
      badge: '15% off',
      priceFrom: r'$110',
      discount: r'$130',
      slotsLeft: '4 slots',
      imageUrl:
          'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=400&q=80',
    ),
    Restaurant(
      id: 'skeleton-3',
      name: 'Restaurant name',
      meta: 'City • Area',
      rating: '4.4',
      badge: '10% off',
      priceFrom: r'$90',
      discount: r'$120',
      slotsLeft: '2 slots',
      imageUrl:
          'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=400&q=80',
    ),
  ];
}
