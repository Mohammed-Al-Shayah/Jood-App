import '../entities/ad_entity.dart';
import '../repositories/ad_repository.dart';

class GetAdsUseCase {
  GetAdsUseCase(this.repository);

  final AdRepository repository;

  Future<List<AdEntity>> call() {
    return repository.getAds();
  }
}
