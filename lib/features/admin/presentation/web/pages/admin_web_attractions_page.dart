import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:jood/core/di/service_locator.dart';
import 'package:jood/core/theming/app_colors.dart';
import 'package:jood/core/theming/app_text_styles.dart';
import 'package:jood/core/utils/search_text_utils.dart';
import 'package:jood/core/widgets/app_snackbar.dart';
import 'package:jood/features/admin/presentation/cubit/admin_attractions_cubit.dart';
import 'package:jood/features/admin/presentation/cubit/admin_attractions_state.dart';
import 'package:jood/features/admin/presentation/web/widgets/admin_web_filter_dropdown_field.dart';
import 'package:jood/features/admin/presentation/web/widgets/admin_web_metric_card.dart';
import 'package:jood/features/admin/presentation/web/widgets/admin_web_panel.dart';
import 'package:jood/features/admin/presentation/widgets/admin_attraction_form_content.dart';
import 'package:jood/features/admin/presentation/widgets/admin_confirm_dialog.dart';
import 'package:jood/features/attractions/domain/entities/attraction_entity.dart';

class AdminWebAttractionsPage extends StatefulWidget {
  const AdminWebAttractionsPage({super.key});

  @override
  State<AdminWebAttractionsPage> createState() =>
      _AdminWebAttractionsPageState();
}

