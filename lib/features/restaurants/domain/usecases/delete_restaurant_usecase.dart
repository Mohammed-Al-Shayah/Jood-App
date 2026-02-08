import '../repositories/restaurant_repository.dart';

class DeleteRestaurantUseCase {
  DeleteRestaurantUseCase(this.repository);

  final RestaurantRepository repository;

  Future<void> call(String id) {
    return repository.deleteRestaurant(id);
  }
}
