import '../../domain/entities/restaurant.dart';
import '../../domain/repositories/restaurant_repository.dart';
import '../datasources/restaurant_remote_data_source.dart';

class RestaurantRepositoryImpl implements RestaurantRepository {
  RestaurantRepositoryImpl({required RestaurantRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final RestaurantRemoteDataSource _remoteDataSource;

  @override
  Future<List<Restaurant>> getRestaurants() {
    return _remoteDataSource.fetchRestaurants();
  }
}
