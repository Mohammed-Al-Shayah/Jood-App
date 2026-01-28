import '../../../restaurants/domain/entities/restaurant_entity.dart';

enum RestaurantDetailStatus { initial, loading, success, failure }

class RestaurantDetailState {
  const RestaurantDetailState({
    required this.status,
    this.restaurant,
    this.errorMessage,
  });

  final RestaurantDetailStatus status;
  final RestaurantEntity? restaurant;
  final String? errorMessage;

  RestaurantDetailState copyWith({
    RestaurantDetailStatus? status,
    RestaurantEntity? restaurant,
    String? errorMessage,
  }) {
    return RestaurantDetailState(
      status: status ?? this.status,
      restaurant: restaurant ?? this.restaurant,
      errorMessage: errorMessage,
    );
  }

  static const RestaurantDetailState initial = RestaurantDetailState(
    status: RestaurantDetailStatus.initial,
  );
}
