import '../entities/offer_entity.dart';
import '../repositories/offer_repository.dart';

class CreateOfferUseCase {
  CreateOfferUseCase(this.repository);

  final OfferRepository repository;

  Future<OfferEntity> call(OfferEntity offer) {
    return repository.createOffer(offer);
  }

  Future<void> many(List<OfferEntity> offers) {
    return repository.createOffers(offers);
  }
}
