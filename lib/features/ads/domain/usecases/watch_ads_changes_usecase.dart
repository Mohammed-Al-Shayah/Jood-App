import '../repositories/ad_repository.dart';

class WatchAdsChangesUseCase {
  WatchAdsChangesUseCase(this.repository);

  final AdRepository repository;

  Stream<void> call() {
    return repository.watchAdsChanges();
  }
}
