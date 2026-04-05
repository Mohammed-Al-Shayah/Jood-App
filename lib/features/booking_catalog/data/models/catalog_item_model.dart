import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/number_utils.dart';
import '../../domain/entities/catalog_category_type.dart';
import '../../domain/entities/catalog_item_entity.dart';

class CatalogItemModel extends CatalogItemEntity {
  const CatalogItemModel({
    required super.id,
    required super.category,
    required super.bookingMode,
    required super.sourceCollection,
    required super.name,
    required super.cityId,
    required super.area,
    required super.address,
    required super.rating,
    required super.reviewsCount,
    required super.coverImageUrl,
    required super.description,
    required super.highlights,
    required super.inclusions,
    required super.availableMeals,
    required super.packageOverview,
    required super.bookingNotes,
    required super.requiresMenuItemSelection,
    required super.badge,
    required super.priceFrom,
    required super.discount,
    required super.slotsLeft,
    required super.isActive,
  });

  factory CatalogItemModel.fromRestaurantDoc({
    required DocumentSnapshot<Map<String, dynamic>> doc,
    required CatalogCategoryType category,
    required CatalogListLabels labels,
  }) {
    final data = doc.data() ?? const <String, dynamic>{};
    final bookingCatalog = _asMap(data['bookingCatalog']);
    final categoryData = category == CatalogCategoryType.buffet
        ? _asMap(bookingCatalog['buffet'])
        : _asMap(bookingCatalog['setMenu']);

    final description =
        _stringValue(categoryData['description']).trim().isNotEmpty
        ? _stringValue(categoryData['description']).trim()
        : _stringValue(data['about']).trim();

    return CatalogItemModel(
      id: doc.id,
      category: category,
      bookingMode: category.bookingMode,
      sourceCollection: 'restaurants',
      name: _stringValue(data['name']),
      cityId: _stringValue(data['cityId']),
      area: _stringValue(data['area']),
      address: _stringValue(data['address']),
      rating: NumberUtils.toDouble(data['rating']),
      reviewsCount: NumberUtils.toInt(data['reviewsCount']),
      coverImageUrl: _stringValue(data['coverImageUrl']),
      description: description,
      highlights: _stringList(
        categoryData['highlights'],
        fallback: _stringList(data['highlights']),
      ),
      inclusions: _stringList(
        categoryData['included'],
        fallback: _stringList(data['inclusions']),
      ),
      availableMeals: _stringList(
        categoryData['availableMeals'],
        fallback: category == CatalogCategoryType.setMenu
            ? [
                AppStrings.breakfastSetMenu,
                AppStrings.lunchSetMenu,
                AppStrings.dinner,
              ]
            : [AppStrings.breakfast, AppStrings.lunch, AppStrings.dinner],
      ),
      packageOverview: const [],
      bookingNotes: _stringList(categoryData['notes']),
      requiresMenuItemSelection:
          category == CatalogCategoryType.setMenu &&
          (categoryData['requiresItemSelection'] as bool? ?? true),
      badge: _stringValue(categoryData['badge']).trim().isNotEmpty
          ? _stringValue(categoryData['badge']).trim()
          : labels.badge,
      priceFrom: _stringValue(categoryData['priceFrom']).trim().isNotEmpty
          ? _stringValue(categoryData['priceFrom']).trim()
          : labels.priceFrom,
      discount: _stringValue(categoryData['discount']).trim().isNotEmpty
          ? _stringValue(categoryData['discount']).trim()
          : labels.discount,
      slotsLeft: _stringValue(categoryData['slotsLeft']).trim().isNotEmpty
          ? _stringValue(categoryData['slotsLeft']).trim()
          : labels.slotsLeft,
      isActive: data['isActive'] as bool? ?? true,
    );
  }

  factory CatalogItemModel.fromAttractionDoc({
    required DocumentSnapshot<Map<String, dynamic>> doc,
    required CatalogListLabels labels,
  }) {
    final data = doc.data() ?? const <String, dynamic>{};
    final bookingCatalog = _asMap(data['bookingCatalog']);
    final description =
        _stringValue(bookingCatalog['description']).trim().isNotEmpty
        ? _stringValue(bookingCatalog['description']).trim()
        : _stringValue(data['about']).trim();

    return CatalogItemModel(
      id: doc.id,
      category: CatalogCategoryType.attraction,
      bookingMode: CatalogCategoryType.attraction.bookingMode,
      sourceCollection: 'attractions',
      name: _stringValue(data['name']),
      cityId: _stringValue(data['cityId']),
      area: _stringValue(data['area']),
      address: _stringValue(data['address']),
      rating: NumberUtils.toDouble(data['rating']),
      reviewsCount: NumberUtils.toInt(data['reviewsCount']),
      coverImageUrl: _stringValue(data['coverImageUrl']),
      description: description,
      highlights: _stringList(
        bookingCatalog['highlights'],
        fallback: _stringList(data['highlights']),
      ),
      inclusions: _stringList(
        bookingCatalog['included'],
        fallback: _stringList(data['inclusions']),
      ),
      availableMeals: const [],
      packageOverview: _stringList(
        bookingCatalog['packageOverview'],
        fallback: _stringList(
          data['packageOverview'],
          fallback: _stringList(data['packagesOverview']),
        ),
      ),
      bookingNotes: _stringList(bookingCatalog['notes']),
      requiresMenuItemSelection: false,
      badge: _stringValue(bookingCatalog['badge']).trim().isNotEmpty
          ? _stringValue(bookingCatalog['badge']).trim()
          : labels.badge,
      priceFrom: _stringValue(bookingCatalog['priceFrom']).trim().isNotEmpty
          ? _stringValue(bookingCatalog['priceFrom']).trim()
          : labels.priceFrom,
      discount: _stringValue(bookingCatalog['discount']).trim().isNotEmpty
          ? _stringValue(bookingCatalog['discount']).trim()
          : labels.discount,
      slotsLeft: _stringValue(bookingCatalog['slotsLeft']).trim().isNotEmpty
          ? _stringValue(bookingCatalog['slotsLeft']).trim()
          : labels.slotsLeft,
      isActive: data['isActive'] as bool? ?? true,
    );
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, item) => MapEntry(key.toString(), item));
    }
    return const <String, dynamic>{};
  }

  static List<String> _stringList(
    dynamic value, {
    List<String> fallback = const [],
  }) {
    if (value is List) {
      final result = value
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList();
      if (result.isNotEmpty) return result;
    }
    if (value is String && value.trim().isNotEmpty) {
      return [value.trim()];
    }
    return fallback;
  }

  static String _stringValue(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }
}

class CatalogListLabels {
  const CatalogListLabels({
    required this.badge,
    required this.priceFrom,
    required this.discount,
    required this.slotsLeft,
  });

  final String badge;
  final String priceFrom;
  final String discount;
  final String slotsLeft;
}
