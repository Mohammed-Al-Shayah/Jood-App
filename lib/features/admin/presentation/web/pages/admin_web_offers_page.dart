import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:jood/core/di/service_locator.dart';
import 'package:jood/core/theming/app_colors.dart';
import 'package:jood/core/theming/app_text_styles.dart';
import 'package:jood/core/utils/payment_amount_utils.dart';
import 'package:jood/core/widgets/currency_amount_text.dart';
import 'package:jood/core/widgets/app_snackbar.dart';
import 'package:jood/features/admin/presentation/cubit/admin_offers_cubit.dart';
import 'package:jood/features/admin/presentation/cubit/admin_offers_state.dart';
import 'package:jood/features/admin/presentation/web/widgets/admin_web_filter_dropdown_field.dart';
import 'package:jood/features/admin/presentation/web/widgets/admin_web_inline_form_view.dart';
import 'package:jood/features/admin/presentation/web/widgets/admin_web_metric_card.dart';
import 'package:jood/features/admin/presentation/web/widgets/admin_web_panel.dart';
import 'package:jood/features/admin/presentation/widgets/admin_confirm_dialog.dart';
import 'package:jood/features/admin/presentation/widgets/admin_offer_form_content.dart';
import 'package:jood/features/attractions/domain/usecases/get_all_attractions_usecase.dart';
import 'package:jood/features/offers/domain/entities/offer_entity.dart';
import 'package:jood/features/restaurants/domain/usecases/get_all_restaurants_usecase.dart';

enum AdminWebOfferSectionMode { all, buffet, setMenu, combo, attractions }

class AdminWebOffersPage extends StatefulWidget {
  const AdminWebOffersPage({
    super.key,
    this.sectionMode = AdminWebOfferSectionMode.all,
  });

  final AdminWebOfferSectionMode sectionMode;

  bool get isCategoryLocked => sectionMode != AdminWebOfferSectionMode.all;

  String? get lockedCategoryFilter => switch (sectionMode) {
    AdminWebOfferSectionMode.all => null,
    AdminWebOfferSectionMode.buffet => 'buffet',
    AdminWebOfferSectionMode.setMenu => 'set_menu',
    AdminWebOfferSectionMode.combo => 'combo',
    AdminWebOfferSectionMode.attractions => 'attraction',
  };

  String get primaryMetricTitle => switch (sectionMode) {
    AdminWebOfferSectionMode.all => 'All offers',
    AdminWebOfferSectionMode.buffet => 'Buffet offers',
    AdminWebOfferSectionMode.setMenu => 'Set menu offers',
    AdminWebOfferSectionMode.combo => 'Combo offers',
    AdminWebOfferSectionMode.attractions => 'Attraction offers',
  };

  String get primaryMetricCaption => switch (sectionMode) {
    AdminWebOfferSectionMode.all => 'Inventory units across categories',
    AdminWebOfferSectionMode.buffet => 'Meal-based buffet inventory',
    AdminWebOfferSectionMode.setMenu =>
      'Fixed menu inventory across restaurants',
    AdminWebOfferSectionMode.combo =>
      'Fixed-price combo inventory with quantity-based ordering',
    AdminWebOfferSectionMode.attractions => 'Time and package based inventory',
  };

  String get thirdMetricTitle => switch (sectionMode) {
    AdminWebOfferSectionMode.all => 'Attraction offers',
    AdminWebOfferSectionMode.buffet => 'Buffet venues',
    AdminWebOfferSectionMode.setMenu => 'Set menu venues',
    AdminWebOfferSectionMode.combo => 'Combo venues',
    AdminWebOfferSectionMode.attractions => 'Attraction venues',
  };

  String get addActionLabel => switch (sectionMode) {
    AdminWebOfferSectionMode.all => 'Add offer',
    AdminWebOfferSectionMode.buffet => 'Add buffet offer',
    AdminWebOfferSectionMode.setMenu => 'Add set menu offer',
    AdminWebOfferSectionMode.combo => 'Add combo offer',
    AdminWebOfferSectionMode.attractions => 'Add attraction offer',
  };

  @override
  State<AdminWebOffersPage> createState() => _AdminWebOffersPageState();
}

