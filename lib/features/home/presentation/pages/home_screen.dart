import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../restaurant_detail/presentation/pages/detail_screen.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import '../widgets/home_header.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/restaurant_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<HomeCubit>()..fetchRestaurants(),
      child: Scaffold(
        backgroundColor: AppColors.cardBackground,
        body: SafeArea(
          child: BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              if (state.status == HomeStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }
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
              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const HomeHeader(),
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
                          '${state.restaurants.length} found',
                          style: AppTextStyles.sectionCount,
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    ...state.restaurants.map(
                      (item) => Padding(
                        padding: EdgeInsets.only(bottom: 14.h),
                        child: RestaurantCard(
                          name: item.name,
                          badge: item.badge,
                          price: item.priceFrom,
                          meta: item.meta,
                          slots: item.slotsLeft,
                          rating: item.rating,
                          image: _RestaurantImage(url: item.imageUrl, name: item.name),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => DetailScreen(
                                  name: item.name,
                                  meta: item.meta,
                                  rating: item.rating,
                                  image: _RestaurantImage(
                                    url: item.imageUrl,
                                    name: item.name,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _RestaurantImage extends StatelessWidget {
  const _RestaurantImage({required this.url, required this.name});

  final String url;
  final String name;

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return _ImagePlaceholder(label: name);
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _ImagePlaceholder(label: name),
      loadingBuilder: (_, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }
        return _ImagePlaceholder(label: name);
      },
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({required this.label});

  final String label;

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
        child: Text(
          label,
          style: AppTextStyles.sectionTitle.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
