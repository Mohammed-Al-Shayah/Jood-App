import '../entities/restaurant_entity.dart';
import '../repositories/restaurant_repository.dart';

class UpdateRestaurantUseCase {
  UpdateRestaurantUseCase(this.repository);

  final RestaurantRepository repository;

  Future<RestaurantEntity> call(RestaurantEntity restaurant) {
    return repository.updateRestaurant(restaurant);
  }
}
