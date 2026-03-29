import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../booking_catalog/domain/entities/catalog_category_type.dart';
import '../../../booking_catalog/domain/entities/catalog_item_entity.dart';
import '../../../booking_catalog/domain/usecases/get_catalog_items_usecase.dart';
import '../../../users/domain/usecases/get_user_by_id_usecase.dart';
import 'home_state.dart';
import '../../../../core/utils/number_utils.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required GetCatalogItemsUseCase getCatalogItems,
    required GetUserByIdUseCase getUserById,
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  }) : _getCatalogItems = getCatalogItems,
       _getUserById = getUserById,
       _auth = auth,
       _firestore = firestore,
       super(const HomeState());

  final GetCatalogItemsUseCase _getCatalogItems;
  final GetUserByIdUseCase _getUserById;
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _restaurantsSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _attractionsSub;
  bool _isFetchingRestaurants = false;

  void startListening() {
    _restaurantsSub?.cancel();
    _attractionsSub?.cancel();
    _restaurantsSub = _firestore
        .collection('restaurants')
        .snapshots()
        .skip(1)
        .listen((_) {
          if (isClosed) return;
          unawaited(fetchHomeItems(showLoading: false, shuffleResults: false));
        });
    _attractionsSub = _firestore
        .collection('attractions')
        .snapshots()
        .skip(1)
        .listen((_) {
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
      final items = _deduplicateVenueItems(
        results.expand((group) => group).toList(),
        shuffleResults: shuffleResults,
      );
      if (shuffleResults) {
        items.shuffle();
      }
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
    final user = _auth.currentUser;
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
    emit(
      state.copyWith(
        selectedCategory: category,
        filteredItems: filtered,
      ),
    );
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

    return _sortItems(filtered, sortField, sortOrder);
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
            item.discount.trim().isNotEmpty
                ? item.discount
                : item.priceFrom,
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
    final match = RegExp(r'(\d+(\.\d+)?)\s*%').firstMatch(value);
    if (match == null) return 0;
    return double.tryParse(match.group(1) ?? '') ?? 0;
  }

  String _metaLabel(CatalogItemEntity item) {
    final parts = <String>[];
    parts.add(item.category.title);
    if (item.area.isNotEmpty) parts.add(item.area);
    if (item.cityId.isNotEmpty) parts.add(item.cityId);
    if (parts.isNotEmpty) {
      return parts.join(' | ');
    }
    return item.address;
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
      for (final item in state.items) '${item.sourceCollection}:${item.id}': item,
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
    await _restaurantsSub?.cancel();
    await _attractionsSub?.cancel();
    await super.close();
  }
}
