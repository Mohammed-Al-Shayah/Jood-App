import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/search_text_utils.dart';
import '../../../booking_catalog/domain/entities/catalog_category_type.dart';
import '../../../booking_catalog/domain/entities/catalog_item_entity.dart';

typedef DistanceCalculator =
    double Function(
      double startLatitude,
      double startLongitude,
      double endLatitude,
      double endLongitude,
    );

class HomeDiscoveryService {
  const HomeDiscoveryService({required DistanceCalculator distanceBetween})
    : _distanceBetween = distanceBetween;

  final DistanceCalculator _distanceBetween;

  String locationLabel(String? city, String? country) {
    final safeCity = (city ?? '').trim();
    final safeCountry = (country ?? '').trim();
    if (safeCity.isEmpty && safeCountry.isEmpty) {
      return AppStrings.cityName;
    }
    if (safeCity.isEmpty) return safeCountry;
    if (safeCountry.isEmpty) return safeCity;
    return '$safeCity, $safeCountry';
  }

  String stripFromPrice(String value) {
    final trimmed = value.trim();
    final localizedPrefix = AppStrings.from.trim();
    if (trimmed.startsWith(localizedPrefix)) {
      return trimmed.substring(localizedPrefix.length).trim();
    }

    const englishPrefix = 'From';
    if (trimmed.toLowerCase().startsWith(englishPrefix.toLowerCase())) {
      return trimmed.substring(englishPrefix.length).trim();
    }

    return trimmed;
  }

  String normalizeDisplayedPrice(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return trimmed;

    final match = _findNumberSpan(trimmed);
    if (match == null) return trimmed;

    final parsed = double.tryParse(match.value.replaceAll(',', ''));
    if (parsed == null) return trimmed;

    return trimmed.replaceRange(
      match.start,
      match.end,
      parsed.toStringAsFixed(1),
    );
  }

  List<CatalogItemEntity> hotDeals(List<CatalogItemEntity> items) {
    final ranked = List<CatalogItemEntity>.from(items)
      ..sort(
        (left, right) => discountScore(right).compareTo(discountScore(left)),
      );

    final withDeals = ranked.where((item) => discountScore(item) > 0).toList();
    final source = withDeals.isNotEmpty ? withDeals : ranked;
    return source.take(6).toList(growable: false);
  }

  List<CatalogItemEntity> nearbyItems(
    List<CatalogItemEntity> items, {
    String? userCity,
    String? userCountry,
    double? userLatitude,
    double? userLongitude,
  }) {
    if (userLatitude != null && userLongitude != null) {
      final ranked = _rankByDistance(
        items,
        latitude: userLatitude,
        longitude: userLongitude,
      );
      if (ranked.isNotEmpty) return ranked.take(6).toList(growable: false);
    }

    final normalizedCity = normalizeSearchText(userCity ?? '');
    final normalizedCountry = normalizeSearchText(userCountry ?? '');
    final matched = _nearbyTextMatchedItems(
      items,
      normalizedCity: normalizedCity,
      normalizedCountry: normalizedCountry,
    );

    final inferredOrigin = _inferOriginFromMatches(matched);
    if (inferredOrigin != null) {
      final ranked = _rankByDistance(
        items,
        latitude: inferredOrigin.latitude,
        longitude: inferredOrigin.longitude,
      );
      if (ranked.isNotEmpty) return ranked.take(6).toList(growable: false);
    }

    final source =
        matched.isNotEmpty ? matched : List<CatalogItemEntity>.from(items)
          ..sort((left, right) => right.rating.compareTo(left.rating));
    return source.take(6).toList(growable: false);
  }

  double discountScore(CatalogItemEntity item) {
    if (showNoOffersTodayMessage(item)) return 0;

    final badgePercent = _extractPercent(item.badge);
    if (badgePercent > 0) return badgePercent;

    final original = _extractAmount(item.priceFrom);
    final current = _extractAmount(item.discount);
    if (original > 0 && current > 0 && original >= current) {
      return ((original - current) / original) * 100;
    }
    return 0;
  }

  bool showNoOffersTodayMessage(CatalogItemEntity item) {
    return item.slotsLeft.trim() == AppStrings.noOffersTodayExploreOtherDates;
  }

  String discoveryMetaLabel(CatalogItemEntity item) {
    final parts = <String>[localizedCategoryTitle(item.category)];
    if (item.area.isNotEmpty) parts.add(item.area);
    if (item.cityId.isNotEmpty) parts.add(item.cityId);
    if (parts.isNotEmpty) {
      return parts.join(' | ');
    }
    return item.address;
  }

