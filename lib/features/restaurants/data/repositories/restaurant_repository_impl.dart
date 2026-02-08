import '../../domain/entities/restaurant_entity.dart';
import '../../domain/repositories/restaurant_repository.dart';
import '../datasources/restaurant_remote_data_source.dart';
import '../models/restaurant_model.dart';

class RestaurantRepositoryImpl implements RestaurantRepository {
  RestaurantRepositoryImpl(this.remoteDataSource);

  final RestaurantRemoteDataSource remoteDataSource;

  @override
  Future<List<RestaurantEntity>> getRestaurants() {
    return remoteDataSource.getRestaurants();
  }

  @override
  Future<List<RestaurantEntity>> getAllRestaurants() {
    return remoteDataSource.getAllRestaurants();
  }

  @override
  Future<RestaurantEntity> getRestaurantById(String id) {
    return remoteDataSource.getRestaurantById(id);
  }

  @override
  Future<RestaurantEntity> createRestaurant(RestaurantEntity restaurant) {
    return remoteDataSource.createRestaurant(restaurant as RestaurantModel);
  }

  @override
  Future<RestaurantEntity> updateRestaurant(RestaurantEntity restaurant) {
    return remoteDataSource.updateRestaurant(restaurant as RestaurantModel);
  }

  @override
  Future<void> deleteRestaurant(String id) {
    return remoteDataSource.deleteRestaurant(id);
  }
}
