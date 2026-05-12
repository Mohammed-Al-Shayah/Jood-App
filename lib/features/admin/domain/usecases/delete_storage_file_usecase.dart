import '../repositories/admin_storage_repository.dart';

class DeleteStorageFileUseCase {
  DeleteStorageFileUseCase(this.repository);

  final AdminStorageRepository repository;

  Future<void> call(String url) {
    return repository.deleteByUrl(url);
  }
}
