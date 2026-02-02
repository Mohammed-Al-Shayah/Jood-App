import '../../domain/repositories/restaurant_repository.dart';
import '../datasources/restaurant_remote_data_source.dart';
import '../../../restaurants/domain/entities/restaurant_entity.dart';

class RestaurantRepositoryImpl implements RestaurantRepository {
  RestaurantRepositoryImpl({required RestaurantRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final RestaurantRemoteDataSource _remoteDataSource;

  @override
  Future<List<RestaurantEntity>> getRestaurants() {
    return _remoteDataSource.fetchRestaurants();
  }
}
