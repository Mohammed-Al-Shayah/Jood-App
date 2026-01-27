import '../../domain/entities/restaurant_entity.dart';
import '../../domain/repositories/restaurant_repository.dart';
import '../datasources/restaurant_remote_data_source.dart';

class RestaurantRepositoryImpl implements RestaurantRepository {
  RestaurantRepositoryImpl(this.remoteDataSource);

  final RestaurantRemoteDataSource remoteDataSource;

  @override
  Future<List<RestaurantEntity>> getRestaurants() {
    return remoteDataSource.getRestaurants();
  }

  @override
  Future<RestaurantEntity> getRestaurantById(String id) {
    return remoteDataSource.getRestaurantById(id);
  }
}
