import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/restaurant_repository.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({required RestaurantRepository repository})
      : _repository = repository,
        super(const HomeState());

  final RestaurantRepository _repository;

  Future<void> fetchRestaurants() async {
    emit(state.copyWith(status: HomeStatus.loading));
    try {
      final restaurants = await _repository.getRestaurants();
      if (restaurants.isEmpty) {
        emit(state.copyWith(status: HomeStatus.empty, restaurants: const []));
      } else {
        emit(
          state.copyWith(
            status: HomeStatus.success,
            restaurants: restaurants,
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
}