class _AdminWebAttractionsPageState extends State<AdminWebAttractionsPage> {
  late final AdminAttractionsCubit _cubit;
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedAttractionIds = <String>{};
  String _statusFilter = 'all';
  String _cityFilter = 'all';
  _AttractionsSort _sortBy = _AttractionsSort.nameAsc;
  _AttractionsView _view = _AttractionsView.list;
  AttractionEntity? _selectedAttraction;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<AdminAttractionsCubit>()..load();
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
      _view = _AttractionsView.create;
      _selectedAttraction = null;
    });
  }

  void _openEditForm(AttractionEntity attraction) {
    setState(() {
      _view = _AttractionsView.edit;
      _selectedAttraction = attraction;
    });
  }

  Future<void> _confirmDelete(AttractionEntity attraction) async {
    final confirmed = await showAdminConfirmDialog(
      context: context,
      title: 'Delete attraction',
      message: 'Delete ${attraction.name}? This also removes related offers.',
    );
    if (confirmed != true) return;
    await _cubit.delete(attraction.id);
    if (!mounted) return;
    setState(() {
      _selectedAttractionIds.remove(attraction.id);
    });
  }

  void _toggleAttractionSelection(String id, bool selected) {
    setState(() {
      if (selected) {
        _selectedAttractionIds.add(id);
      } else {
        _selectedAttractionIds.remove(id);
      }
    });
  }

  void _toggleSelectAllAttractions(List<AttractionEntity> items) {
    final ids = items.map((item) => item.id).toList(growable: false);
    final allSelected =
        ids.isNotEmpty &&
        ids.every((id) => _selectedAttractionIds.contains(id));
    setState(() {
      if (allSelected) {
        _selectedAttractionIds.removeAll(ids);
      } else {
        _selectedAttractionIds.addAll(ids);
      }
    });
  }

  Future<void> _confirmDeleteSelectedAttractions(
    List<AttractionEntity> items,
  ) async {
    final selectedIds = items
        .map((item) => item.id)
        .where(_selectedAttractionIds.contains)
        .toList(growable: false);
    if (selectedIds.isEmpty) return;
    final confirmed = await showAdminConfirmDialog(
      context: context,
      title: 'Delete attractions',
      message: 'Delete ${selectedIds.length} selected attractions?',
    );
    if (confirmed != true) return;
    for (final id in selectedIds) {
      await _cubit.delete(id);
    }
    if (!mounted) return;
    setState(() {
      _selectedAttractionIds.removeAll(selectedIds);
    });
  }

  void _closeForm() {
    setState(() {
      _view = _AttractionsView.list;
      _selectedAttraction = null;
    });
  }

  Future<void> _submitForm(AttractionEntity attraction) async {
    final isEdit = _view == _AttractionsView.edit;
    if (isEdit) {
      await _cubit.update(attraction);
    } else {
      await _cubit.create(attraction);
    }
    if (!mounted) return;
    if (_cubit.state.status == AdminAttractionsStatus.failure) {
      showAppSnackBar(
        context,
        _cubit.state.errorMessage ?? 'Failed to save attraction.',
        type: SnackBarType.error,
      );
      return;
    }
    showAppSnackBar(
      context,
      isEdit
          ? 'Attraction updated successfully.'
          : 'Attraction created successfully.',
      type: SnackBarType.success,
    );
    _closeForm();
  }

  List<AttractionEntity> _applyFilters(List<AttractionEntity> items) {
    final query = normalizeSearchText(_searchController.text);
    final filtered = items
        .where((attraction) {
          final matchesStatus = switch (_statusFilter) {
            'active' => attraction.isActive,
            'inactive' => !attraction.isActive,
            _ => true,
          };
          if (!matchesStatus) return false;
          if (_cityFilter != 'all' &&
              normalizeSearchText(attraction.cityId) !=
                  normalizeSearchText(_cityFilter)) {
            return false;
          }
          if (query.isEmpty) return true;
          return matchesSearchQuery(query, [
            attraction.name,
            attraction.nameEn,
            attraction.nameAr,
            attraction.cityId,
            attraction.cityIdEn,
            attraction.cityIdAr,
            attraction.area,
            attraction.areaEn,
            attraction.areaAr,
            attraction.address,
            attraction.addressEn,
            attraction.addressAr,
            attraction.about,
            attraction.aboutEn,
            attraction.aboutAr,
          ]);
        })
        .toList(growable: false);

    filtered.sort((a, b) {
      switch (_sortBy) {
        case _AttractionsSort.nameAsc:
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        case _AttractionsSort.nameDesc:
          return b.name.toLowerCase().compareTo(a.name.toLowerCase());
        case _AttractionsSort.cityAsc:
          return a.cityId.toLowerCase().compareTo(b.cityId.toLowerCase());
        case _AttractionsSort.ratingHigh:
          return b.rating.compareTo(a.rating);
        case _AttractionsSort.ratingLow:
          return a.rating.compareTo(b.rating);
      }
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<AdminAttractionsCubit, AdminAttractionsState>(
        builder: (context, state) {
          if (_view != _AttractionsView.list) {
            final isEdit = _view == _AttractionsView.edit;
            return _AttractionFormView(
              attraction: _selectedAttraction,
              title: isEdit ? 'Edit attraction' : 'Create attraction',
              subtitle: isEdit
                  ? 'Update attraction content and visibility, then return to the list.'
                  : 'Add a new attraction entry and return to the attractions list.',
              onBack: _closeForm,
              onSubmit: _submitForm,
            );
          }

          final filteredItems = _applyFilters(state.attractions);
          _selectedAttractionIds.removeWhere(
            (id) => !state.attractions.any((item) => item.id == id),
          );
          final selectedInViewCount = filteredItems
              .where((item) => _selectedAttractionIds.contains(item.id))
              .length;
          final allFilteredSelected =
              filteredItems.isNotEmpty &&
              selectedInViewCount == filteredItems.length;
          final cityOptions =
              state.attractions
                  .map((item) => item.cityId.trim())
                  .where((item) => item.isNotEmpty)
                  .toSet()
                  .toList()
                ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
          final activeCount = state.attractions
              .where((item) => item.isActive)
              .length;
          final inactiveCount = state.attractions.length - activeCount;

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
                          title: 'Total attractions',
                          value: '${state.attractions.length}',
                          icon: Icons.local_activity_outlined,
                          iconColor: const Color(0xFF2563EB),
                          caption: 'Standalone attraction venues in catalog',
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
                          caption: 'Hidden or draft attraction entries',
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
                      onRefresh: _cubit.load,
                      onActionPressed: _openCreateForm,
                      onToggleSelectAll: () =>
                          _toggleSelectAllAttractions(filteredItems),
                      onDeleteSelected: () =>
                          _confirmDeleteSelectedAttractions(filteredItems),
                      hasSelection: selectedInViewCount > 0,
                      allVisibleSelected: allFilteredSelected,
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
                    if (state.status == AdminAttractionsStatus.loading &&
                        state.attractions.isEmpty)
                      const Center(child: CircularProgressIndicator())
                    else if (state.status == AdminAttractionsStatus.failure)
                      _PanelMessage(
                        message:
                            state.errorMessage ?? 'Failed to load attractions.',
                        isError: true,
                      )
                    else if (filteredItems.isEmpty)
                      const _PanelMessage(
                        message: 'No attractions match the current filters.',
                      )
                    else
                      _AttractionsTable(
                        items: filteredItems,
                        onEdit: _openEditForm,
                        onDelete: _confirmDelete,
                        selectedIds: _selectedAttractionIds,
                        onSelectionChanged: _toggleAttractionSelection,
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

enum _AttractionsView { list, create, edit }

enum _AttractionsSort { nameAsc, nameDesc, cityAsc, ratingHigh, ratingLow }

class _AttractionFormView extends StatelessWidget {
  const _AttractionFormView({
    required this.attraction,
    required this.title,
    required this.subtitle,
    required this.onBack,
    required this.onSubmit,
  });

  final AttractionEntity? attraction;
  final String title;
  final String subtitle;
  final VoidCallback onBack;
  final Future<void> Function(AttractionEntity attraction) onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: onBack,
              tooltip: 'Back to attractions',
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.textPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.cardTitle.copyWith(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    subtitle,
                    style: AppTextStyles.cardMeta.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 18.h),
        Expanded(
          child: AdminWebPanel(
            padding: EdgeInsets.zero,
            child: AdminAttractionFormContent(
              attraction: attraction,
              padding: EdgeInsets.all(20.w),
              onSubmit: onSubmit,
            ),
          ),
        ),
      ],
    );
  }
}

class _AttractionsTable extends StatelessWidget {
  const _AttractionsTable({
    required this.items,
    required this.onEdit,
    required this.onDelete,
    required this.selectedIds,
    required this.onSelectionChanged,
  });

  final List<AttractionEntity> items;
  final ValueChanged<AttractionEntity> onEdit;
  final ValueChanged<AttractionEntity> onDelete;
  final Set<String> selectedIds;
  final void Function(String id, bool selected) onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        showCheckboxColumn: false,
        columnSpacing: 24.w,
        headingRowHeight: 48.h,
        dataRowMinHeight: 68.h,
        dataRowMaxHeight: 82.h,
        columns: [
          DataColumn(
            label: SizedBox(
              width: 28.w,
              child: const Icon(Icons.check_box_outline_blank, size: 18),
            ),
          ),
          DataColumn(label: Text('Attraction')),
          DataColumn(label: Text('Location')),
          DataColumn(label: Text('Rating')),
          DataColumn(label: Text('Price from')),
          DataColumn(label: Text('Options')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Actions')),
        ],
        rows: items
            .map((attraction) {
              final isSelected = selectedIds.contains(attraction.id);
              return DataRow(
                selected: isSelected,
                cells: [
                  DataCell(
                    Checkbox(
                      value: isSelected,
                      onChanged: (value) =>
                          onSelectionChanged(attraction.id, value ?? false),
                    ),
                  ),
                  DataCell(
                    SizedBox(
                      width: 280.w,
                      child: Row(
                        children: [
                          _AttractionThumb(url: attraction.coverImageUrl),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  attraction.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.sectionTitle.copyWith(
                                    fontSize: 14.sp,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  attraction.id,
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
                        '${attraction.cityId} - ${attraction.area}',
                        style: AppTextStyles.cardMeta.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  DataCell(Text(attraction.rating.toStringAsFixed(1))),
                  DataCell(
                    Text(
                      attraction.priceFrom.trim().isEmpty
                          ? '-'
                          : attraction.priceFrom,
                    ),
                  ),
                  DataCell(Text('${_optionsCount(attraction)}')),
                  DataCell(
                    _StatusPill(
                      label: attraction.isActive ? 'Active' : 'Inactive',
                      color: attraction.isActive
                          ? const Color(0xFF0E9F6E)
                          : const Color(0xFFF59E0B),
                    ),
                  ),
                  DataCell(
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => onEdit(attraction),
                          tooltip: 'Edit',
                          icon: const Icon(Icons.edit_outlined),
                        ),
                        IconButton(
                          onPressed: () => onDelete(attraction),
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

class _AttractionThumb extends StatelessWidget {
  const _AttractionThumb({required this.url});

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
        Icons.local_activity_outlined,
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

int _optionsCount(AttractionEntity attraction) {
  if (attraction.catalogAvailableOptions.isNotEmpty) {
    return attraction.catalogAvailableOptions.length;
  }
  return attraction.packageOverview.length;
}

class _PageToolbar extends StatelessWidget {
  const _PageToolbar({
    required this.searchController,
    required this.onRefresh,
    required this.onActionPressed,
    required this.onToggleSelectAll,
    required this.onDeleteSelected,
    required this.hasSelection,
    required this.allVisibleSelected,
    required this.cityFilter,
    required this.cityOptions,
    required this.sortBy,
    required this.onCityChanged,
    required this.onSortChanged,
  });

  final TextEditingController searchController;
  final Future<void> Function() onRefresh;
  final VoidCallback onActionPressed;
  final VoidCallback onToggleSelectAll;
  final VoidCallback onDeleteSelected;
  final bool hasSelection;
  final bool allVisibleSelected;
  final String cityFilter;
  final List<String> cityOptions;
  final _AttractionsSort sortBy;
  final ValueChanged<String> onCityChanged;
  final ValueChanged<_AttractionsSort> onSortChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final searchField = _SearchField(
          controller: searchController,
          hintText: 'Search by name, city, area, or address',
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
            OutlinedButton.icon(
              onPressed: onToggleSelectAll,
              icon: Icon(
                allVisibleSelected
                    ? Icons.deselect_outlined
                    : Icons.select_all_rounded,
              ),
              label: Text(allVisibleSelected ? 'Deselect all' : 'Select all'),
            ),
            OutlinedButton.icon(
              onPressed: hasSelection ? onDeleteSelected : null,
              icon: const Icon(Icons.delete_sweep_outlined),
              label: const Text('Delete selected'),
            ),
            ElevatedButton.icon(
              onPressed: onActionPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.add),
              label: const Text('Add attraction'),
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
        final sortField = AdminWebFilterDropdownField<_AttractionsSort>(
          label: 'Sort by',
          value: sortBy,
          items: const [
            DropdownMenuItem(
              value: _AttractionsSort.nameAsc,
              child: Text('Name A-Z'),
            ),
            DropdownMenuItem(
              value: _AttractionsSort.nameDesc,
              child: Text('Name Z-A'),
            ),
            DropdownMenuItem(
              value: _AttractionsSort.cityAsc,
              child: Text('City A-Z'),
            ),
            DropdownMenuItem(
              value: _AttractionsSort.ratingHigh,
              child: Text('Rating high-low'),
            ),
            DropdownMenuItem(
              value: _AttractionsSort.ratingLow,
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
