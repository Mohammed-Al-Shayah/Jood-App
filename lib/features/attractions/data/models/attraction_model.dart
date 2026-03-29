import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/attraction_entity.dart';
import '../../../../core/utils/number_utils.dart';

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
    final rootHighlights = _stringList(data['highlights']);
    final rootInclusions = _stringList(data['inclusions']);

    return AttractionModel(
      id: id,
      name: _stringValue(data['name']),
      cityId: _stringValue(data['cityId']),
      area: _stringValue(data['area']),
      rating: NumberUtils.toDouble(data['rating']),
      reviewsCount: NumberUtils.toInt(data['reviewsCount']),
      coverImageUrl: _stringValue(data['coverImageUrl']),
      about: _stringValue(data['about']),
      phone: _stringValue(data['phone']),
      address: _stringValue(data['address']),
      highlights: rootHighlights,
      inclusions: rootInclusions,
      catalogDescription:
          _stringValue(bookingCatalog['description']).trim().isNotEmpty
          ? _stringValue(bookingCatalog['description']).trim()
          : _stringValue(data['about']).trim(),
      catalogHighlights: _stringList(
        bookingCatalog['highlights'],
        fallback: rootHighlights,
      ),
      catalogIncluded: _stringList(
        bookingCatalog['included'],
        fallback: rootInclusions,
      ),
      packageOverview: _stringList(bookingCatalog['packageOverview']),
      bookingNotes: _stringList(bookingCatalog['notes']),
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
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'cityId': cityId,
      'area': area,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'coverImageUrl': coverImageUrl,
      'about': about,
      'phone': phone,
      'address': address,
      'highlights': highlights,
      'inclusions': inclusions,
      'badge': badge,
      'priceFrom': priceFrom,
      'discount': discount,
      'slotsLeft': slotsLeft,
      'isActive': isActive,
      'bookingCatalog': {
        'description': catalogDescription,
        'highlights': catalogHighlights,
        'included': catalogIncluded,
        'packageOverview': packageOverview,
        'notes': bookingNotes,
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
    return value.toString();
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
}
