import '../../domain/entities/catalog_category_type.dart';
import '../../domain/entities/catalog_item_entity.dart';

enum CatalogListStatus { initial, loading, success, failure }

class CatalogListState {
  const CatalogListState({
    required this.status,
    required this.category,
    required this.items,
    this.errorMessage,
  });

  final CatalogListStatus status;
  final CatalogCategoryType category;
  final List<CatalogItemEntity> items;
  final String? errorMessage;

  CatalogListState copyWith({
    CatalogListStatus? status,
    CatalogCategoryType? category,
    List<CatalogItemEntity>? items,
    String? errorMessage,
  }) {
    return CatalogListState(
      status: status ?? this.status,
      category: category ?? this.category,
      items: items ?? this.items,
      errorMessage: errorMessage,
    );
  }

  factory CatalogListState.initial() {
    return const CatalogListState(
      status: CatalogListStatus.initial,
      category: CatalogCategoryType.buffet,
      items: [],
    );
  }
}
