import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:jood/core/di/service_locator.dart';
import 'package:jood/core/theming/app_colors.dart';
import 'package:jood/core/theming/app_text_styles.dart';
import 'package:jood/core/widgets/app_snackbar.dart';
import 'package:jood/features/admin/presentation/cubit/admin_restaurants_cubit.dart';
import 'package:jood/features/admin/presentation/cubit/admin_restaurants_state.dart';
import 'package:jood/features/admin/presentation/web/widgets/admin_web_filter_dropdown_field.dart';
import 'package:jood/features/admin/presentation/web/widgets/admin_web_inline_form_view.dart';
import 'package:jood/features/admin/presentation/web/widgets/admin_web_metric_card.dart';
import 'package:jood/features/admin/presentation/web/widgets/admin_web_panel.dart';
import 'package:jood/features/admin/presentation/widgets/admin_confirm_dialog.dart';
import 'package:jood/features/admin/presentation/widgets/admin_restaurant_form_content.dart';
import 'package:jood/features/restaurants/domain/entities/restaurant_entity.dart';

class AdminWebRestaurantsPage extends StatefulWidget {
  const AdminWebRestaurantsPage({super.key});

  @override
  State<AdminWebRestaurantsPage> createState() =>
      _AdminWebRestaurantsPageState();
}

