import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jood/core/utils/app_strings.dart';

import '../../../../core/utils/number_utils.dart';
import '../../../auth/domain/usecases/get_current_user_usecase.dart';
import '../../../booking_catalog/domain/entities/catalog_category_type.dart';
import '../../../booking_catalog/domain/entities/catalog_item_entity.dart';
import '../../../booking_catalog/domain/usecases/get_catalog_items_usecase.dart';
import '../../../booking_catalog/domain/usecases/watch_catalog_changes_usecase.dart';
import '../../../users/domain/usecases/get_user_by_id_usecase.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required GetCatalogItemsUseCase getCatalogItems,
    required WatchCatalogChangesUseCase watchCatalogChanges,
    required GetUserByIdUseCase getUserById,
    required GetCurrentUserUseCase getCurrentUser,
  }) : _getCatalogItems = getCatalogItems,
       _watchCatalogChanges = watchCatalogChanges,
       _getUserById = getUserById,
       _getCurrentUser = getCurrentUser,
       super(const HomeState());

  final GetCatalogItemsUseCase _getCatalogItems;
  final WatchCatalogChangesUseCase _watchCatalogChanges;
  final GetUserByIdUseCase _getUserById;
  final GetCurrentUserUseCase _getCurrentUser;
  StreamSubscription<void>? _catalogChangesSubscription;
  bool _isFetchingRestaurants = false;

  void startListening() {
    _catalogChangesSubscription?.cancel();
    _catalogChangesSubscription = _watchCatalogChanges().listen((_) {
      if (isClosed) return;
      unawaited(fetchHomeItems(showLoading: false, shuffleResults: false));
    });
  }

  Future<void> fetchHomeItems({
    bool showLoading = true,
    bool shuffleResults = true,
  }) async {
    if (isClosed || _isFetchingRestaurants) return;
    _isFetchingRestaurants = true;
    if (showLoading && state.items.isEmpty) {
      emit(state.copyWith(status: HomeStatus.loading));
    }
    try {
      final results = await Future.wait([
        _getCatalogItems(CatalogCategoryType.buffet),
        _getCatalogItems(CatalogCategoryType.setMenu),
        _getCatalogItems(CatalogCategoryType.attraction),
      ]);
      final items = results.expand((group) => group).toList();
      if (isClosed) return;
      if (items.isEmpty) {
        emit(
          state.copyWith(
            status: HomeStatus.empty,
            items: const [],
            filteredItems: const [],
          ),
        );
      } else {
        final filtered = _applyFilters(
          items,
          state.query,
          state.selectedCategory,
          state.sortField,
          state.sortOrder,
        );
        if (shuffleResults &&
            state.selectedCategory == null &&
            state.query.trim().isEmpty &&
            state.sortField == null) {
          filtered.shuffle();
        }
        emit(
          state.copyWith(
            status: HomeStatus.success,
            items: items,
            filteredItems: filtered,
          ),
        );
      }
    } catch (error) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: HomeStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    } finally {
      _isFetchingRestaurants = false;
    }
  }

  Future<void> fetchUserLocation() async {
    final user = _getCurrentUser();
    if (user == null || isClosed) return;
    try {
      final profile = await _getUserById(user.uid);
      if (profile == null || isClosed) return;
      emit(
        state.copyWith(userCity: profile.city, userCountry: profile.country),
      );
    } catch (_) {}
  }

  void updateQuery(String value) {
    if (isClosed) return;
    final filtered = _applyFilters(
      state.items,
      value,
      state.selectedCategory,
      state.sortField,
      state.sortOrder,
    );
    emit(state.copyWith(query: value, filteredItems: filtered));
  }

  void updateSort({SortField? field, SortOrder? order}) {
    if (isClosed) return;
    final nextOrder = order ?? state.sortOrder;
    final filtered = _applyFilters(
      state.items,
      state.query,
      state.selectedCategory,
      field,
      nextOrder,
    );
    emit(
      state.copyWith(
        sortField: field,
        sortOrder: nextOrder,
        filteredItems: filtered,
      ),
    );
  }

  void updateCategoryFilter(CatalogCategoryType? category) {
    if (isClosed) return;
    final filtered = _applyFilters(
      state.items,
      state.query,
      category,
      state.sortField,
      state.sortOrder,
    );
    emit(state.copyWith(selectedCategory: category, filteredItems: filtered));
  }

  List<CatalogItemEntity> _applyFilters(
    List<CatalogItemEntity> items,
    String query,
    CatalogCategoryType? selectedCategory,
    SortField? sortField,
    SortOrder sortOrder,
  ) {
    final trimmed = query.trim().toLowerCase();
    final filtered = items.where((item) {
      final matchesCategory =
          selectedCategory == null || item.category == selectedCategory;
      if (!matchesCategory) return false;
      if (trimmed.isEmpty) return true;
      final name = item.name.toLowerCase();
      final meta = _metaLabel(item).toLowerCase();
      return name.contains(trimmed) || meta.contains(trimmed);
    }).toList();

    final scopedItems = selectedCategory == null
        ? _deduplicateVenueItems(filtered, shuffleResults: false)
        : filtered;

    return _sortItems(scopedItems, sortField, sortOrder);
  }

  List<CatalogItemEntity> _sortItems(
    List<CatalogItemEntity> items,
    SortField? field,
    SortOrder order,
  ) {
    if (field == null) return items;
    final sorted = List<CatalogItemEntity>.from(items);
    sorted.sort((a, b) {
      final aValue = _sortValue(a, field);
      final bValue = _sortValue(b, field);
      final result = aValue.compareTo(bValue);
      return order == SortOrder.asc ? result : -result;
    });
    return sorted;
  }

  double _sortValue(CatalogItemEntity item, SortField field) {
    switch (field) {
      case SortField.price:
        final discountValue = _parseNumber(item.discount);
        final priceFromValue = _parseNumber(item.priceFrom);
        if (discountValue > 0) return discountValue;
        if (priceFromValue > 0) return priceFromValue;
        final current = item.discount.trim().isNotEmpty
            ? item.discount
            : item.priceFrom;
        return _parseNumber(current);
      case SortField.discount:
        return _discountValue(item);
      case SortField.rating:
        return item.rating;
    }
  }

  double _discountValue(CatalogItemEntity item) {
    final badgePercent = _parsePercent(item.badge);
    if (badgePercent > 0) return badgePercent;
    final original = _parseNumber(item.priceFrom);
    final current = _parseNumber(item.discount) > 0
        ? _parseNumber(item.discount)
        : _parseNumber(
            item.discount.trim().isNotEmpty ? item.discount : item.priceFrom,
          );
    if (original > 0 && current > 0 && original >= current) {
      return ((original - current) / original) * 100;
    }
    return 0;
  }

  double _parseNumber(String value) {
    return NumberUtils.parseNumber(value.replaceAll(',', ''));
  }

  double _parsePercent(String value) {
    final percentIndex = value.indexOf('%');
    if (percentIndex < 0) return 0;
    final buffer = StringBuffer();
    for (final rune in value.substring(0, percentIndex).runes) {
      final character = String.fromCharCode(rune);
      final isNumber = (rune >= 48 && rune <= 57) || rune == 46;
      if (isNumber) {
        buffer.write(character);
      }
    }
    return double.tryParse(buffer.toString()) ?? 0;
  }

  String _metaLabel(CatalogItemEntity item) {
    final parts = <String>[];
    parts.add(_localizedCategoryTitle(item.category));
    if (item.area.isNotEmpty) parts.add(item.area);
    if (item.cityId.isNotEmpty) parts.add(item.cityId);
    if (parts.isNotEmpty) {
      return parts.join(' | ');
    }
    return item.address;
  }

  String _localizedCategoryTitle(CatalogCategoryType category) {
    switch (category) {
      case CatalogCategoryType.buffet:
        return AppStrings.buffet;
      case CatalogCategoryType.setMenu:
        return AppStrings.setMenu;
      case CatalogCategoryType.attraction:
        return AppStrings.attractions;
    }
  }

  List<CatalogItemEntity> _deduplicateVenueItems(
    List<CatalogItemEntity> items, {
    required bool shuffleResults,
  }) {
    final grouped = <String, List<CatalogItemEntity>>{};
    for (final item in items) {
      final key = '${item.sourceCollection}:${item.id}';
      grouped.putIfAbsent(key, () => <CatalogItemEntity>[]).add(item);
    }

    final previousSelections = <String, CatalogItemEntity>{
      for (final item in state.items)
        '${item.sourceCollection}:${item.id}': item,
    };

    final uniqueItems = <CatalogItemEntity>[];
    for (final entry in grouped.entries) {
      final group = List<CatalogItemEntity>.from(entry.value);
      if (group.length == 1) {
        uniqueItems.add(group.first);
        continue;
      }

      final previous = previousSelections[entry.key];
      if (!shuffleResults && previous != null) {
        final retained = _findMatchingCategory(group, previous.category);
        if (retained != null) {
          uniqueItems.add(retained);
          continue;
        }
      }

      if (shuffleResults) {
        group.shuffle();
      }
      uniqueItems.add(group.first);
    }

    return uniqueItems;
  }

  CatalogItemEntity? _findMatchingCategory(
    List<CatalogItemEntity> items,
    CatalogCategoryType category,
  ) {
    for (final item in items) {
      if (item.category == category) return item;
    }
    return null;
  }

  @override
  Future<void> close() async {
    await _catalogChangesSubscription?.cancel();
    await super.close();
  }
}
