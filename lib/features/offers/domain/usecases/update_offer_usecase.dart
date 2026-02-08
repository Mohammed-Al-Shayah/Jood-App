import '../entities/offer_entity.dart';
import '../repositories/offer_repository.dart';

class UpdateOfferUseCase {
  UpdateOfferUseCase(this.repository);

  final OfferRepository repository;

  Future<OfferEntity> call(OfferEntity offer) {
    return repository.updateOffer(offer);
  }
}
