import '../entities/restaurant_entity.dart';
import '../repositories/restaurant_repository.dart';

class GetAllRestaurantsUseCase {
  GetAllRestaurantsUseCase(this.repository);

  final RestaurantRepository repository;

  Future<List<RestaurantEntity>> call() {
    return repository.getAllRestaurants();
  }
}
