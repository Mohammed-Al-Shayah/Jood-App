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
    emit(state.copyWith(status: AdminOrdersStatus.loading));
    try {
      final restaurants = await _getAllRestaurants();
      emit(
        state.copyWith(
          status: AdminOrdersStatus.success,
          restaurants: restaurants,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AdminOrdersStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void setRestaurant(String restaurantId) {
    emit(state.copyWith(selectedRestaurantId: restaurantId));
  }

  void setDateRange(DateTimeRange? range) {
    emit(state.copyWith(dateRange: range));
  }

  void clearFilters() {
    emit(
      state.copyWith(
        selectedRestaurantId: '',
        dateRange: null,
      ),
    );
  }
}
