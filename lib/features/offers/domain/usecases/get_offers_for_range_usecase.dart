import '../entities/offer_entity.dart';
import '../repositories/offer_repository.dart';

class GetOffersForRangeUseCase {
  GetOffersForRangeUseCase(this.repository);

  final OfferRepository repository;

  Future<List<OfferEntity>> call(
    String restaurantId,
    String startDate,
    String endDate,
  ) {
    return repository.getOffersByRestaurantAndDateRange(
      restaurantId,
      startDate,
      endDate,
    );
  }
}
