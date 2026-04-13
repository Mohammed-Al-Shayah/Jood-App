import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/utils/localized_value_utils.dart';
import '../../../../core/utils/number_utils.dart';
import '../../domain/entities/restaurant_entity.dart';

class RestaurantModel extends RestaurantEntity {
  const RestaurantModel({
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
    required super.geoLat,
    required super.geoLng,
    required super.openFrom,
    required super.openTo,
    required super.highlights,
    required super.inclusions,
    required super.exclusions,
    required super.cancellationPolicy,
    required super.knowBeforeYouGo,
    required super.isActive,
    required super.createdAt,
    super.badge,
    super.priceFrom,
    super.discount,
    super.slotsLeft,
    super.priceFromValue,
    super.discountValue,
    super.supportsBuffet,
    super.supportsSetMenu,
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
    super.exclusionsEn,
    super.exclusionsAr,
    super.cancellationPolicyEn,
    super.cancellationPolicyAr,
    super.knowBeforeYouGoEn,
    super.knowBeforeYouGoAr,
  });

  factory RestaurantModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return RestaurantModel.fromMap(id: doc.id, data: data);
  }

  factory RestaurantModel.fromMap({
    required String id,
    required Map<String, dynamic> data,
  }) {
    final geo = (data['geo'] as Map?) ?? {};
    final openHours = (data['openHours'] as Map?) ?? {};
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
    final exclusionsEn = _stringList(data['exclusions']);
    final exclusionsAr = _stringList(data['exclusionsAr']);
    final cancellationPolicyEn = _stringList(data['cancellationPolicy']);
    final cancellationPolicyAr = _stringList(data['cancellationPolicyAr']);
    final knowBeforeYouGoEn = _stringList(data['knowBeforeYouGo']);
    final knowBeforeYouGoAr = _stringList(data['knowBeforeYouGoAr']);

    return RestaurantModel(
      id: id,
      name: resolveLocalizedText(english: nameEn, arabic: nameAr),
      cityId: resolveLocalizedText(english: cityIdEn, arabic: cityIdAr),
      area: resolveLocalizedText(english: areaEn, arabic: areaAr),
      rating: NumberUtils.toDouble(data['rating']),
      reviewsCount: (data['reviewsCount'] as num?)?.toInt() ?? 0,
      coverImageUrl: _stringValue(data['coverImageUrl']),
      about: resolveLocalizedText(english: aboutEn, arabic: aboutAr),
      phone: _stringValue(data['phone']),
      address: resolveLocalizedText(english: addressEn, arabic: addressAr),
      geoLat: NumberUtils.toDouble(geo['lat']),
      geoLng: NumberUtils.toDouble(geo['lng']),
      openFrom: openHours['from'] as String? ?? '',
      openTo: openHours['to'] as String? ?? '',
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
      cancellationPolicy: resolveLocalizedList(
        english: cancellationPolicyEn,
        arabic: cancellationPolicyAr,
      ),
      knowBeforeYouGo: resolveLocalizedList(
        english: knowBeforeYouGoEn,
        arabic: knowBeforeYouGoAr,
      ),
      isActive: data['isActive'] as bool? ?? true,
      createdAt: _toDateTime(data['createdAt']),
      badge: _stringValue(data['badge']),
      priceFrom: _stringValue(data['priceFrom']),
      discount: _stringValue(data['discount']),
      slotsLeft: _stringValue(data['slotsLeft']),
      priceFromValue: NumberUtils.toDouble(data['priceFromValue']),
      discountValue: NumberUtils.toDouble(data['discountValue']),
      supportsBuffet: _supportsCategory(bookingCatalog, 'buffet'),
      supportsSetMenu: _supportsCategory(bookingCatalog, 'set_menu'),
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
      exclusionsEn: exclusionsEn,
      exclusionsAr: exclusionsAr,
      cancellationPolicyEn: cancellationPolicyEn,
      cancellationPolicyAr: cancellationPolicyAr,
      knowBeforeYouGoEn: knowBeforeYouGoEn,
      knowBeforeYouGoAr: knowBeforeYouGoAr,
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
      'geo': {'lat': geoLat, 'lng': geoLng},
      'openHours': {'from': openFrom, 'to': openTo},
      'highlights': _baseList(highlightsEn, highlights),
      'highlightsAr': _cleanList(highlightsAr),
      'inclusions': _baseList(inclusionsEn, inclusions),
      'inclusionsAr': _cleanList(inclusionsAr),
      'exclusions': _baseList(exclusionsEn, exclusions),
      'exclusionsAr': _cleanList(exclusionsAr),
      'cancellationPolicy': _baseList(cancellationPolicyEn, cancellationPolicy),
      'cancellationPolicyAr': _cleanList(cancellationPolicyAr),
      'knowBeforeYouGo': _baseList(knowBeforeYouGoEn, knowBeforeYouGo),
      'knowBeforeYouGoAr': _cleanList(knowBeforeYouGoAr),
      'isActive': isActive,
      'badge': badge,
      'priceFrom': priceFrom,
      'discount': discount,
      'slotsLeft': slotsLeft,
      'priceFromValue': priceFromValue,
      'discountValue': discountValue,
    };
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

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, item) => MapEntry(key.toString(), item));
    }
    return const <String, dynamic>{};
  }

  static bool _supportsCategory(
    Map<String, dynamic> bookingCatalog,
    String category,
  ) {
    if (category == 'set_menu') {
      return true;
    }

    final supported = _normalizedStringList(
      bookingCatalog['supportedCategories'],
    );

    if (category == 'buffet') {
      if (supported.isEmpty) return true;
      return supported.contains('buffet');
    }

    return true;
  }

  static List<String> _normalizedStringList(dynamic value) {
    if (value is! List) return const [];
    return value
        .map(
          (item) => item.toString().trim().toLowerCase().replaceAll(' ', '_'),
        )
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
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
}