  String localizedCategoryTitle(CatalogCategoryType category) {
    switch (category) {
      case CatalogCategoryType.buffet:
        return AppStrings.buffet;
      case CatalogCategoryType.setMenu:
        return AppStrings.setMenu;
      case CatalogCategoryType.combo:
        return AppStrings.comboCategory;
      case CatalogCategoryType.attraction:
        return AppStrings.attractions;
    }
  }

  List<CatalogItemEntity> skeletonItems() {
    return [
      CatalogItemEntity(
        id: 'skeleton-1',
        category: CatalogCategoryType.buffet,
        bookingMode: CatalogCategoryType.buffet.bookingMode,
        sourceCollection: 'restaurants',
        name: 'Restaurant name',
        cityId: 'City',
        area: 'Area',
        address: '',
        rating: 4.6,
        reviewsCount: 0,
        coverImageUrl:
            'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=400&q=80',
        description: '',
        highlights: const [],
        inclusions: const [],
        availableMeals: [
          AppStrings.breakfast,
          AppStrings.lunch,
          AppStrings.dinner,
        ],
        packageOverview: const [],
        bookingNotes: const [],
        requiresMenuItemSelection: false,
        badge: AppStrings.percentOff(20),
        priceFrom: r'$120',
        discount: r'$150',
        slotsLeft: '6 slots',
        isActive: true,
      ),
      CatalogItemEntity(
        id: 'skeleton-2',
        category: CatalogCategoryType.setMenu,
        bookingMode: CatalogCategoryType.setMenu.bookingMode,
        sourceCollection: 'restaurants',
        name: 'Restaurant name',
        cityId: 'City',
        area: 'Area',
        address: '',
        rating: 4.5,
        reviewsCount: 0,
        coverImageUrl:
            'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=400&q=80',
        description: '',
        highlights: const [],
        inclusions: const [],
        availableMeals: [AppStrings.breakfastSetMenu, AppStrings.lunchSetMenu],
        packageOverview: const [],
        bookingNotes: const [],
        requiresMenuItemSelection: true,
        badge: AppStrings.percentOff(15),
        priceFrom: r'$110',
        discount: r'$130',
        slotsLeft: '4 slots',
        isActive: true,
      ),
      CatalogItemEntity(
        id: 'skeleton-3',
        category: CatalogCategoryType.combo,
        bookingMode: CatalogCategoryType.combo.bookingMode,
        sourceCollection: 'restaurants',
        name: 'Combo venue',
        cityId: 'City',
        area: 'Area',
        address: '',
        rating: 4.4,
        reviewsCount: 0,
        coverImageUrl:
            'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=400&q=80',
        description: '',
        highlights: const [],
        inclusions: const [],
        availableMeals: const ['10 pcs Broasted', 'Family Combo'],
        packageOverview: const [],
        bookingNotes: const [],
        requiresMenuItemSelection: false,
        badge: AppStrings.percentOff(10),
        priceFrom: r'$10',
        discount: r'$14',
        slotsLeft: '12 slots',
        isActive: true,
      ),
      CatalogItemEntity(
        id: 'skeleton-4',
        category: CatalogCategoryType.attraction,
        bookingMode: CatalogCategoryType.attraction.bookingMode,
        sourceCollection: 'attractions',
        name: 'Attraction name',
        cityId: 'City',
        area: 'Area',
        address: '',
        rating: 4.4,
        reviewsCount: 0,
        coverImageUrl:
            'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=400&q=80',
        description: '',
        highlights: const [],
        inclusions: const [],
        availableMeals: const [],
        packageOverview: [AppStrings.packageA, AppStrings.packageB],
        bookingNotes: const [],
        requiresMenuItemSelection: false,
        badge: AppStrings.percentOff(10),
        priceFrom: r'$90',
        discount: r'$120',
        slotsLeft: '2 slots',
        isActive: true,
      ),
    ];
  }

  List<CatalogItemEntity> _rankByDistance(
    List<CatalogItemEntity> items, {
    required double latitude,
    required double longitude,
  }) {
    final ranked = items.where(_hasUsableCoordinates).toList(growable: false)
      ..sort(
        (left, right) =>
            _distanceBetween(
              latitude,
              longitude,
              left.geoLat,
              left.geoLng,
            ).compareTo(
              _distanceBetween(latitude, longitude, right.geoLat, right.geoLng),
            ),
      );
    return ranked;
  }