class _AdminWebOffersPageState extends State<AdminWebOffersPage> {
  late final AdminOffersCubit _cubit;
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedOfferIds = <String>{};
  Map<String, String> _venueNames = const {};
  String _categoryFilter = 'all';
  String _statusFilter = 'all';
  String _venueFilter = 'all';
  _OffersSort _sortBy = _OffersSort.dateNewest;
  _OffersView _view = _OffersView.list;
  OfferEntity? _selectedOffer;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<AdminOffersCubit>()..load();
    _searchController.addListener(_onSearchChanged);
    if (widget.lockedCategoryFilter != null) {
      _categoryFilter = widget.lockedCategoryFilter!;
    }
    _loadVenueNames();
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

  Future<void> _loadVenueNames() async {
    try {
      final restaurants = await getIt<GetAllRestaurantsUseCase>()();
      final attractions = await getIt<GetAllAttractionsUseCase>()();
      if (!mounted) return;
      setState(() {
        _venueNames = {
          for (final restaurant in restaurants) restaurant.id: restaurant.name,
          for (final attraction in attractions)
            attraction.id: attraction.name.trim().isNotEmpty
                ? attraction.name
                : attraction.id,
        };
      });
    } catch (_) {
      // Keep the raw venue id as a fallback in the table.
    }
  }

  void _openCreateForm() {
    setState(() {
      _view = _OffersView.create;
      _selectedOffer = null;
    });
  }

  void _openEditForm(OfferEntity offer) {
    setState(() {
      _view = _OffersView.edit;
      _selectedOffer = offer;
    });
  }

  Future<void> _confirmDelete(OfferEntity offer) async {
    final confirmed = await showAdminConfirmDialog(
      context: context,
      title: 'Delete offer',
      message: 'Delete ${offer.title}?',
    );
    if (confirmed != true) return;
    await _cubit.delete(offer.id);
    if (!mounted) return;
    setState(() {
      _selectedOfferIds.remove(offer.id);
    });
  }

  void _toggleOfferSelection(String id, bool selected) {
    setState(() {
      if (selected) {
        _selectedOfferIds.add(id);
      } else {
        _selectedOfferIds.remove(id);
      }
    });
  }

  void _toggleSelectAllOffers(List<OfferEntity> items) {
    final ids = items.map((item) => item.id).toList(growable: false);
    final allSelected =
        ids.isNotEmpty && ids.every((id) => _selectedOfferIds.contains(id));
    setState(() {
      if (allSelected) {
        _selectedOfferIds.removeAll(ids);
      } else {
        _selectedOfferIds.addAll(ids);
      }
    });
  }

  Future<void> _confirmDeleteSelectedOffers(List<OfferEntity> items) async {
    final selectedIds = items
        .map((item) => item.id)
        .where(_selectedOfferIds.contains)
        .toList(growable: false);
    if (selectedIds.isEmpty) return;
    final confirmed = await showAdminConfirmDialog(
      context: context,
      title: 'Delete offers',
      message: 'Delete ${selectedIds.length} selected offers?',
    );
    if (confirmed != true) return;
    await _cubit.deleteMany(selectedIds);
    if (!mounted) return;
    setState(() {
      _selectedOfferIds.removeAll(selectedIds);
    });
  }

  void _closeForm() {
    setState(() {
      _view = _OffersView.list;
      _selectedOffer = null;
    });
  }

  Future<void> _submitForm(Object result) async {
    if (result is OfferEntity) {
      if (_view == _OffersView.edit) {
        await _cubit.update(result);
      } else {
        await _cubit.create(result);
      }
    } else if (result is List<OfferEntity>) {
      await _cubit.createMany(result);
    } else {
      return;
    }

    if (!mounted) return;
    if (_cubit.state.status == AdminOffersStatus.failure) {
      showAppSnackBar(
        context,
        _cubit.state.errorMessage ?? 'Failed to save offer.',
        type: SnackBarType.error,
      );
      return;
    }

    final message = switch (result) {
      OfferEntity() =>
        _view == _OffersView.edit
            ? 'Offer updated successfully.'
            : 'Offer created successfully.',
      List<OfferEntity>() => '${result.length} offers created successfully.',
      _ => 'Offer saved successfully.',
    };
    showAppSnackBar(context, message, type: SnackBarType.success);
    _closeForm();
  }

