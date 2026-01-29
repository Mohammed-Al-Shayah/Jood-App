import '../../domain/entities/offer_entity.dart';
import '../../domain/repositories/offer_repository.dart';
import '../datasources/offer_remote_data_source.dart';

class OfferRepositoryImpl implements OfferRepository {
  OfferRepositoryImpl(this.remoteDataSource);

  final OfferRemoteDataSource remoteDataSource;

  @override
  Future<List<OfferEntity>> getOffersByRestaurantAndDate(
    String restaurantId,
    String date,
  ) {
    return remoteDataSource.getOffersByRestaurantAndDate(restaurantId, date);
  }

  @override
  Future<List<OfferEntity>> getOffersByRestaurantAndDateRange(
    String restaurantId,
    String startDate,
    String endDate,
  ) {
    return remoteDataSource.getOffersByRestaurantAndDateRange(
      restaurantId,
      startDate,
      endDate,
    );
  }

  @override
  Future<OfferEntity> getOfferById(String id) {
    return remoteDataSource.getOfferById(id);
  }
}
