import '../entities/restaurant_entity.dart';
import '../repositories/restaurant_repository.dart';

class GetRestaurantsUseCase {
  GetRestaurantsUseCase(this.repository);

  final RestaurantRepository repository;

  Future<List<RestaurantEntity>> call() => repository.getRestaurants();
}
