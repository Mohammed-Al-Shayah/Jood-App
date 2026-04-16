import '../entities/ad_entity.dart';
import '../repositories/ad_repository.dart';

class UpdateAdUseCase {
  UpdateAdUseCase(this.repository);

  final AdRepository repository;

  Future<AdEntity> call(AdEntity ad) {
    return repository.updateAd(ad);
  }
}
