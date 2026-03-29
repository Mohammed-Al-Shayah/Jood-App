import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../restaurants/domain/usecases/get_all_restaurants_usecase.dart';
import 'admin_orders_state.dart';

class AdminOrdersCubit extends Cubit<AdminOrdersState> {
  AdminOrdersCubit({required GetAllRestaurantsUseCase getAllRestaurants})
      : _getAllRestaurants = getAllRestaurants,
        super(const AdminOrdersState());

  final GetAllRestaurantsUseCase _getAllRestaurants;

  Future<void> load() async {
    if (isClosed) return;
    emit(state.copyWith(status: AdminOrdersStatus.loading));
    try {
      final restaurants = await _getAllRestaurants();
      if (isClosed) return;
      emit(
        state.copyWith(
          status: AdminOrdersStatus.success,
          restaurants: restaurants,
          errorMessage: null,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: AdminOrdersStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void setRestaurant(String restaurantId) {
    if (isClosed) return;
    emit(state.copyWith(selectedRestaurantId: restaurantId));
  }

  void setDateRange(DateTimeRange? range) {
    if (isClosed) return;
    emit(state.copyWith(dateRange: range));
  }

  void clearFilters() {
    if (isClosed) return;
    emit(
      state.copyWith(
        selectedRestaurantId: '',
        dateRange: null,
      ),
    );
  }
}
