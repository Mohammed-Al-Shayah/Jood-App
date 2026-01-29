import 'package:cloud_firestore/cloud_firestore.dart';

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
  });

  factory RestaurantModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final geo = (data['geo'] as Map?) ?? {};
    final openHours = (data['openHours'] as Map?) ?? {};
    return RestaurantModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      cityId: data['cityId'] as String? ?? '',
      area: data['area'] as String? ?? '',
      rating: _toDouble(data['rating']),
      reviewsCount: (data['reviewsCount'] as num?)?.toInt() ?? 0,
      coverImageUrl: data['coverImageUrl'] as String? ?? '',
      about: data['about'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      address: data['address'] as String? ?? '',
      geoLat: _toDouble(geo['lat']),
      geoLng: _toDouble(geo['lng']),
      openFrom: openHours['from'] as String? ?? '',
      openTo: openHours['to'] as String? ?? '',
      highlights: _stringList(data['highlights']),
      inclusions: _stringList(data['inclusions']),
      exclusions: _stringList(data['exclusions']),
      cancellationPolicy: _stringList(data['cancellationPolicy']),
      knowBeforeYouGo: _stringList(data['knowBeforeYouGo']),
      isActive: data['isActive'] as bool? ?? true,
      createdAt: _toDateTime(data['createdAt']),
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

  static double _toDouble(dynamic value) {
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return 0;
  }

  static DateTime _toDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.now();
  }
}
