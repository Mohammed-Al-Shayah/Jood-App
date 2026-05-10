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
    super.geoLat,
    super.geoLng,
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
    super.catalogExcluded,
    super.catalogTermsAndConditions,
    super.catalogCancellationPolicy,
    super.catalogAvailableOptions,
    super.catalogLocation,
    super.catalogExcludedEn,
    super.catalogExcludedAr,
    super.catalogTermsAndConditionsEn,
    super.catalogTermsAndConditionsAr,
    super.catalogCancellationPolicyEn,
    super.catalogCancellationPolicyAr,
    super.catalogAvailableOptionsEn,
    super.catalogAvailableOptionsAr,
    super.catalogLocationEn,
    super.catalogLocationAr,
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
    final geoPoint = _resolveGeoPoint(data);

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
    final catalogAvailableOptionsEn = _firstNonEmptyList(
      _stringList(bookingCatalog['availableOptions']),
      legacyPackageOverviewEn,
    );
    final catalogAvailableOptionsAr = _firstNonEmptyList(
      _stringList(bookingCatalog['availableOptionsAr']),
      legacyPackageOverviewAr,
    );
    final packageOverviewEn = _firstNonEmptyList(
      legacyPackageOverviewEn,
      catalogAvailableOptionsEn,
    );
    final packageOverviewAr = _firstNonEmptyList(
      legacyPackageOverviewAr,
      catalogAvailableOptionsAr,
    );
    final bookingNotesEn = _stringList(bookingCatalog['notes']);
    final bookingNotesAr = _stringList(bookingCatalog['notesAr']);
    final catalogExcludedEn = _stringList(bookingCatalog['excluded']);
    final catalogExcludedAr = _stringList(bookingCatalog['excludedAr']);
    final catalogTermsAndConditionsEn = _firstNonEmptyList(
      _stringList(bookingCatalog['terms']),
      bookingNotesEn,
    );
    final catalogTermsAndConditionsAr = _firstNonEmptyList(
      _stringList(bookingCatalog['termsAr']),
      bookingNotesAr,
    );
    final catalogCancellationPolicyEn = _stringList(
      bookingCatalog['cancellationPolicy'],
    );
    final catalogCancellationPolicyAr = _stringList(
      bookingCatalog['cancellationPolicyAr'],
    );
    final catalogLocationEn = _firstNonEmptyString(
      _stringValue(bookingCatalog['location']),
      addressEn,
    );
    final catalogLocationAr = _firstNonEmptyString(
      _stringValue(bookingCatalog['locationAr']),
      addressAr,
    );

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
      geoLat: geoPoint.latitude,
      geoLng: geoPoint.longitude,
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
      catalogExcluded: resolveLocalizedList(
        english: catalogExcludedEn,
        arabic: catalogExcludedAr,
      ),
      catalogTermsAndConditions: resolveLocalizedList(
        english: catalogTermsAndConditionsEn,
        arabic: catalogTermsAndConditionsAr,
      ),
      catalogCancellationPolicy: resolveLocalizedList(
        english: catalogCancellationPolicyEn,
        arabic: catalogCancellationPolicyAr,
      ),
      catalogAvailableOptions: resolveLocalizedList(
        english: catalogAvailableOptionsEn,
        arabic: catalogAvailableOptionsAr,
      ),
      catalogLocation: resolveLocalizedText(
        english: catalogLocationEn,
        arabic: catalogLocationAr,
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
      catalogExcludedEn: catalogExcludedEn,
      catalogExcludedAr: catalogExcludedAr,
      catalogTermsAndConditionsEn: catalogTermsAndConditionsEn,
      catalogTermsAndConditionsAr: catalogTermsAndConditionsAr,
      catalogCancellationPolicyEn: catalogCancellationPolicyEn,
      catalogCancellationPolicyAr: catalogCancellationPolicyAr,
      catalogAvailableOptionsEn: catalogAvailableOptionsEn,
      catalogAvailableOptionsAr: catalogAvailableOptionsAr,
      catalogLocationEn: catalogLocationEn,
      catalogLocationAr: catalogLocationAr,
    );
  }

  Map<String, dynamic> toMap() {
    final resolvedPackageOverview = _baseList(
      packageOverviewEn,
      packageOverview,
    );
    final resolvedPackageOverviewAr = _cleanList(packageOverviewAr);
    final resolvedBookingNotes = _baseList(bookingNotesEn, bookingNotes);
    final resolvedBookingNotesAr = _cleanList(bookingNotesAr);
    final resolvedCatalogOptions = _firstNonEmptyList(
      _baseList(catalogAvailableOptionsEn, catalogAvailableOptions),
      resolvedPackageOverview,
    );
    final resolvedCatalogOptionsAr = _firstNonEmptyList(
      _cleanList(catalogAvailableOptionsAr),
      resolvedPackageOverviewAr,
    );
    final resolvedCatalogTerms = _firstNonEmptyList(
      _baseList(catalogTermsAndConditionsEn, catalogTermsAndConditions),
      resolvedBookingNotes,
    );
    final resolvedCatalogTermsAr = _firstNonEmptyList(
      _cleanList(catalogTermsAndConditionsAr),
      resolvedBookingNotesAr,
    );
    final resolvedCatalogLocation = _baseText(
      catalogLocationEn,
      catalogLocation,
    );
    final resolvedCatalogLocationAr = _firstNonEmptyString(
      catalogLocationAr.trim(),
      addressAr.trim(),
    );

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
      'geo': {'lat': geoLat, 'lng': geoLng},
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
        'excluded': _baseList(catalogExcludedEn, catalogExcluded),
        'excludedAr': _cleanList(catalogExcludedAr),
        'terms': resolvedCatalogTerms,
        'termsAr': resolvedCatalogTermsAr,
        'cancellationPolicy': _baseList(
          catalogCancellationPolicyEn,
          catalogCancellationPolicy,
        ),
        'cancellationPolicyAr': _cleanList(catalogCancellationPolicyAr),
        'availableOptions': resolvedCatalogOptions,
        'availableOptionsAr': resolvedCatalogOptionsAr,
        'location': resolvedCatalogLocation,
        'locationAr': resolvedCatalogLocationAr,
        'packageOverview': resolvedPackageOverview,
        'packageOverviewAr': resolvedPackageOverviewAr,
        'notes': resolvedBookingNotes,
        'notesAr': resolvedBookingNotesAr,
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

  static _AttractionGeoPoint _resolveGeoPoint(Map<String, dynamic> data) {
    final geo = data['geo'];
    if (geo is GeoPoint) {
      return _AttractionGeoPoint(geo.latitude, geo.longitude);
    }

    final geoMap = _asMap(geo);
    final bookingCatalog = _asMap(data['bookingCatalog']);
    final catalogGeo = bookingCatalog['geo'];
    if (catalogGeo is GeoPoint) {
      return _AttractionGeoPoint(catalogGeo.latitude, catalogGeo.longitude);
    }
    final catalogGeoMap = _asMap(catalogGeo);
    final latitude = _firstNonZeroDouble(
      geoMap['lat'],
      geoMap['latitude'],
      catalogGeoMap['lat'],
      catalogGeoMap['latitude'],
      data['geoLat'],
      data['latitude'],
    );
    final longitude = _firstNonZeroDouble(
      geoMap['lng'],
      geoMap['longitude'],
      catalogGeoMap['lng'],
      catalogGeoMap['longitude'],
      data['geoLng'],
      data['longitude'],
    );
    return _AttractionGeoPoint(latitude, longitude);
  }

  static double _firstNonZeroDouble(
    dynamic primary,
    dynamic secondary,
    dynamic tertiary,
    dynamic quaternary,
    dynamic quinary,
    dynamic senary,
  ) {
    for (final value in [
      primary,
      secondary,
      tertiary,
      quaternary,
      quinary,
      senary,
    ]) {
      final parsed = _toDouble(value);
      if (parsed != 0) return parsed;
    }
    return 0;
  }

  static double _toDouble(dynamic value) {
    final numeric = NumberUtils.toDouble(value);
    if (numeric != 0) return numeric;
    if (value is String) {
      return double.tryParse(value.trim()) ?? 0;
    }
    return 0;
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

class _AttractionGeoPoint {
  const _AttractionGeoPoint(this.latitude, this.longitude);

  final double latitude;
  final double longitude;
}
