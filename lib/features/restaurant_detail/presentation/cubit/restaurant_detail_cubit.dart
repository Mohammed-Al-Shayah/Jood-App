import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../restaurants/domain/usecases/get_restaurant_details_usecase.dart';
import 'restaurant_detail_state.dart';

class RestaurantDetailCubit extends Cubit<RestaurantDetailState> {
  RestaurantDetailCubit({required this.getRestaurantDetails})
      : super(RestaurantDetailState.initial);

  final GetRestaurantDetailsUseCase getRestaurantDetails;

  Future<void> load(String id) async {
    emit(state.copyWith(status: RestaurantDetailStatus.loading));
    try {
      final restaurant = await getRestaurantDetails(id);
      emit(
        state.copyWith(
          status: RestaurantDetailStatus.success,
          restaurant: restaurant,
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: RestaurantDetailStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }
}
