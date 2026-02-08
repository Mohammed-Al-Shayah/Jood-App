import '../entities/offer_entity.dart';
import '../repositories/offer_repository.dart';

class GetOffersUseCase {
  GetOffersUseCase(this.repository);

  final OfferRepository repository;

  Future<List<OfferEntity>> call() {
    return repository.getOffers();
  }
}