  List<OfferEntity> _applyFilters(List<OfferEntity> items) {
    final query = _searchController.text.trim().toLowerCase();
    final categoryFilter = widget.lockedCategoryFilter ?? _categoryFilter;
    final filtered = items
        .where((offer) {
          final category = _normalizedCategory(offer);
          final status = offer.status.trim().toLowerCase();
          final venueName = _venueLabel(offer).toLowerCase();
          if (categoryFilter != 'all' && category != categoryFilter) {
            return false;
          }
          if (_statusFilter != 'all' && status != _statusFilter) {
            return false;
          }
          if (_venueFilter != 'all' &&
              venueName != _venueFilter.toLowerCase()) {
            return false;
          }
          if (query.isEmpty) return true;
          final haystack = [
            offer.title,
            _venueLabel(offer),
            offer.date,
            offer.startTime,
            offer.endTime,
            category,
            offer.packageName,
            offer.mealType,
          ].join(' ').toLowerCase();
          return haystack.contains(query);
        })
        .toList(growable: false);

    filtered.sort((a, b) {
      switch (_sortBy) {
        case _OffersSort.dateNewest:
          return _offerSortKey(b).compareTo(_offerSortKey(a));
        case _OffersSort.dateOldest:
          return _offerSortKey(a).compareTo(_offerSortKey(b));
        case _OffersSort.venueAsc:
          return _venueLabel(
            a,
          ).toLowerCase().compareTo(_venueLabel(b).toLowerCase());
        case _OffersSort.venueDesc:
          return _venueLabel(
            b,
          ).toLowerCase().compareTo(_venueLabel(a).toLowerCase());
        case _OffersSort.priceHigh:
          return b.priceAdult.compareTo(a.priceAdult);
        case _OffersSort.priceLow:
          return a.priceAdult.compareTo(b.priceAdult);
      }
    });

    return filtered;
  }

  String _venueLabel(OfferEntity offer) {
    final value = (_venueNames[offer.restaurantId] ?? offer.restaurantId)
        .trim();
    return value.isEmpty ? '-' : value;
  }

  String _offerSortKey(OfferEntity offer) {
    return '${offer.date.trim()} ${offer.startTime.trim()}';
  }

  String _normalizedCategory(OfferEntity offer) {
    final raw = offer.bookingCategory.trim().toLowerCase();
    if (raw == 'set menu') return 'set_menu';
    if (raw.isNotEmpty) return raw;
    if (offer.bookableType.trim().toLowerCase() == 'attraction') {
      return 'attraction';
    }
    return 'restaurant';
  }

