part of 'home_tab.dart';

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
                                label: _homeDiscovery.localizedCategoryTitle(
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
                                label: _homeDiscovery.localizedCategoryTitle(
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
                                label: _homeDiscovery.localizedCategoryTitle(
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
                                label: _homeDiscovery.localizedCategoryTitle(
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