class _AdminWebRestaurantsPageState extends State<AdminWebRestaurantsPage> {
  late final AdminRestaurantsCubit _cubit;
  final TextEditingController _searchController = TextEditingController();
  String _statusFilter = 'all';
  String _cityFilter = 'all';
  _RestaurantsSort _sortBy = _RestaurantsSort.nameAsc;
  _RestaurantsView _view = _RestaurantsView.list;
  RestaurantEntity? _selectedRestaurant;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<AdminRestaurantsCubit>()..load();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    _cubit.close();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {});
  }

  void _openCreateForm() {
    setState(() {
      _view = _RestaurantsView.create;
      _selectedRestaurant = null;
    });
  }

  void _openEditForm(RestaurantEntity restaurant) {
    setState(() {
      _view = _RestaurantsView.edit;
      _selectedRestaurant = restaurant;
    });
  }

  Future<void> _confirmDelete(RestaurantEntity restaurant) async {
    final confirmed = await showAdminConfirmDialog(
      context: context,
      title: 'Delete restaurant',
      message: 'Delete ${restaurant.name}?',
    );
    if (confirmed != true) return;
    await _cubit.delete(restaurant.id);
  }

  void _closeForm() {
    setState(() {
      _view = _RestaurantsView.list;
      _selectedRestaurant = null;
    });
  }

  Future<void> _submitForm(RestaurantEntity restaurant) async {
    final isEdit = _view == _RestaurantsView.edit;
    if (isEdit) {
      await _cubit.update(restaurant);
    } else {
      await _cubit.create(restaurant);
    }
    if (!mounted) return;
    if (_cubit.state.status == AdminRestaurantsStatus.failure) {
      showAppSnackBar(
        context,
        _cubit.state.errorMessage ?? 'Failed to save restaurant.',
        type: SnackBarType.error,
      );
      return;
    }
    showAppSnackBar(
      context,
      isEdit
          ? 'Restaurant updated successfully.'
          : 'Restaurant created successfully.',
      type: SnackBarType.success,
    );
    _closeForm();
  }

  List<RestaurantEntity> _applyFilters(List<RestaurantEntity> items) {
    final query = _searchController.text.trim().toLowerCase();
    final filtered = items
        .where((restaurant) {
          final matchesStatus = switch (_statusFilter) {
            'active' => restaurant.isActive,
            'inactive' => !restaurant.isActive,
            _ => true,
          };
          if (!matchesStatus) return false;
          if (_cityFilter != 'all' &&
              restaurant.cityId.trim().toLowerCase() !=
                  _cityFilter.toLowerCase()) {
            return false;
          }
          if (query.isEmpty) return true;
          final haystack = [
            restaurant.name,
            restaurant.cityId,
            restaurant.area,
            restaurant.address,
          ].join(' ').toLowerCase();
          return haystack.contains(query);
        })
        .toList(growable: false);

    filtered.sort((a, b) {
      switch (_sortBy) {
        case _RestaurantsSort.nameAsc:
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        case _RestaurantsSort.nameDesc:
          return b.name.toLowerCase().compareTo(a.name.toLowerCase());
        case _RestaurantsSort.cityAsc:
          return a.cityId.toLowerCase().compareTo(b.cityId.toLowerCase());
        case _RestaurantsSort.ratingHigh:
          return b.rating.compareTo(a.rating);
        case _RestaurantsSort.ratingLow:
          return a.rating.compareTo(b.rating);
      }
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<AdminRestaurantsCubit, AdminRestaurantsState>(
        builder: (context, state) {
          if (_view != _RestaurantsView.list) {
            final isEdit = _view == _RestaurantsView.edit;
            return AdminWebInlineFormView(
              title: isEdit ? 'Edit restaurant' : 'Create restaurant',
              subtitle: isEdit
                  ? 'Update restaurant details and return to the venues list.'
                  : 'Add a new restaurant entry and return to the venues list.',
              onBack: _closeForm,
              backTooltip: 'Back to restaurants',
              child: AdminRestaurantFormContent(
                restaurant: _selectedRestaurant,
                padding: EdgeInsets.all(20.w),
                onSubmit: _submitForm,
              ),
            );
          }

          final filteredItems = _applyFilters(state.restaurants);
          final cityOptions =
              state.restaurants
                  .map((item) => item.cityId.trim())
                  .where((item) => item.isNotEmpty)
                  .toSet()
                  .toList()
                ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
          final activeCount = state.restaurants
              .where((item) => item.isActive)
              .length;
          final inactiveCount = state.restaurants.length - activeCount;

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final spacing = 16.w;
                  final columns = constraints.maxWidth >= 1000
                      ? 3
                      : constraints.maxWidth >= 680
                      ? 2
                      : 1;
                  final cardWidth = columns == 1
                      ? constraints.maxWidth
                      : (constraints.maxWidth - (spacing * (columns - 1))) /
                            columns;
                  return Wrap(
                    spacing: spacing,
                    runSpacing: 16.h,
                    children: [
                      SizedBox(
                        width: cardWidth,
                        child: AdminWebMetricCard(
                          title: 'Total venues',
                          value: '${state.restaurants.length}',
                          icon: Icons.storefront_outlined,
                          iconColor: const Color(0xFF2563EB),
                          caption: 'All restaurants in the catalog',
                        ),
                      ),
                      SizedBox(
                        width: cardWidth,
                        child: AdminWebMetricCard(
                          title: 'Active',
                          value: '$activeCount',
                          icon: Icons.check_circle_outline,
                          iconColor: const Color(0xFF0E9F6E),
                          caption: 'Visible to customers now',
                        ),
                      ),
                      SizedBox(
                        width: cardWidth,
                        child: AdminWebMetricCard(
                          title: 'Inactive',
                          value: '$inactiveCount',
                          icon: Icons.pause_circle_outline,
                          iconColor: const Color(0xFFF59E0B),
                          caption: 'Draft or hidden venues',
                        ),
                      ),
                    ],
                  );
                },
              ),
              SizedBox(height: 20.h),
              AdminWebPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _PageToolbar(
                      searchController: _searchController,
                      searchHint: 'Search by name, city, area, or address',
                      onRefresh: _cubit.load,
                      actionLabel: 'Add restaurant',
                      onActionPressed: _openCreateForm,
                      cityFilter: cityOptions.contains(_cityFilter)
                          ? _cityFilter
                          : 'all',
                      cityOptions: cityOptions,
                      sortBy: _sortBy,
                      onCityChanged: (value) =>
                          setState(() => _cityFilter = value),
                      onSortChanged: (value) => setState(() => _sortBy = value),
                    ),
                    SizedBox(height: 14.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: [
                        _FilterChip(
                          label: 'All',
                          selected: _statusFilter == 'all',
                          onTap: () => setState(() => _statusFilter = 'all'),
                        ),
                        _FilterChip(
                          label: 'Active',
                          selected: _statusFilter == 'active',
                          onTap: () => setState(() => _statusFilter = 'active'),
                        ),
                        _FilterChip(
                          label: 'Inactive',
                          selected: _statusFilter == 'inactive',
                          onTap: () =>
                              setState(() => _statusFilter = 'inactive'),
                        ),
                      ],
                    ),
                    SizedBox(height: 18.h),
                    if (state.status == AdminRestaurantsStatus.loading &&
                        state.restaurants.isEmpty)
                      const Center(child: CircularProgressIndicator())
                    else if (state.status == AdminRestaurantsStatus.failure)
                      _PanelMessage(
                        message:
                            state.errorMessage ?? 'Failed to load restaurants.',
                        isError: true,
                      )
                    else if (filteredItems.isEmpty)
                      const _PanelMessage(
                        message: 'No restaurants match the current filters.',
                      )
                    else
                      _RestaurantsTable(
                        items: filteredItems,
                        onEdit: _openEditForm,
                        onDelete: _confirmDelete,
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

enum _RestaurantsView { list, create, edit }

enum _RestaurantsSort { nameAsc, nameDesc, cityAsc, ratingHigh, ratingLow }

class _RestaurantsTable extends StatelessWidget {
  const _RestaurantsTable({
    required this.items,
    required this.onEdit,
    required this.onDelete,
  });

  final List<RestaurantEntity> items;
  final ValueChanged<RestaurantEntity> onEdit;
  final ValueChanged<RestaurantEntity> onDelete;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 24.w,
        headingRowHeight: 48.h,
        dataRowMinHeight: 68.h,
        dataRowMaxHeight: 76.h,
        columns: const [
          DataColumn(label: Text('Restaurant')),
          DataColumn(label: Text('Location')),
          DataColumn(label: Text('Open hours')),
          DataColumn(label: Text('Rating')),
          DataColumn(label: Text('Starting price')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Actions')),
        ],
        rows: items
            .map((restaurant) {
              return DataRow(
                cells: [
                  DataCell(
                    SizedBox(
                      width: 280.w,
                      child: Row(
                        children: [
                          _RestaurantThumb(url: restaurant.coverImageUrl),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  restaurant.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.sectionTitle.copyWith(
                                    fontSize: 14.sp,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  restaurant.id,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.cardMeta,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  DataCell(
                    SizedBox(
                      width: 180.w,
                      child: Text(
                        '${restaurant.cityId} - ${restaurant.area}',
                        style: AppTextStyles.cardMeta.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                    Text('${restaurant.openFrom} - ${restaurant.openTo}'),
                  ),
                  DataCell(Text(restaurant.rating.toStringAsFixed(1))),
                  DataCell(
                    Text(
                      restaurant.priceFrom.trim().isNotEmpty
                          ? restaurant.priceFrom
                          : 'OMR ${restaurant.priceFromValue.toStringAsFixed(2)}',
                    ),
                  ),
                  DataCell(
                    _StatusPill(
                      label: restaurant.isActive ? 'Active' : 'Inactive',
                      color: restaurant.isActive
                          ? const Color(0xFF0E9F6E)
                          : const Color(0xFFF59E0B),
                    ),
                  ),
                  DataCell(
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => onEdit(restaurant),
                          tooltip: 'Edit',
                          icon: const Icon(Icons.edit_outlined),
                        ),
                        IconButton(
                          onPressed: () => onDelete(restaurant),
                          tooltip: 'Delete',
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            })
            .toList(growable: false),
      ),
    );
  }
}

class _RestaurantThumb extends StatelessWidget {
  const _RestaurantThumb({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: 48.w,
      height: 48.w,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Icon(
        Icons.storefront_outlined,
        color: AppColors.primary,
        size: 22.sp,
      ),
    );
    if (url.trim().isEmpty) return placeholder;
    return ClipRRect(
      borderRadius: BorderRadius.circular(14.r),
      child: Image.network(
        url,
        width: 48.w,
        height: 48.w,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => placeholder,
      ),
    );
  }
}

class _PageToolbar extends StatelessWidget {
  const _PageToolbar({
    required this.searchController,
    required this.searchHint,
    required this.onRefresh,
    required this.actionLabel,
    required this.onActionPressed,
    required this.cityFilter,
    required this.cityOptions,
    required this.sortBy,
    required this.onCityChanged,
    required this.onSortChanged,
  });

  final TextEditingController searchController;
  final String searchHint;
  final Future<void> Function() onRefresh;
  final String actionLabel;
  final VoidCallback onActionPressed;
  final String cityFilter;
  final List<String> cityOptions;
  final _RestaurantsSort sortBy;
  final ValueChanged<String> onCityChanged;
  final ValueChanged<_RestaurantsSort> onSortChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final searchField = _SearchField(
          controller: searchController,
          hintText: searchHint,
        );
        final actions = Wrap(
          spacing: 10.w,
          runSpacing: 10.h,
          children: [
            OutlinedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Refresh'),
            ),
            ElevatedButton.icon(
              onPressed: onActionPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.add),
              label: Text(actionLabel),
            ),
          ],
        );
        final cityField = AdminWebFilterDropdownField<String>(
          label: 'City',
          value: cityFilter,
          items: [
            const DropdownMenuItem(value: 'all', child: Text('All cities')),
            ...cityOptions.map(
              (city) => DropdownMenuItem(value: city, child: Text(city)),
            ),
          ],
          onChanged: onCityChanged,
        );
        final sortField = AdminWebFilterDropdownField<_RestaurantsSort>(
          label: 'Sort by',
          value: sortBy,
          items: const [
            DropdownMenuItem(
              value: _RestaurantsSort.nameAsc,
              child: Text('Name A-Z'),
            ),
            DropdownMenuItem(
              value: _RestaurantsSort.nameDesc,
              child: Text('Name Z-A'),
            ),
            DropdownMenuItem(
              value: _RestaurantsSort.cityAsc,
              child: Text('City A-Z'),
            ),
            DropdownMenuItem(
              value: _RestaurantsSort.ratingHigh,
              child: Text('Rating high-low'),
            ),
            DropdownMenuItem(
              value: _RestaurantsSort.ratingLow,
              child: Text('Rating low-high'),
            ),
          ],
          onChanged: onSortChanged,
        );

        if (constraints.maxWidth < 1180) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              searchField,
              SizedBox(height: 12.h),
              cityField,
              SizedBox(height: 12.h),
              sortField,
              SizedBox(height: 12.h),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: actions,
              ),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: searchField),
            SizedBox(width: 12.w),
            SizedBox(width: 210.w, child: cityField),
            SizedBox(width: 12.w),
            SizedBox(width: 210.w, child: sortField),
            SizedBox(width: 12.w),
            Flexible(
              child: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: actions,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.hintText});

  final TextEditingController controller;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search_rounded),
        filled: true,
        fillColor: const Color(0xFFF6F7FB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.22),
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primary.withValues(alpha: 0.16),
      labelStyle: AppTextStyles.cardMeta.copyWith(
        color: selected ? AppColors.primaryDark : AppColors.textPrimary,
        fontWeight: FontWeight.w700,
      ),
      side: BorderSide(
        color: selected
            ? AppColors.primary.withValues(alpha: 0.18)
            : const Color(0xFFE5EAF1),
      ),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999.r)),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(
        label,
        style: AppTextStyles.cardMeta.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _PanelMessage extends StatelessWidget {
  const _PanelMessage({required this.message, this.isError = false});

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 18.h),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: AppTextStyles.cardMeta.copyWith(
            color: isError ? const Color(0xFFC62828) : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
