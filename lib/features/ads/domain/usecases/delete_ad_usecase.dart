import '../repositories/ad_repository.dart';

class DeleteAdUseCase {
  DeleteAdUseCase(this.repository);

  final AdRepository repository;

  Future<void> call(String id) {
    return repository.deleteAd(id);
  }
}