  String _displayCategory(OfferEntity offer) {
    final category = _normalizedCategory(offer);
    switch (category) {
      case 'buffet':
        return 'Buffet';
      case 'set_menu':
      case 'setmenu':
        return 'Set Menu';
      case 'combo':
        return 'Combo';
      case 'attraction':
        return 'Attraction';
      default:
        return 'Restaurant';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<AdminOffersCubit, AdminOffersState>(
        builder: (context, state) {
          if (_view != _OffersView.list) {
            final isEdit = _view == _OffersView.edit;
            return AdminWebInlineFormView(
              title: isEdit ? _editTitle() : _createTitle(),
              subtitle: isEdit
                  ? 'Update pricing, dates, and capacity, then return to the inventory list.'
                  : 'Create inventory entries and return to the offers list.',
              onBack: _closeForm,
              backTooltip: 'Back to offers',
              child: AdminOfferFormContent(
                offer: _selectedOffer,
                initialCategory: isEdit ? null : widget.lockedCategoryFilter,
                padding: EdgeInsets.all(20.w),
                onSubmit: _submitForm,
              ),
            );
          }

          final filteredItems = _applyFilters(state.offers);
          _selectedOfferIds.removeWhere(
            (id) => !state.offers.any((item) => item.id == id),
          );
          final selectedInViewCount = filteredItems
              .where((item) => _selectedOfferIds.contains(item.id))
              .length;
          final allFilteredSelected =
              filteredItems.isNotEmpty &&
              selectedInViewCount == filteredItems.length;
          final scopedItems = widget.isCategoryLocked
              ? state.offers
                    .where(
                      (offer) =>
                          _normalizedCategory(offer) ==
                          widget.lockedCategoryFilter,
                    )
                    .toList(growable: false)
              : state.offers;
          final venueOptions =
              scopedItems
                  .map(_venueLabel)
                  .where((name) => name != '-')
                  .toSet()
                  .toList()
                ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
          final activeCount = scopedItems
              .where((offer) => offer.status.trim().toLowerCase() == 'active')
              .length;
          final supportingVenueCount = scopedItems
              .map((offer) => offer.restaurantId)
              .toSet()
              .length;
          final thirdMetricValue =
              widget.sectionMode == AdminWebOfferSectionMode.all
              ? state.offers
                    .where(
                      (offer) => _normalizedCategory(offer) == 'attraction',
                    )
                    .length
                    .toString()
              : '$supportingVenueCount';
          final thirdMetricCaption =
              widget.sectionMode == AdminWebOfferSectionMode.attractions
              ? 'Unique attraction venues in this inventory'
              : widget.sectionMode == AdminWebOfferSectionMode.all
              ? 'Time and package based inventory'
              : 'Unique venues with this inventory type';

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
                          title: widget.primaryMetricTitle,
                          value: '${scopedItems.length}',
                          icon: Icons.local_offer_outlined,
                          iconColor: AppColors.primary,
                          caption: widget.primaryMetricCaption,
                        ),
                      ),
                      SizedBox(
                        width: cardWidth,
                        child: AdminWebMetricCard(
                          title: 'Active offers',
                          value: '$activeCount',
                          icon: Icons.check_circle_outline,
                          iconColor: const Color(0xFF0E9F6E),
                          caption: 'Currently available for booking',
                        ),
                      ),
                      SizedBox(
                        width: cardWidth,
                        child: AdminWebMetricCard(
                          title: widget.thirdMetricTitle,
                          value: thirdMetricValue,
                          icon:
                              widget.sectionMode ==
                                  AdminWebOfferSectionMode.attractions
                              ? Icons.place_outlined
                              : Icons.local_activity_outlined,
                          iconColor: const Color(0xFF2563EB),
                          caption: thirdMetricCaption,
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
                    _OffersToolbar(
                      searchController: _searchController,
                      onRefresh: () async {
                        await _cubit.load();
                        await _loadVenueNames();
                      },
                      onAddPressed: _openCreateForm,
                      actionLabel: widget.addActionLabel,
                      onToggleSelectAll: () =>
                          _toggleSelectAllOffers(filteredItems),
                      onDeleteSelected: () =>
                          _confirmDeleteSelectedOffers(filteredItems),
                      hasSelection: selectedInViewCount > 0,
                      allVisibleSelected: allFilteredSelected,
                      venueFilter: venueOptions.contains(_venueFilter)
                          ? _venueFilter
                          : 'all',
                      venueOptions: venueOptions,
                      sortBy: _sortBy,
                      onVenueChanged: (value) =>
                          setState(() => _venueFilter = value),
                      onSortChanged: (value) => setState(() => _sortBy = value),
                    ),
                    SizedBox(height: 14.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: [
                        if (!widget.isCategoryLocked) ...[
                          _FilterChip(
                            label: 'All types',
                            selected: _categoryFilter == 'all',
                            onTap: () =>
                                setState(() => _categoryFilter = 'all'),
                          ),
                          _FilterChip(
                            label: 'Buffet',
                            selected: _categoryFilter == 'buffet',
                            onTap: () =>
                                setState(() => _categoryFilter = 'buffet'),
                          ),
                          _FilterChip(
                            label: 'Set Menu',
                            selected: _categoryFilter == 'set_menu',
                            onTap: () =>
                                setState(() => _categoryFilter = 'set_menu'),
                          ),
                          _FilterChip(
                            label: 'Combo',
                            selected: _categoryFilter == 'combo',
                            onTap: () =>
                                setState(() => _categoryFilter = 'combo'),
                          ),
                          _FilterChip(
                            label: 'Attractions',
                            selected: _categoryFilter == 'attraction',
                            onTap: () =>
                                setState(() => _categoryFilter = 'attraction'),
                          ),
                        ],
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
                    if (state.status == AdminOffersStatus.loading &&
                        state.offers.isEmpty)
                      const Center(child: CircularProgressIndicator())
                    else if (state.status == AdminOffersStatus.failure)
                      _PanelMessage(
                        message: state.errorMessage ?? 'Failed to load offers.',
                        isError: true,
                      )
                    else if (filteredItems.isEmpty)
                      const _PanelMessage(
                        message: 'No offers match the current filters.',
                      )
                    else
                      _OffersTable(
                        items: filteredItems,
                        venueNames: _venueNames,
                        onEdit: _openEditForm,
                        onDelete: _confirmDelete,
                        categoryLabelBuilder: _displayCategory,
                        selectedIds: _selectedOfferIds,
                        onSelectionChanged: _toggleOfferSelection,
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

  String _createTitle() {
    switch (widget.sectionMode) {
      case AdminWebOfferSectionMode.buffet:
        return 'Create buffet offer';
      case AdminWebOfferSectionMode.setMenu:
        return 'Create set menu offer';
      case AdminWebOfferSectionMode.combo:
        return 'Create combo offer';
      case AdminWebOfferSectionMode.attractions:
        return 'Create attraction offer';
      case AdminWebOfferSectionMode.all:
        return 'Create offer';
    }
  }

  String _editTitle() {
    if (_selectedOffer == null) return 'Edit offer';
    final label = _displayCategory(_selectedOffer!);
    return 'Edit ${label.toLowerCase()} offer';
  }
}

enum _OffersView { list, create, edit }

enum _OffersSort {
  dateNewest,
  dateOldest,
  venueAsc,
  venueDesc,
  priceHigh,
  priceLow,
}

class _OffersToolbar extends StatelessWidget {
  const _OffersToolbar({
    required this.searchController,
    required this.onRefresh,
    required this.onAddPressed,
    required this.actionLabel,
    required this.onToggleSelectAll,
    required this.onDeleteSelected,
    required this.hasSelection,
    required this.allVisibleSelected,
    required this.venueFilter,
    required this.venueOptions,
    required this.sortBy,
    required this.onVenueChanged,
    required this.onSortChanged,
  });

  final TextEditingController searchController;
  final Future<void> Function() onRefresh;
  final VoidCallback onAddPressed;
  final String actionLabel;
  final VoidCallback onToggleSelectAll;
  final VoidCallback onDeleteSelected;
  final bool hasSelection;
  final bool allVisibleSelected;
  final String venueFilter;
  final List<String> venueOptions;
  final _OffersSort sortBy;
  final ValueChanged<String> onVenueChanged;
  final ValueChanged<_OffersSort> onSortChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final searchField = _SearchField(
          controller: searchController,
          hintText: 'Search by title, restaurant, date, package, or meal type',
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
              onPressed: onAddPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.add),
              label: Text(actionLabel),
            ),
          ],
        );
        final venueField = AdminWebFilterDropdownField<String>(
          label: 'Venue',
          value: venueFilter,
          items: [
            const DropdownMenuItem(value: 'all', child: Text('All venues')),
            ...venueOptions.map(
              (name) => DropdownMenuItem(value: name, child: Text(name)),
            ),
          ],
          onChanged: onVenueChanged,
        );
        final sortField = AdminWebFilterDropdownField<_OffersSort>(
          label: 'Sort by',
          value: sortBy,
          items: const [
            DropdownMenuItem(
              value: _OffersSort.dateNewest,
              child: Text('Newest date'),
            ),
            DropdownMenuItem(
              value: _OffersSort.dateOldest,
              child: Text('Oldest date'),
            ),
            DropdownMenuItem(
              value: _OffersSort.venueAsc,
              child: Text('Venue A-Z'),
            ),
            DropdownMenuItem(
              value: _OffersSort.venueDesc,
              child: Text('Venue Z-A'),
            ),
            DropdownMenuItem(
              value: _OffersSort.priceHigh,
              child: Text('Price high-low'),
            ),
            DropdownMenuItem(
              value: _OffersSort.priceLow,
              child: Text('Price low-high'),
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
              venueField,
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
            SizedBox(width: 220.w, child: venueField),
            SizedBox(width: 12.w),
            SizedBox(width: 220.w, child: sortField),
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

class _OffersTable extends StatelessWidget {
  const _OffersTable({
    required this.items,
    required this.venueNames,
    required this.onEdit,
    required this.onDelete,
    required this.categoryLabelBuilder,
    required this.selectedIds,
    required this.onSelectionChanged,
  });

  final List<OfferEntity> items;
  final Map<String, String> venueNames;
  final ValueChanged<OfferEntity> onEdit;
  final ValueChanged<OfferEntity> onDelete;
  final String Function(OfferEntity) categoryLabelBuilder;
  final Set<String> selectedIds;
  final void Function(String id, bool selected) onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        showCheckboxColumn: false,
        columnSpacing: 22.w,
        headingRowHeight: 48.h,
        dataRowMinHeight: 70.h,
        dataRowMaxHeight: 82.h,
        columns: [
          DataColumn(
            label: SizedBox(
              width: 28.w,
              child: const Icon(Icons.check_box_outline_blank, size: 18),
            ),
          ),
          DataColumn(label: Text('Offer')),
          DataColumn(label: Text('Restaurant')),
          DataColumn(label: Text('Category')),
          DataColumn(label: Text('Date')),
          DataColumn(label: Text('Time')),
          DataColumn(label: Text('Price')),
          DataColumn(label: Text('Remaining')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Actions')),
        ],
        rows: items
            .map((offer) {
              final isSelected = selectedIds.contains(offer.id);
              final venueName =
                  venueNames[offer.restaurantId] ?? offer.restaurantId;
              final primaryOfferLabel = offer.packageName.trim().isNotEmpty
                  ? offer.packageName
                  : offer.title;
              final secondaryOfferLabel =
                  offer.packageDescription.trim().isNotEmpty
                  ? offer.packageDescription
                  : offer.packageName.trim().isNotEmpty &&
                        offer.title.trim().isNotEmpty &&
                        offer.title.trim() != offer.packageName.trim()
                  ? offer.title
                  : offer.mealType;
              return DataRow(
                selected: isSelected,
                cells: [
                  DataCell(
                    Checkbox(
                      value: isSelected,
                      onChanged: (value) =>
                          onSelectionChanged(offer.id, value ?? false),
                    ),
                  ),
                  DataCell(
                    SizedBox(
                      width: 220.w,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            primaryOfferLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.sectionTitle.copyWith(
                              fontSize: 14.sp,
                            ),
                          ),
                          if (secondaryOfferLabel.trim().isNotEmpty) ...[
                            SizedBox(height: 4.h),
                            Text(
                              secondaryOfferLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.cardMeta,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  DataCell(
                    SizedBox(
                      width: 170.w,
                      child: Text(
                        venueName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  DataCell(Text(categoryLabelBuilder(offer))),
                  DataCell(Text(offer.date)),
                  DataCell(Text('${offer.startTime} - ${offer.endTime}')),
                  DataCell(
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CurrencyAmountInlineText(text: _priceLabel(offer)),
                        if (_originalPriceLabel(offer).isNotEmpty)
                          CurrencyAmountInlineText(
                            text: _originalPriceLabel(offer),
                            style: AppTextStyles.cardMeta.copyWith(
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                      ],
                    ),
                  ),
                  DataCell(
                    Text(
                      _remainingLabel(offer),
                      style: AppTextStyles.cardMeta.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  DataCell(
                    _StatusPill(
                      label: _titleCase(offer.status),
                      color: offer.status.trim().toLowerCase() == 'active'
                          ? const Color(0xFF0E9F6E)
                          : const Color(0xFFF59E0B),
                    ),
                  ),
                  DataCell(
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => onEdit(offer),
                          tooltip: 'Edit',
                          icon: const Icon(Icons.edit_outlined),
                        ),
                        IconButton(
                          onPressed: () => onDelete(offer),
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

  String _priceLabel(OfferEntity offer) {
    final amount = formatCurrency(offer.currency, offer.priceAdult);
    if (offer.usesUnifiedGuestCount) {
      final unit = _categoryKey(offer) == 'combo' ? 'combo' : 'person';
      return '$amount / $unit';
    }
    return '$amount / ${formatCurrency(offer.currency, offer.priceChild)}';
  }

  String _originalPriceLabel(OfferEntity offer) {
    if (offer.priceAdultOriginal <= 0 ||
        offer.priceAdultOriginal <= offer.priceAdult) {
      return '';
    }
    return formatCurrency(offer.currency, offer.priceAdultOriginal);
  }

  String _remainingLabel(OfferEntity offer) {
    if (offer.usesUnifiedGuestCount) {
      final remaining = offer.remainingAdult + offer.remainingChild;
      final unit = _categoryKey(offer) == 'combo' ? 'combos' : 'persons';
      return '$remaining $unit';
    }
    return 'A ${offer.remainingAdult}  C ${offer.remainingChild}';
  }

  String _categoryKey(OfferEntity offer) {
    final raw = offer.bookingCategory.trim().toLowerCase();
    if (raw == 'set menu') return 'set_menu';
    if (raw.isNotEmpty) return raw;
    if (offer.bookableType.trim().toLowerCase() == 'attraction') {
      return 'attraction';
    }
    return 'restaurant';
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

String _titleCase(String value) {
  final words = value
      .replaceAll('_', ' ')
      .split(' ')
      .where((word) => word.isNotEmpty)
      .toList(growable: false);
  if (words.isEmpty) return '-';
  return words
      .map(
        (word) => '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
      )
      .join(' ');
}
