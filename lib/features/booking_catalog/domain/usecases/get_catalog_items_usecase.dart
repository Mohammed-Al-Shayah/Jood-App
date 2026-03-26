import '../entities/catalog_category_type.dart';
import '../entities/catalog_item_entity.dart';
import '../repositories/catalog_repository.dart';

class GetCatalogItemsUseCase {
  GetCatalogItemsUseCase(this.repository);

  final CatalogRepository repository;

  Future<List<CatalogItemEntity>> call(CatalogCategoryType category) {
    return repository.getItems(category);
  }
}
