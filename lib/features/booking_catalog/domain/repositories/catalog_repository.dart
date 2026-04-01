import '../entities/catalog_category_type.dart';
import '../entities/catalog_item_entity.dart';

abstract class CatalogRepository {
  Future<List<CatalogItemEntity>> getItems(CatalogCategoryType category);

  Stream<void> watchCatalogChanges();
}