  List<CatalogItemEntity> _nearbyTextMatchedItems(
    List<CatalogItemEntity> items, {
    required String normalizedCity,
    required String normalizedCountry,
  }) {
    return items.where((item) {
      final fields = [
        item.cityId,
        item.cityIdEn,
        item.cityIdAr,
        item.area,
        item.areaEn,
        item.areaAr,
        item.address,
        item.addressEn,
        item.addressAr,
        item.location,
        item.locationEn,
        item.locationAr,
      ];
      final cityMatch =
          normalizedCity.isNotEmpty &&
          fields.any((field) => normalizeSearchText(field) == normalizedCity);
      final areaMatch =
          normalizedCity.isNotEmpty &&
          fields.any(
            (field) => normalizeSearchText(field).contains(normalizedCity),
          );
      final countryMatch =
          normalizedCountry.isNotEmpty &&
          fields.any(
            (field) => normalizeSearchText(field).contains(normalizedCountry),
          );
      return cityMatch || countryMatch || areaMatch;
    }).toList()..sort((left, right) {
      final leftScore = _nearbyTextScore(
        left,
        normalizedCity: normalizedCity,
        normalizedCountry: normalizedCountry,
      );
      final rightScore = _nearbyTextScore(
        right,
        normalizedCity: normalizedCity,
        normalizedCountry: normalizedCountry,
      );
      final scoreCompare = rightScore.compareTo(leftScore);
      if (scoreCompare != 0) return scoreCompare;
      return right.rating.compareTo(left.rating);
    });
  }

  HomeGeoPoint? _inferOriginFromMatches(List<CatalogItemEntity> matched) {
    final withCoordinates = matched
        .where(_hasUsableCoordinates)
        .toList(growable: false);
    if (withCoordinates.isEmpty) return null;

    var latitudeSum = 0.0;
    var longitudeSum = 0.0;
    for (final item in withCoordinates) {
      latitudeSum += item.geoLat;
      longitudeSum += item.geoLng;
    }
    return HomeGeoPoint(
      latitudeSum / withCoordinates.length,
      longitudeSum / withCoordinates.length,
    );
  }

  int _nearbyTextScore(
    CatalogItemEntity item, {
    required String normalizedCity,
    required String normalizedCountry,
  }) {
    final cityFields = [item.cityId, item.cityIdEn, item.cityIdAr]
        .map(normalizeSearchText)
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
    final areaFields = [item.area, item.areaEn, item.areaAr]
        .map(normalizeSearchText)
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
    final addressFields =
        [
              item.address,
              item.addressEn,
              item.addressAr,
              item.location,
              item.locationEn,
              item.locationAr,
            ]
            .map(normalizeSearchText)
            .where((value) => value.isNotEmpty)
            .toList(growable: false);

    var score = 0;
    if (normalizedCity.isNotEmpty) {
      if (cityFields.any((field) => field == normalizedCity)) {
        score += 100;
      }
      if (areaFields.any((field) => field.contains(normalizedCity))) {
        score += 50;
      }
      if (addressFields.any((field) => field.contains(normalizedCity))) {
        score += 25;
      }
    }
    if (normalizedCountry.isNotEmpty &&
        addressFields.any((field) => field.contains(normalizedCountry))) {
      score += 10;
    }
    return score;
  }

  bool _hasUsableCoordinates(CatalogItemEntity item) {
    final lat = item.geoLat;
    final lng = item.geoLng;
    if (lat == 0 && lng == 0) return false;
    return lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180;
  }

  double _extractPercent(String value) {
    final percentIndex = value.indexOf('%');
    if (percentIndex < 0) return 0;
    final match = _findNumberSpan(value.substring(0, percentIndex));
    return double.tryParse(match?.value ?? '') ?? 0;
  }

  double _extractAmount(String value) {
    final match = _findNumberSpan(value, allowComma: true);
    return double.tryParse(match?.value.replaceAll(',', '') ?? '') ?? 0;
  }

  _NumberSpan? _findNumberSpan(String value, {bool allowComma = false}) {
    int? start;
    for (var index = 0; index < value.length; index += 1) {
      final code = value.codeUnitAt(index);
      final isDigit = code >= 48 && code <= 57;
      final isSeparator = code == 46 || (allowComma && code == 44);
      if (isDigit || (start != null && isSeparator)) {
        start ??= index;
        continue;
      }
      if (start != null) {
        return _NumberSpan(start, index, value.substring(start, index));
      }
    }
    if (start == null) return null;
    return _NumberSpan(start, value.length, value.substring(start));
  }
}

class HomeGeoPoint {
  const HomeGeoPoint(this.latitude, this.longitude);

  final double latitude;
  final double longitude;
}

class _NumberSpan {
  const _NumberSpan(this.start, this.end, this.value);

  final int start;
  final int end;
  final String value;
}
