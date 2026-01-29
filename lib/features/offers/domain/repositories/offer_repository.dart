import '../entities/offer_entity.dart';

abstract class OfferRepository {
  Future<List<OfferEntity>> getOffersByRestaurantAndDate(
    String restaurantId,
    String date,
  );
  Future<List<OfferEntity>> getOffersByRestaurantAndDateRange(
    String restaurantId,
    String startDate,
    String endDate,
  );
  Future<OfferEntity> getOfferById(String id);
}
