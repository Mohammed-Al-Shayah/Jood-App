import '../entities/restaurant_entity.dart';
import '../repositories/restaurant_repository.dart';

class CreateRestaurantUseCase {
  CreateRestaurantUseCase(this.repository);

  final RestaurantRepository repository;

  Future<RestaurantEntity> call(RestaurantEntity restaurant) {
    return repository.createRestaurant(restaurant);
  }
}
