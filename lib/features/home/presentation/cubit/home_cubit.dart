import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jood/features/home/domain/entities/restaurant.dart';

import '../../domain/repositories/restaurant_repository.dart';
import '../../../users/domain/usecases/get_user_by_id_usecase.dart';
import 'home_state.dart';
import '../../../../core/utils/number_utils.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required RestaurantRepository repository,
    required GetUserByIdUseCase getUserById,
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  }) : _repository = repository,
       _getUserById = getUserById,
       _auth = auth,
       _firestore = firestore,
       super(const HomeState());

  final RestaurantRepository _repository;
  final GetUserByIdUseCase _getUserById;
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _restaurantsSub;

  void startListening() {
    _restaurantsSub?.cancel();
    _restaurantsSub = _firestore
        .collection('restaurants')
        .snapshots()
        .listen((_) => fetchRestaurants());
  }

  Future<void> fetchRestaurants() async {
    emit(state.copyWith(status: HomeStatus.loading));
    try {
      final restaurants = await _repository.getRestaurants();
      if (restaurants.isEmpty) {
        emit(
          state.copyWith(
            status: HomeStatus.empty,
            restaurants: const [],
            filteredRestaurants: const [],
          ),
        );
      } else {
        final filtered = _applyFilters(
          restaurants,
          state.query,
          state.sortField,
          state.sortOrder,
        );
        emit(
          state.copyWith(
            status: HomeStatus.success,
            restaurants: restaurants,
            filteredRestaurants: filtered,
          ),
        );
      }
    } catch (error) {
      emit(
        state.copyWith(
          status: HomeStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> fetchUserLocation() async {
    final user = _auth.currentUser;
    if (user == null) return;
    try {
      final profile = await _getUserById(user.uid);
      if (profile == null) return;
      emit(
        state.copyWith(userCity: profile.city, userCountry: profile.country),
      );
    } catch (_) {}
  }

  void updateQuery(String value) {
    final filtered = _applyFilters(
      state.restaurants,
      value,
      state.sortField,
      state.sortOrder,
    );
    emit(state.copyWith(query: value, filteredRestaurants: filtered));
  }

  void updateSort({SortField? field, SortOrder? order}) {
    final nextOrder = order ?? state.sortOrder;
    final filtered = _applyFilters(
      state.restaurants,
      state.query,
      field,
      nextOrder,
    );
    emit(
      state.copyWith(
        sortField: field,
        sortOrder: nextOrder,
        filteredRestaurants: filtered,
      ),
    );
  }

  List<RestaurantEntity> _applyFilters(
    List<RestaurantEntity> restaurants,
    String query,
    SortField? sortField,
    SortOrder sortOrder,
  ) {
    final trimmed = query.trim().toLowerCase();
    final filtered = trimmed.isEmpty
        ? restaurants
        : restaurants.where((restaurant) {
            final name = restaurant.name.toLowerCase();
            final meta = _metaLabel(restaurant).toLowerCase();
            return name.contains(trimmed) || meta.contains(trimmed);
          }).toList();

    return _sortRestaurants(filtered, sortField, sortOrder);
  }

  List<RestaurantEntity> _sortRestaurants(
    List<RestaurantEntity> restaurants,
    SortField? field,
    SortOrder order,
  ) {
    if (field == null) return restaurants;
    final sorted = List<RestaurantEntity>.from(restaurants);
    sorted.sort((a, b) {
      final aValue = _sortValue(a, field);
      final bValue = _sortValue(b, field);
      final result = aValue.compareTo(bValue);
      return order == SortOrder.asc ? result : -result;
    });
    return sorted;
  }

  double _sortValue(RestaurantEntity restaurant, SortField field) {
    switch (field) {
      case SortField.price:
        if (restaurant.discountValue > 0) return restaurant.discountValue;
        if (restaurant.priceFromValue > 0) return restaurant.priceFromValue;
        final current = restaurant.discount.trim().isNotEmpty
            ? restaurant.discount
            : restaurant.priceFrom;
        return _parseNumber(current);
      case SortField.discount:
        return _discountValue(restaurant);
      case SortField.rating:
        return restaurant.rating;
    }
  }

  double _discountValue(RestaurantEntity restaurant) {
    final badgePercent = _parsePercent(restaurant.badge);
    if (badgePercent > 0) return badgePercent;
    final original = restaurant.priceFromValue > 0
        ? restaurant.priceFromValue
        : _parseNumber(restaurant.priceFrom);
    final current = restaurant.discountValue > 0
        ? restaurant.discountValue
        : _parseNumber(
            restaurant.discount.trim().isNotEmpty
                ? restaurant.discount
                : restaurant.priceFrom,
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

  String _metaLabel(RestaurantEntity restaurant) {
    final parts = <String>[];
    if (restaurant.area.isNotEmpty) parts.add(restaurant.area);
    if (restaurant.cityId.isNotEmpty) parts.add(restaurant.cityId);
    if (parts.isNotEmpty) {
      return parts.join(' • ');
    }
    return restaurant.address;
  }

  @override
  Future<void> close() {
    _restaurantsSub?.cancel();
    return super.close();
  }
}
