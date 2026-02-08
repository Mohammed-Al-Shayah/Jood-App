import '../entities/restaurant_entity.dart';

abstract class RestaurantRepository {
  Future<List<RestaurantEntity>> getRestaurants();
  Future<List<RestaurantEntity>> getAllRestaurants();
  Future<RestaurantEntity> getRestaurantById(String id);
  Future<RestaurantEntity> createRestaurant(RestaurantEntity restaurant);
  Future<RestaurantEntity> updateRestaurant(RestaurantEntity restaurant);
  Future<void> deleteRestaurant(String id);
}
