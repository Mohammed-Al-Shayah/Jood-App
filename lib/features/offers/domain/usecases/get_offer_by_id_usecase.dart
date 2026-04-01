import '../entities/offer_entity.dart';
import '../repositories/offer_repository.dart';

class GetOfferByIdUseCase {
  GetOfferByIdUseCase(this.repository);

  final OfferRepository repository;

  Future<OfferEntity> call(String id) {
    return repository.getOfferById(id);
  }
}
