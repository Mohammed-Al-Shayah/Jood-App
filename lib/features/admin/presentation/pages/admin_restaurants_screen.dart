import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:jood/core/di/service_locator.dart';
import 'package:jood/core/routing/routes.dart';
import 'package:jood/core/theming/app_colors.dart';
import 'package:jood/core/theming/app_text_styles.dart';
import 'package:jood/features/admin/presentation/cubit/admin_restaurants_cubit.dart';
import 'package:jood/features/admin/presentation/cubit/admin_restaurants_state.dart';
import 'package:jood/features/admin/presentation/widgets/admin_confirm_dialog.dart';
import 'package:jood/features/admin/presentation/widgets/admin_list_tile.dart';
import 'package:jood/features/admin/presentation/widgets/admin_shell.dart';
import 'package:jood/features/restaurants/domain/entities/restaurant_entity.dart';

class AdminRestaurantsScreen extends StatelessWidget {
  const AdminRestaurantsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AdminRestaurantsCubit>()..load(),
      child: Builder(
        builder: (context) {
          return AdminShell(
            title: 'Restaurants',
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.of(context).pushNamed(
                  Routes.adminRestaurantFormScreen,
                  arguments: const AdminRestaurantFormArgs(),
                );
                if (result is RestaurantEntity && context.mounted) {
                  context.read<AdminRestaurantsCubit>().create(result);
                }
              },
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
            ),
            body: BlocBuilder<AdminRestaurantsCubit, AdminRestaurantsState>(
              builder: (context, state) {
                final isLoading =
                    state.status == AdminRestaurantsStatus.loading;
                if (state.status == AdminRestaurantsStatus.failure) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.w),
                      child: Text(
                        state.errorMessage ?? 'Failed to load restaurants.',
                        style: AppTextStyles.cardMeta,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                final items =
                    isLoading ? _skeletonRestaurants() : state.restaurants;
                if (!isLoading && items.isEmpty) {
                  return Center(
                    child: Text(
                      'No restaurants yet.',
                      style: AppTextStyles.cardMeta,
                    ),
                  );
                }
                return Skeletonizer(
                  enabled: isLoading,
                  child: ListView.separated(
                    padding: EdgeInsets.fromLTRB(0, 12.h, 0, 80.h),
                    itemBuilder: (context, index) {
                      final restaurant = items[index];
                      return AdminListTile(
                        leading: _RestaurantThumb(url: restaurant.coverImageUrl),
                        title: restaurant.name,
                        subtitles: [
                          SizedBox(height: 4.h),
                          Text(
                            '${restaurant.cityId} - ${restaurant.area}',
                            style: AppTextStyles.cardMeta,
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            restaurant.isActive ? 'Active' : 'Inactive',
                            style: AppTextStyles.cardMeta.copyWith(
                              color: restaurant.isActive
                                  ? AppColors.primary
                                  : AppColors.textMuted,
                            ),
                          ),
                        ],
                        onTap: isLoading
                            ? null
                            : () async {
                                final result =
                                    await Navigator.of(context).pushNamed(
                                  Routes.adminRestaurantFormScreen,
                                  arguments: AdminRestaurantFormArgs(
                                    restaurant: restaurant,
                                  ),
                                );
                                if (result is RestaurantEntity &&
                                    context.mounted) {
                                  context
                                      .read<AdminRestaurantsCubit>()
                                      .update(result);
                                }
                              },
                        onDelete: isLoading
                            ? null
                            : () => _confirmDelete(context, restaurant),
                      );
                    },
                    separatorBuilder: (_, _) => SizedBox(height: 12.h),
                    itemCount: items.length,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    RestaurantEntity restaurant,
  ) async {
    final confirmed = await showAdminConfirmDialog(
      context: context,
      title: 'Delete restaurant',
      message: 'Delete ${restaurant.name}?',
    );
    if (confirmed == true && context.mounted) {
      context.read<AdminRestaurantsCubit>().delete(restaurant.id);
    }
  }
}

class _RestaurantThumb extends StatelessWidget {
  const _RestaurantThumb({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: 44.w,
      height: 44.w,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Icon(Icons.restaurant, color: AppColors.primary),
    );
    if (url.isEmpty) return placeholder;
    return ClipRRect(
      borderRadius: BorderRadius.circular(14.r),
      child: CachedNetworkImage(
        imageUrl: url,
        width: 44.w,
        height: 44.w,
        fit: BoxFit.cover,
        placeholder: (_, __) => placeholder,
        errorWidget: (_, __, ___) => placeholder,
      ),
    );
  }
}

List<RestaurantEntity> _skeletonRestaurants() {
  return List.generate(
    6,
    (index) => RestaurantEntity(
      id: 'skeleton-$index',
      name: 'Restaurant name',
      cityId: 'City',
      area: 'Area',
      rating: 4.5,
      reviewsCount: 0,
      coverImageUrl: '',
      about: '',
      phone: '',
      address: '',
      geoLat: 0,
      geoLng: 0,
      openFrom: '',
      openTo: '',
      highlights: const [],
      inclusions: const [],
      exclusions: const [],
      cancellationPolicy: const [],
      knowBeforeYouGo: const [],
      isActive: true,
      createdAt: DateTime(2000),
      badge: '',
      priceFrom: '',
      discount: '',
      slotsLeft: '',
    ),
  );
}

class AdminRestaurantFormArgs {
  const AdminRestaurantFormArgs({this.restaurant});

  final RestaurantEntity? restaurant;
}
