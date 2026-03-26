import 'package:jood/features/booking_catalog/domain/entities/catalog_category_type.dart';
import 'package:jood/features/booking_catalog/domain/entities/catalog_item_entity.dart';

class CatalogListArgs {
  const CatalogListArgs({required this.category});

  final CatalogCategoryType category;
}

class CatalogDetailArgs {
  const CatalogDetailArgs({required this.item});

  final CatalogItemEntity item;
}

class CatalogBookingArgs {
  const CatalogBookingArgs({required this.item});

  final CatalogItemEntity item;
}
