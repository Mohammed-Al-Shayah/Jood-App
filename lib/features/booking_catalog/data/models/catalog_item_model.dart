import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/localized_value_utils.dart';
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
    super.exclusions,
    super.termsAndConditions,
    super.cancellationPolicy,
    required super.availableMeals,
    required super.packageOverview,
    required super.bookingNotes,
    super.location,
    super.geoLat,
    super.geoLng,
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
    final geo = _asMap(data['geo']);
    final categoryData = category == CatalogCategoryType.buffet
        ? _asMap(bookingCatalog['buffet'])
        : category == CatalogCategoryType.setMenu
        ? _asMap(bookingCatalog['setMenu'])
        : _asMap(bookingCatalog['combo']);

    final nameEn = _stringValue(data['name']);
    final nameAr = _stringValue(data['nameAr']);
    final cityIdEn = _stringValue(data['cityId']);
    final cityIdAr = _stringValue(data['cityIdAr']);
    final areaEn = _stringValue(data['area']);
    final areaAr = _stringValue(data['areaAr']);
    final addressEn = _stringValue(data['address']);
    final addressAr = _stringValue(data['addressAr']);
    final descriptionEn = _firstNonEmptyString(
      _stringValue(categoryData['description']),
      _stringValue(data['about']),
    );
    final descriptionAr = _firstNonEmptyString(
      _stringValue(categoryData['descriptionAr']),
      _stringValue(data['aboutAr']),
    );
    final highlightsEn = _firstNonEmptyList(
      _stringList(categoryData['highlights']),
      _stringList(data['highlights']),
    );
    final highlightsAr = _firstNonEmptyList(
      _stringList(categoryData['highlightsAr']),
      _stringList(data['highlightsAr']),
    );
    final inclusionsEn = _firstNonEmptyList(
      _stringList(categoryData['included']),
      _stringList(data['inclusions']),
    );
    final inclusionsAr = _firstNonEmptyList(
      _stringList(categoryData['includedAr']),
      _stringList(data['inclusionsAr']),
    );
    final exclusionsEn = _firstNonEmptyList(
      _stringList(categoryData['excluded']),
      _stringList(data['exclusions']),
    );
    final exclusionsAr = _firstNonEmptyList(
      _stringList(categoryData['excludedAr']),
      _stringList(data['exclusionsAr']),
    );
    final termsAndConditionsEn = _firstNonEmptyList(
      _stringList(categoryData['terms']),
      _stringList(categoryData['notes']),
    );
    final termsAndConditionsAr = _firstNonEmptyList(
      _stringList(categoryData['termsAr']),
      _stringList(categoryData['notesAr']),
    );
    final cancellationPolicyEn = _firstNonEmptyList(
      _stringList(categoryData['cancellationPolicy']),
      _stringList(data['cancellationPolicy']),
    );
    final cancellationPolicyAr = _firstNonEmptyList(
      _stringList(categoryData['cancellationPolicyAr']),
      _stringList(data['cancellationPolicyAr']),
    );
    final bookingNotesEn = _stringList(categoryData['notes']);
    final bookingNotesAr = _stringList(categoryData['notesAr']);
    final locationEn = _firstNonEmptyString(
      _stringValue(categoryData['location']),
      addressEn,
    );
    final locationAr = _firstNonEmptyString(
      _stringValue(categoryData['locationAr']),
      addressAr,
    );

    final availableMealsEn = category == CatalogCategoryType.combo
        ? _stringList(categoryData['availableCombos'])
        : _stringList(categoryData['availableMeals']);
    final availableMealsAr = category == CatalogCategoryType.combo
        ? _stringList(categoryData['availableCombosAr'])
        : _stringList(categoryData['availableMealsAr']);

    return CatalogItemModel(
      id: doc.id,
      category: category,
      bookingMode: category.bookingMode,
      sourceCollection: 'restaurants',
      name: resolveLocalizedText(english: nameEn, arabic: nameAr),
      cityId: resolveLocalizedText(english: cityIdEn, arabic: cityIdAr),
      area: resolveLocalizedText(english: areaEn, arabic: areaAr),
      address: resolveLocalizedText(english: addressEn, arabic: addressAr),
      rating: NumberUtils.toDouble(data['rating']),
      reviewsCount: NumberUtils.toInt(data['reviewsCount']),
      coverImageUrl: _stringValue(data['coverImageUrl']),
      description: resolveLocalizedText(
        english: descriptionEn,
        arabic: descriptionAr,
      ),
      highlights: resolveLocalizedList(
        english: highlightsEn,
        arabic: highlightsAr,
      ),
      inclusions: resolveLocalizedList(
        english: inclusionsEn,
        arabic: inclusionsAr,
      ),
      exclusions: resolveLocalizedList(
        english: exclusionsEn,
        arabic: exclusionsAr,
      ),
      termsAndConditions: resolveLocalizedList(
        english: termsAndConditionsEn,
        arabic: termsAndConditionsAr,
      ),
      cancellationPolicy: resolveLocalizedList(
        english: cancellationPolicyEn,
        arabic: cancellationPolicyAr,
      ),
      availableMeals: resolveLocalizedList(
        english: availableMealsEn,
        arabic: availableMealsAr,
        fallback: category == CatalogCategoryType.setMenu
            ? [
                AppStrings.breakfastSetMenu,
                AppStrings.lunchSetMenu,
                AppStrings.dinner,
              ]
            : category == CatalogCategoryType.combo
            ? _stringList(categoryData['availableCombos'])
            : [AppStrings.breakfast, AppStrings.lunch, AppStrings.dinner],
      ),
      packageOverview: const [],
      bookingNotes: resolveLocalizedList(
        english: bookingNotesEn,
        arabic: bookingNotesAr,
      ),
      location: resolveLocalizedText(english: locationEn, arabic: locationAr),
      geoLat: NumberUtils.toDouble(geo['lat']),
      geoLng: NumberUtils.toDouble(geo['lng']),
      requiresMenuItemSelection:
          category == CatalogCategoryType.setMenu &&
          (categoryData['requiresItemSelection'] as bool? ?? true),
      badge: _catalogLabel(
        primary: categoryData,
        fallback: bookingCatalog,
        labels: labels.badge,
        key: 'badge',
        overrideStoredValues: labels.overrideStoredValues,
      ),
      priceFrom: _catalogLabel(
        primary: categoryData,
        fallback: bookingCatalog,
        labels: labels.priceFrom,
        key: 'priceFrom',
        overrideStoredValues: labels.overrideStoredValues,
      ),
      discount: _catalogLabel(
        primary: categoryData,
        fallback: bookingCatalog,
        labels: labels.discount,
        key: 'discount',
        overrideStoredValues: labels.overrideStoredValues,
      ),
      slotsLeft: _catalogLabel(
        primary: categoryData,
        fallback: bookingCatalog,
        labels: labels.slotsLeft,
        key: 'slotsLeft',
        overrideStoredValues: labels.overrideStoredValues,
      ),
      isActive: data['isActive'] as bool? ?? true,
    );
  }

  factory CatalogItemModel.fromAttractionDoc({
    required DocumentSnapshot<Map<String, dynamic>> doc,
    required CatalogListLabels labels,
  }) {
    final data = doc.data() ?? const <String, dynamic>{};
    final bookingCatalog = _asMap(data['bookingCatalog']);
    final geo = _asMap(data['geo']);

    final nameEn = _stringValue(data['name']);
    final nameAr = _stringValue(data['nameAr']);
    final cityIdEn = _stringValue(data['cityId']);
    final cityIdAr = _stringValue(data['cityIdAr']);
    final areaEn = _stringValue(data['area']);
    final areaAr = _stringValue(data['areaAr']);
    final addressEn = _stringValue(data['address']);
    final addressAr = _stringValue(data['addressAr']);
    final descriptionEn = _firstNonEmptyString(
      _stringValue(bookingCatalog['description']),
      _stringValue(data['about']),
    );
    final descriptionAr = _firstNonEmptyString(
      _stringValue(bookingCatalog['descriptionAr']),
      _stringValue(data['aboutAr']),
    );
    final highlightsEn = _firstNonEmptyList(
      _stringList(bookingCatalog['highlights']),
      _stringList(data['highlights']),
    );
    final highlightsAr = _firstNonEmptyList(
      _stringList(bookingCatalog['highlightsAr']),
      _stringList(data['highlightsAr']),
    );
    final inclusionsEn = _firstNonEmptyList(
      _stringList(bookingCatalog['included']),
      _stringList(data['inclusions']),
    );
    final inclusionsAr = _firstNonEmptyList(
      _stringList(bookingCatalog['includedAr']),
      _stringList(data['inclusionsAr']),
    );
    final exclusionsEn = _firstNonEmptyList(
      _stringList(bookingCatalog['excluded']),
      const <String>[],
    );
    final exclusionsAr = _firstNonEmptyList(
      _stringList(bookingCatalog['excludedAr']),
      const <String>[],
    );
    final legacyPackageOverviewEn = _firstNonEmptyList(
      _stringList(bookingCatalog['packageOverview']),
      _firstNonEmptyList(
        _stringList(data['packageOverview']),
        _stringList(data['packagesOverview']),
      ),
    );
    final legacyPackageOverviewAr = _firstNonEmptyList(
      _stringList(bookingCatalog['packageOverviewAr']),
      _firstNonEmptyList(
        _stringList(data['packageOverviewAr']),
        _stringList(data['packagesOverviewAr']),
      ),
    );
    final availableOptionsEn = _firstNonEmptyList(
      _stringList(bookingCatalog['availableOptions']),
      legacyPackageOverviewEn,
    );
    final availableOptionsAr = _firstNonEmptyList(
      _stringList(bookingCatalog['availableOptionsAr']),
      legacyPackageOverviewAr,
    );
    final packageOverviewEn = _firstNonEmptyList(
      legacyPackageOverviewEn,
      availableOptionsEn,
    );
    final packageOverviewAr = _firstNonEmptyList(
      legacyPackageOverviewAr,
      availableOptionsAr,
    );
    final bookingNotesEn = _stringList(bookingCatalog['notes']);
    final bookingNotesAr = _stringList(bookingCatalog['notesAr']);
    final termsAndConditionsEn = _firstNonEmptyList(
      _stringList(bookingCatalog['terms']),
      bookingNotesEn,
    );
    final termsAndConditionsAr = _firstNonEmptyList(
      _stringList(bookingCatalog['termsAr']),
      bookingNotesAr,
    );
    final cancellationPolicyEn = _firstNonEmptyList(
      _stringList(bookingCatalog['cancellationPolicy']),
      const <String>[],
    );
    final cancellationPolicyAr = _firstNonEmptyList(
      _stringList(bookingCatalog['cancellationPolicyAr']),
      const <String>[],
    );
    final locationEn = _firstNonEmptyString(
      _stringValue(bookingCatalog['location']),
      addressEn,
    );
    final locationAr = _firstNonEmptyString(
      _stringValue(bookingCatalog['locationAr']),
      addressAr,
    );

    return CatalogItemModel(
      id: doc.id,
      category: CatalogCategoryType.attraction,
      bookingMode: CatalogCategoryType.attraction.bookingMode,
      sourceCollection: 'attractions',
      name: resolveLocalizedText(english: nameEn, arabic: nameAr),
      cityId: resolveLocalizedText(english: cityIdEn, arabic: cityIdAr),
      area: resolveLocalizedText(english: areaEn, arabic: areaAr),
      address: resolveLocalizedText(english: addressEn, arabic: addressAr),
      rating: NumberUtils.toDouble(data['rating']),
      reviewsCount: NumberUtils.toInt(data['reviewsCount']),
      coverImageUrl: _stringValue(data['coverImageUrl']),
      description: resolveLocalizedText(
        english: descriptionEn,
        arabic: descriptionAr,
      ),
      highlights: resolveLocalizedList(
        english: highlightsEn,
        arabic: highlightsAr,
      ),
      inclusions: resolveLocalizedList(
        english: inclusionsEn,
        arabic: inclusionsAr,
      ),
      exclusions: resolveLocalizedList(
        english: exclusionsEn,
        arabic: exclusionsAr,
      ),
      termsAndConditions: resolveLocalizedList(
        english: termsAndConditionsEn,
        arabic: termsAndConditionsAr,
      ),
      cancellationPolicy: resolveLocalizedList(
        english: cancellationPolicyEn,
        arabic: cancellationPolicyAr,
      ),
      availableMeals: resolveLocalizedList(
        english: availableOptionsEn,
        arabic: availableOptionsAr,
      ),
      packageOverview: resolveLocalizedList(
        english: packageOverviewEn,
        arabic: packageOverviewAr,
      ),
      bookingNotes: resolveLocalizedList(
        english: bookingNotesEn,
        arabic: bookingNotesAr,
      ),
      location: resolveLocalizedText(english: locationEn, arabic: locationAr),
      geoLat: NumberUtils.toDouble(geo['lat']),
      geoLng: NumberUtils.toDouble(geo['lng']),
      requiresMenuItemSelection: false,
      badge: _catalogLabel(
        primary: bookingCatalog,
        labels: labels.badge,
        key: 'badge',
        overrideStoredValues: labels.overrideStoredValues,
      ),
      priceFrom: _catalogLabel(
        primary: bookingCatalog,
        labels: labels.priceFrom,
        key: 'priceFrom',
        overrideStoredValues: labels.overrideStoredValues,
      ),
      discount: _catalogLabel(
        primary: bookingCatalog,
        labels: labels.discount,
        key: 'discount',
        overrideStoredValues: labels.overrideStoredValues,
      ),
      slotsLeft: _catalogLabel(
        primary: bookingCatalog,
        labels: labels.slotsLeft,
        key: 'slotsLeft',
        overrideStoredValues: labels.overrideStoredValues,
      ),
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
          .toList(growable: false);
      if (result.isNotEmpty) return result;
    }
    if (value is String && value.trim().isNotEmpty) {
      return [value.trim()];
    }
    return fallback;
  }

  static String _stringValue(dynamic value) {
    if (value == null) return '';
    return value.toString().trim();
  }

  static String _catalogLabel({
    required Map<String, dynamic> primary,
    Map<String, dynamic> fallback = const <String, dynamic>{},
    required String labels,
    required String key,
    required bool overrideStoredValues,
  }) {
    if (overrideStoredValues) {
      return labels;
    }

    final english = _firstNonEmptyString(
      _stringValue(primary[key]),
      _stringValue(fallback[key]),
    );
    final arabic = _firstNonEmptyString(
      _stringValue(primary['${key}Ar']),
      _stringValue(fallback['${key}Ar']),
    );
    return resolveLocalizedText(
      english: english,
      arabic: arabic,
      fallback: labels,
    );
  }

  static String _firstNonEmptyString(String primary, String fallback) {
    if (primary.trim().isNotEmpty) return primary.trim();
    return fallback.trim();
  }

  static List<String> _firstNonEmptyList(
    List<String> primary,
    List<String> fallback,
  ) {
    if (primary.isNotEmpty) return primary;
    return fallback;
  }
}

class CatalogListLabels {
  const CatalogListLabels({
    required this.badge,
    required this.priceFrom,
    required this.discount,
    required this.slotsLeft,
    this.overrideStoredValues = false,
  });

  final String badge;
  final String priceFrom;
  final String discount;
  final String slotsLeft;
  final bool overrideStoredValues;
}
