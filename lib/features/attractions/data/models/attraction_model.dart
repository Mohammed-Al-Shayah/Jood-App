import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/utils/localized_value_utils.dart';
import '../../../../core/utils/number_utils.dart';
import '../../domain/entities/attraction_entity.dart';

class AttractionModel extends AttractionEntity {
  const AttractionModel({
    required super.id,
    required super.name,
    required super.cityId,
    required super.area,
    required super.rating,
    required super.reviewsCount,
    required super.coverImageUrl,
    required super.about,
    required super.phone,
    required super.address,
    required super.highlights,
    required super.inclusions,
    required super.catalogDescription,
    required super.catalogHighlights,
    required super.catalogIncluded,
    required super.packageOverview,
    required super.bookingNotes,
    required super.isActive,
    required super.createdAt,
    super.badge,
    super.priceFrom,
    super.discount,
    super.slotsLeft,
    super.nameEn,
    super.nameAr,
    super.cityIdEn,
    super.cityIdAr,
    super.areaEn,
    super.areaAr,
    super.aboutEn,
    super.aboutAr,
    super.addressEn,
    super.addressAr,
    super.highlightsEn,
    super.highlightsAr,
    super.inclusionsEn,
    super.inclusionsAr,
    super.catalogDescriptionEn,
    super.catalogDescriptionAr,
    super.catalogHighlightsEn,
    super.catalogHighlightsAr,
    super.catalogIncludedEn,
    super.catalogIncludedAr,
    super.packageOverviewEn,
    super.packageOverviewAr,
    super.bookingNotesEn,
    super.bookingNotesAr,
  });

