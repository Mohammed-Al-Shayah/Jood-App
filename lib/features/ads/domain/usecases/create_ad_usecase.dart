import '../entities/ad_entity.dart';
import '../repositories/ad_repository.dart';

class CreateAdUseCase {
  CreateAdUseCase(this.repository);

  final AdRepository repository;

  Future<AdEntity> call(AdEntity ad) {
    return repository.createAd(ad);
  }
}
