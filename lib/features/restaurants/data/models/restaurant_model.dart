import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/restaurant_entity.dart';
import '../../../../core/utils/number_utils.dart';

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
    return RestaurantModel(
      id: id,
      name: data['name'] as String? ?? '',
      cityId: data['cityId'] as String? ?? '',
      area: data['area'] as String? ?? '',
      rating: NumberUtils.toDouble(data['rating']),
      reviewsCount: (data['reviewsCount'] as num?)?.toInt() ?? 0,
      coverImageUrl: _stringValue(data['coverImageUrl']),
      about: data['about'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      address: data['address'] as String? ?? '',
      geoLat: NumberUtils.toDouble(geo['lat']),
      geoLng: NumberUtils.toDouble(geo['lng']),
      openFrom: openHours['from'] as String? ?? '',
      openTo: openHours['to'] as String? ?? '',
      highlights: _stringList(data['highlights']),
      inclusions: _stringList(data['inclusions']),
      exclusions: _stringList(data['exclusions']),
      cancellationPolicy: _stringList(data['cancellationPolicy']),
      knowBeforeYouGo: _stringList(data['knowBeforeYouGo']),
      isActive: data['isActive'] as bool? ?? true,
      createdAt: _toDateTime(data['createdAt']),
      badge: _stringValue(data['badge']),
      priceFrom: _stringValue(data['priceFrom']),
      discount: _stringValue(data['discount']),
      slotsLeft: _stringValue(data['slotsLeft']),
      priceFromValue: NumberUtils.toDouble(data['priceFromValue']),
      discountValue: NumberUtils.toDouble(data['discountValue']),
    );
  }

  static List<String> _stringList(dynamic value) {
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }
    if (value is String && value.trim().isNotEmpty) {
      return [value];
    }
    return const [];
  }

  static String _stringValue(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  // Number parsing moved to NumberUtils

  static DateTime _toDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.now();
  }
}
