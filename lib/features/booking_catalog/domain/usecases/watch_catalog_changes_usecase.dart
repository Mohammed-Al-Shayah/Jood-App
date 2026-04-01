import '../repositories/catalog_repository.dart';

class WatchCatalogChangesUseCase {
  WatchCatalogChangesUseCase(this.repository);

  final CatalogRepository repository;

  Stream<void> call() {
    return repository.watchCatalogChanges();
  }
}
