import 'package:equatable/equatable.dart';
import '../../../restaurants/domain/entities/restaurant_entity.dart';

enum AdminRestaurantsStatus { initial, loading, success, failure }

class AdminRestaurantsState extends Equatable {
  const AdminRestaurantsState({
    this.status = AdminRestaurantsStatus.initial,
    this.restaurants = const [],
    this.errorMessage,
  });

  final AdminRestaurantsStatus status;
  final List<RestaurantEntity> restaurants;
  final String? errorMessage;

  AdminRestaurantsState copyWith({
    AdminRestaurantsStatus? status,
    List<RestaurantEntity>? restaurants,
    String? errorMessage,
  }) {
    return AdminRestaurantsState(
      status: status ?? this.status,
      restaurants: restaurants ?? this.restaurants,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, restaurants, errorMessage];
}
