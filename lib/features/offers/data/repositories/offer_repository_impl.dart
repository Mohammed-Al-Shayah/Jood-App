import '../../domain/entities/offer_entity.dart';
import '../../domain/repositories/offer_repository.dart';
import '../datasources/offer_remote_data_source.dart';
import '../models/offer_model.dart';

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

  @override
  Future<List<OfferEntity>> getOffers() {
    return remoteDataSource.getOffers();
  }

  @override
  Future<OfferEntity> createOffer(OfferEntity offer) {
    return remoteDataSource.createOffer(offer as OfferModel);
  }

  @override
  Future<OfferEntity> updateOffer(OfferEntity offer) {
    return remoteDataSource.updateOffer(offer as OfferModel);
  }

  @override
  Future<void> deleteOffer(String id) {
    return remoteDataSource.deleteOffer(id);
  }
}
