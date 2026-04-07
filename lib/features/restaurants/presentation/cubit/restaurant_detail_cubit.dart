import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jood/core/localization/app_localization_controller.dart';

import 'package:jood/features/restaurants/domain/usecases/get_restaurant_details_usecase.dart';
import 'restaurant_detail_state.dart';

class RestaurantDetailCubit extends Cubit<RestaurantDetailState> {
  RestaurantDetailCubit({required this.getRestaurantDetails})
    : super(RestaurantDetailState.initial) {
    AppLocalizationController.instance.localeNotifier.addListener(
      _handleLocaleChanged,
    );
  }

  final GetRestaurantDetailsUseCase getRestaurantDetails;
  String? _currentRestaurantId;

  Future<void> load(String id) async {
    _currentRestaurantId = id;
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

  void _handleLocaleChanged() {
    final currentRestaurantId = _currentRestaurantId;
    if (isClosed ||
        currentRestaurantId == null ||
        currentRestaurantId.isEmpty) {
      return;
    }
    load(currentRestaurantId);
  }

  @override
  Future<void> close() {
    AppLocalizationController.instance.localeNotifier.removeListener(
      _handleLocaleChanged,
    );
    return super.close();
  }
}
