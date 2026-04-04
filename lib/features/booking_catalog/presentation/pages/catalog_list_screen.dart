import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/localization/app_localization_controller.dart';
import '../../../../core/routing/catalog_route_args.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theming/app_colors.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/extensions.dart';
import '../../../home/presentation/widgets/restaurant_card.dart';
import '../../domain/entities/catalog_category_type.dart';
import '../../presentation/cubit/catalog_list_cubit.dart';
import '../../presentation/cubit/catalog_list_state.dart';
import '../widgets/catalog_image.dart';

class CatalogListScreen extends StatelessWidget {
  const CatalogListScreen({super.key, required this.category});

  final CatalogCategoryType category;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<CatalogListCubit>()..load(category),
      child: Scaffold(
        backgroundColor: AppColors.cardBackground,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(76.h),
          child: AppBar(
            backgroundColor: AppColors.cardBackground,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            toolbarHeight: 76.h,
            leadingWidth: 44.w,
            titleSpacing: 0,
            leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              color: AppColors.textPrimary,
              iconSize: 18.sp,
              icon: const BackButtonIcon(),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _categoryText(category, 'title'),
                  style: AppTextStyles.headingMedium,
                ),
                SizedBox(height: 4.h),
                Text(
                  _categoryText(category, 'short_description'),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.cardMeta.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12.5.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
        body: BlocBuilder<CatalogListCubit, CatalogListState>(
          builder: (context, state) {
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (state.status == CatalogListStatus.loading)
                          const LinearProgressIndicator(
                            color: AppColors.primary,
                          ),
                        if (state.status == CatalogListStatus.failure)
                          Padding(
                            padding: EdgeInsets.only(top: 18.h),
                            child: Text(
                              state.errorMessage ??
                                  AppStrings.failedToLoadCategoryItems,
                              style: AppTextStyles.cardMeta,
                            ),
                          ),
                        if (state.status == CatalogListStatus.success &&
                            state.items.isEmpty)
                          Padding(
                            padding: EdgeInsets.only(top: 24.h),
                            child: Center(
                              child: Text(
                                _categoryText(category, 'empty'),
                                style: AppTextStyles.cardMeta.copyWith(
                                  fontSize: 14.sp,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                if (state.items.isNotEmpty)
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
                    sliver: SliverList.builder(
                      itemCount: state.items.length,
                      itemBuilder: (context, index) {
                        final item = state.items[index];
                        return Padding(
                          padding: EdgeInsets.only(bottom: 14.h),
                          child: RestaurantCard(
                            name: item.name,
                            badge: item.badge,
                            price: item.priceFrom,
                            discount: item.discount,
                            meta: item.metaLabel,
                            slots: item.slotsLeft,
                            rating: item.ratingLabel,
                            image: CatalogImage(
                              url: item.coverImageUrl,
                              name: item.name,
                              showLabel: false,
                            ),
                            onTap: () {
                              context.pushNamed(
                                Routes.catalogDetailScreen,
                                arguments: CatalogDetailArgs(item: item),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

String _categoryText(CatalogCategoryType category, String suffix) {
  return AppLocalizationController.instance.tr(
    'catalog_category_${category.routeKey}_$suffix',
  );
}
