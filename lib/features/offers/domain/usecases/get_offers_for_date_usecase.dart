import '../entities/offer_entity.dart';
import '../repositories/offer_repository.dart';

class GetOffersForDateUseCase {
  GetOffersForDateUseCase(this.repository);

  final OfferRepository repository;

  Future<List<OfferEntity>> call(String restaurantId, String date) {
    return repository.getOffersByRestaurantAndDate(restaurantId, date);
  }
}
