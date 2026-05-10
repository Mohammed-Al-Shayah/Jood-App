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
import '../../../../core/utils/search_text_utils.dart';
import '../../../home/presentation/widgets/home_search_bar.dart';
import '../../../home/presentation/widgets/restaurant_card.dart';
import '../../domain/entities/catalog_category_type.dart';
import '../../domain/entities/catalog_item_entity.dart';
import '../../presentation/cubit/catalog_list_cubit.dart';
import '../../presentation/cubit/catalog_list_state.dart';
import '../widgets/catalog_image.dart';

class CatalogListScreen extends StatefulWidget {
  const CatalogListScreen({super.key, required this.category});

  final CatalogCategoryType category;

  @override
  State<CatalogListScreen> createState() => _CatalogListScreenState();
}

class _CatalogListScreenState extends State<CatalogListScreen> {
  String _query = '';

  void _handleQueryChanged(String value) {
    setState(() {
      _query = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<CatalogListCubit>()..load(widget.category),
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
                  _categoryText(widget.category, 'title'),
                  style: AppTextStyles.headingMedium,
                ),
                SizedBox(height: 4.h),
                Text(
                  _categoryText(widget.category, 'short_description'),
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
            final visibleItems = _filterCatalogItems(state.items, _query);
            final showSearchEmptyState =
                state.status == CatalogListStatus.success &&
                state.items.isNotEmpty &&
                visibleItems.isEmpty &&
                _query.trim().isNotEmpty;

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        HomeSearchBar(onChanged: _handleQueryChanged),
                        SizedBox(height: 14.h),
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
                        if (showSearchEmptyState)
                          Padding(
                            padding: EdgeInsets.only(top: 18.h),
                            child: Text(
                              AppStrings.noItemsMatchSearch,
                              style: AppTextStyles.cardMeta.copyWith(
                                fontSize: 14.sp,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        if (state.status == CatalogListStatus.success &&
                            state.items.isEmpty &&
                            !showSearchEmptyState)
                          Padding(
                            padding: EdgeInsets.only(top: 24.h),
                            child: Center(
                              child: Text(
                                _categoryText(widget.category, 'empty'),
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
                if (visibleItems.isNotEmpty)
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
                    sliver: SliverList.builder(
                      itemCount: visibleItems.length,
                      itemBuilder: (context, index) {
                        final item = visibleItems[index];
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

List<CatalogItemEntity> _filterCatalogItems(
  List<CatalogItemEntity> items,
  String query,
) {
  final trimmed = normalizeSearchText(query);
  if (trimmed.isEmpty) return items;

  return items
      .where((item) {
        final fields = <String>[
          item.name,
          item.nameEn,
          item.nameAr,
          item.area,
          item.areaEn,
          item.areaAr,
          item.cityId,
          item.cityIdEn,
          item.cityIdAr,
          item.address,
          item.addressEn,
          item.addressAr,
          item.description,
          item.descriptionEn,
          item.descriptionAr,
          item.location,
          item.locationEn,
          item.locationAr,
          item.metaLabel,
        ];

        return matchesSearchQuery(trimmed, fields);
      })
      .toList(growable: false);
}
