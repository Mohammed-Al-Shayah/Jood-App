import '../../domain/entities/catalog_category_type.dart';
import '../../domain/entities/catalog_item_entity.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../datasources/catalog_remote_data_source.dart';

class CatalogRepositoryImpl implements CatalogRepository {
  CatalogRepositoryImpl(this.remoteDataSource);

  final CatalogRemoteDataSource remoteDataSource;

  @override
  Future<List<CatalogItemEntity>> getItems(CatalogCategoryType category) {
    return remoteDataSource.getItems(category);
  }

  @override
  Stream<void> watchCatalogChanges() {
    return remoteDataSource.watchCatalogChanges();
  }
}
