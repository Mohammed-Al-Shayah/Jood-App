import '../entities/restaurant_entity.dart';
import '../repositories/restaurant_repository.dart';

class GetRestaurantDetailsUseCase {
  GetRestaurantDetailsUseCase(this.repository);

  final RestaurantRepository repository;

  Future<RestaurantEntity> call(String id) => repository.getRestaurantById(id);
}
