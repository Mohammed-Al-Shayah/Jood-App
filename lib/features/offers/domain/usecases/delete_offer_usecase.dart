import '../repositories/offer_repository.dart';

class DeleteOfferUseCase {
  DeleteOfferUseCase(this.repository);

  final OfferRepository repository;

  Future<void> call(String id) {
    return repository.deleteOffer(id);
  }
}
