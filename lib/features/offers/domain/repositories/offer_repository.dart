import '../entities/offer_entity.dart';

abstract class OfferRepository {
  Future<List<OfferEntity>> getOffersByRestaurantAndDate(
    String restaurantId,
    String date,
  );
  Future<OfferEntity> getOfferById(String id);
}
