import '../entities/ad_entity.dart';
import '../repositories/ad_repository.dart';

class GetActiveAdsUseCase {
  GetActiveAdsUseCase(this.repository);

  final AdRepository repository;

  Future<List<AdEntity>> call() {
    return repository.getActiveAds();
  }
}