  factory AttractionModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return AttractionModel.fromMap(id: doc.id, data: data);
  }

  factory AttractionModel.fromMap({
    required String id,
    required Map<String, dynamic> data,
  }) {
    final bookingCatalog = _asMap(data['bookingCatalog']);

    final nameEn = _stringValue(data['name']);
    final nameAr = _stringValue(data['nameAr']);
    final cityIdEn = _stringValue(data['cityId']);
    final cityIdAr = _stringValue(data['cityIdAr']);
    final areaEn = _stringValue(data['area']);
    final areaAr = _stringValue(data['areaAr']);
    final aboutEn = _stringValue(data['about']);
    final aboutAr = _stringValue(data['aboutAr']);
    final addressEn = _stringValue(data['address']);
    final addressAr = _stringValue(data['addressAr']);
    final highlightsEn = _stringList(data['highlights']);
    final highlightsAr = _stringList(data['highlightsAr']);
    final inclusionsEn = _stringList(data['inclusions']);
    final inclusionsAr = _stringList(data['inclusionsAr']);

    final catalogDescriptionEn = _firstNonEmptyString(
      _stringValue(bookingCatalog['description']),
      aboutEn,
    );
    final catalogDescriptionAr = _firstNonEmptyString(
      _stringValue(bookingCatalog['descriptionAr']),
      aboutAr,
    );
    final catalogHighlightsEn = _firstNonEmptyList(
      _stringList(bookingCatalog['highlights']),
      highlightsEn,
    );
    final catalogHighlightsAr = _firstNonEmptyList(
      _stringList(bookingCatalog['highlightsAr']),
      highlightsAr,
    );
    final catalogIncludedEn = _firstNonEmptyList(
      _stringList(bookingCatalog['included']),
      inclusionsEn,
    );
    final catalogIncludedAr = _firstNonEmptyList(
      _stringList(bookingCatalog['includedAr']),
      inclusionsAr,
    );
    final packageOverviewEn = _firstNonEmptyList(
      _stringList(bookingCatalog['packageOverview']),
      _firstNonEmptyList(
        _stringList(data['packageOverview']),
        _stringList(data['packagesOverview']),
      ),
    );
    final packageOverviewAr = _firstNonEmptyList(
      _stringList(bookingCatalog['packageOverviewAr']),
      _firstNonEmptyList(
        _stringList(data['packageOverviewAr']),
        _stringList(data['packagesOverviewAr']),
      ),
    );
    final bookingNotesEn = _stringList(bookingCatalog['notes']);
    final bookingNotesAr = _stringList(bookingCatalog['notesAr']);

    return AttractionModel(
      id: id,
      name: resolveLocalizedText(english: nameEn, arabic: nameAr),
      cityId: resolveLocalizedText(english: cityIdEn, arabic: cityIdAr),
      area: resolveLocalizedText(english: areaEn, arabic: areaAr),
      rating: NumberUtils.toDouble(data['rating']),
      reviewsCount: NumberUtils.toInt(data['reviewsCount']),
      coverImageUrl: _stringValue(data['coverImageUrl']),
      about: resolveLocalizedText(english: aboutEn, arabic: aboutAr),
      phone: _stringValue(data['phone']),
      address: resolveLocalizedText(english: addressEn, arabic: addressAr),
      highlights: resolveLocalizedList(
        english: highlightsEn,
        arabic: highlightsAr,
      ),
      inclusions: resolveLocalizedList(
        english: inclusionsEn,
        arabic: inclusionsAr,
      ),
      catalogDescription: resolveLocalizedText(
        english: catalogDescriptionEn,
        arabic: catalogDescriptionAr,
      ),
      catalogHighlights: resolveLocalizedList(
        english: catalogHighlightsEn,
        arabic: catalogHighlightsAr,
      ),
      catalogIncluded: resolveLocalizedList(
        english: catalogIncludedEn,
        arabic: catalogIncludedAr,
      ),
      packageOverview: resolveLocalizedList(
        english: packageOverviewEn,
        arabic: packageOverviewAr,
      ),
      bookingNotes: resolveLocalizedList(
        english: bookingNotesEn,
        arabic: bookingNotesAr,
      ),
      isActive: data['isActive'] as bool? ?? true,
      createdAt: _toDateTime(data['createdAt']),
      badge: _catalogLabelValue(
        bookingCatalog: bookingCatalog,
        rootValue: data['badge'],
        key: 'badge',
      ),
      priceFrom: _catalogLabelValue(
        bookingCatalog: bookingCatalog,
        rootValue: data['priceFrom'],
        key: 'priceFrom',
      ),
      discount: _catalogLabelValue(
        bookingCatalog: bookingCatalog,
        rootValue: data['discount'],
        key: 'discount',
      ),
      slotsLeft: _catalogLabelValue(
        bookingCatalog: bookingCatalog,
        rootValue: data['slotsLeft'],
        key: 'slotsLeft',
      ),
      nameEn: nameEn,
      nameAr: nameAr,
      cityIdEn: cityIdEn,
      cityIdAr: cityIdAr,
      areaEn: areaEn,
      areaAr: areaAr,
      aboutEn: aboutEn,
      aboutAr: aboutAr,
      addressEn: addressEn,
      addressAr: addressAr,
      highlightsEn: highlightsEn,
      highlightsAr: highlightsAr,
      inclusionsEn: inclusionsEn,
      inclusionsAr: inclusionsAr,
      catalogDescriptionEn: catalogDescriptionEn,
      catalogDescriptionAr: catalogDescriptionAr,
      catalogHighlightsEn: catalogHighlightsEn,
      catalogHighlightsAr: catalogHighlightsAr,
      catalogIncludedEn: catalogIncludedEn,
      catalogIncludedAr: catalogIncludedAr,
      packageOverviewEn: packageOverviewEn,
      packageOverviewAr: packageOverviewAr,
      bookingNotesEn: bookingNotesEn,
      bookingNotesAr: bookingNotesAr,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': _baseText(nameEn, name),
      'nameAr': nameAr.trim(),
      'cityId': _baseText(cityIdEn, cityId),
      'cityIdAr': cityIdAr.trim(),
      'area': _baseText(areaEn, area),
      'areaAr': areaAr.trim(),
      'rating': rating,
      'reviewsCount': reviewsCount,
      'coverImageUrl': coverImageUrl,
      'about': _baseText(aboutEn, about),
      'aboutAr': aboutAr.trim(),
      'phone': phone,
      'address': _baseText(addressEn, address),
      'addressAr': addressAr.trim(),
      'highlights': _baseList(highlightsEn, highlights),
      'highlightsAr': _cleanList(highlightsAr),
      'inclusions': _baseList(inclusionsEn, inclusions),
      'inclusionsAr': _cleanList(inclusionsAr),
      'badge': badge,
      'priceFrom': priceFrom,
      'discount': discount,
      'slotsLeft': slotsLeft,
      'isActive': isActive,
      'bookingCatalog': {
        'description': _baseText(catalogDescriptionEn, catalogDescription),
        'descriptionAr': catalogDescriptionAr.trim(),
        'highlights': _baseList(catalogHighlightsEn, catalogHighlights),
        'highlightsAr': _cleanList(catalogHighlightsAr),
        'included': _baseList(catalogIncludedEn, catalogIncluded),
        'includedAr': _cleanList(catalogIncludedAr),
        'packageOverview': _baseList(packageOverviewEn, packageOverview),
        'packageOverviewAr': _cleanList(packageOverviewAr),
        'notes': _baseList(bookingNotesEn, bookingNotes),
        'notesAr': _cleanList(bookingNotesAr),
        'badge': badge,
        'priceFrom': priceFrom,
        'discount': discount,
        'slotsLeft': slotsLeft,
      },
    };
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, item) => MapEntry(key.toString(), item));
    }
    return const <String, dynamic>{};
  }

  static List<String> _stringList(dynamic value) {
    if (value is List) {
      return value
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList(growable: false);
    }
    if (value is String && value.trim().isNotEmpty) {
      return [value.trim()];
    }
    return const [];
  }

  static String _stringValue(dynamic value) {
    if (value == null) return '';
    return value.toString().trim();
  }

  static String _catalogLabelValue({
    required Map<String, dynamic> bookingCatalog,
    required dynamic rootValue,
    required String key,
  }) {
    final catalogValue = _stringValue(bookingCatalog[key]).trim();
    if (catalogValue.isNotEmpty) return catalogValue;
    return _stringValue(rootValue).trim();
  }

  static DateTime _toDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.now();
  }

  static String _baseText(String rawEnglish, String fallback) {
    final english = rawEnglish.trim();
    if (english.isNotEmpty) return english;
    return fallback.trim();
  }

  static List<String> _baseList(
    List<String> rawEnglish,
    List<String> fallback,
  ) {
    final english = _cleanList(rawEnglish);
    if (english.isNotEmpty) return english;
    return _cleanList(fallback);
  }

  static List<String> _cleanList(List<String> values) {
    return values
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
  }

  static String _firstNonEmptyString(String primary, String fallback) {
    if (primary.trim().isNotEmpty) return primary.trim();
    return fallback.trim();
  }

  static List<String> _firstNonEmptyList(
    List<String> primary,
    List<String> fallback,
  ) {
    final normalizedPrimary = _cleanList(primary);
    if (normalizedPrimary.isNotEmpty) return normalizedPrimary;
    return _cleanList(fallback);
  }
}
