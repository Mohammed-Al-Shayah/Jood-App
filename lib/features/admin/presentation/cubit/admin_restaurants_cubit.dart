import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../restaurants/domain/entities/restaurant_entity.dart';
import '../../../restaurants/domain/usecases/create_restaurant_usecase.dart';
import '../../../restaurants/domain/usecases/delete_restaurant_usecase.dart';
import '../../../restaurants/domain/usecases/get_all_restaurants_usecase.dart';
import '../../../restaurants/domain/usecases/update_restaurant_usecase.dart';
import 'admin_restaurants_state.dart';

class AdminRestaurantsCubit extends Cubit<AdminRestaurantsState> {
  AdminRestaurantsCubit({
    required GetAllRestaurantsUseCase getAllRestaurants,
    required CreateRestaurantUseCase createRestaurant,
    required UpdateRestaurantUseCase updateRestaurant,
    required DeleteRestaurantUseCase deleteRestaurant,
  }) : _getAllRestaurants = getAllRestaurants,
       _createRestaurant = createRestaurant,
       _updateRestaurant = updateRestaurant,
       _deleteRestaurant = deleteRestaurant,
       super(const AdminRestaurantsState());

  final GetAllRestaurantsUseCase _getAllRestaurants;
  final CreateRestaurantUseCase _createRestaurant;
  final UpdateRestaurantUseCase _updateRestaurant;
  final DeleteRestaurantUseCase _deleteRestaurant;

  Future<void> load() async {
    emit(state.copyWith(status: AdminRestaurantsStatus.loading));
    try {
      final restaurants = await _getAllRestaurants();
      emit(
        state.copyWith(
          status: AdminRestaurantsStatus.success,
          restaurants: restaurants,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AdminRestaurantsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> create(RestaurantEntity restaurant) async {
    try {
      await _createRestaurant(restaurant);
      await load();
    } catch (e) {
      emit(
        state.copyWith(
          status: AdminRestaurantsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> update(RestaurantEntity restaurant) async {
    try {
      await _updateRestaurant(restaurant);
      await load();
    } catch (e) {
      emit(
        state.copyWith(
          status: AdminRestaurantsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> delete(String id) async {
    try {
      await _deleteRestaurant(id);
      await load();
    } catch (e) {
      emit(
        state.copyWith(
          status: AdminRestaurantsStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
