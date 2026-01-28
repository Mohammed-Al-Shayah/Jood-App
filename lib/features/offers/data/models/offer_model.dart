import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/offer_entity.dart';

class OfferModel extends OfferEntity {
  const OfferModel({
    required super.id,
    required super.restaurantId,
    required super.date,
    required super.startTime,
    required super.endTime,
    required super.currency,
    required super.priceAdult,
    required super.priceChild,
    required super.capacityAdult,
    required super.capacityChild,
    required super.bookedAdult,
    required super.bookedChild,
    required super.status,
    required super.title,
    required super.entryConditions,
    required super.createdAt,
    required super.updatedAt,
  });

  factory OfferModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return OfferModel(
      id: doc.id,
      restaurantId: data['restaurantId'] as String? ?? '',
      date: _readDate(data['date']),
      startTime: data['startTime'] as String? ?? '',
      endTime: data['endTime'] as String? ?? '',
      currency: data['currency'] as String? ?? 'USD',
      priceAdult: _toDouble(data['priceAdult']),
      priceChild: _toDouble(data['priceChild']),
      capacityAdult: (data['capacityAdult'] as num?)?.toInt() ?? 0,
      capacityChild: (data['capacityChild'] as num?)?.toInt() ?? 0,
      bookedAdult: (data['bookedAdult'] as num?)?.toInt() ?? 0,
      bookedChild: (data['bookedChild'] as num?)?.toInt() ?? 0,
      status: data['status'] as String? ?? 'active',
      title: data['title'] as String? ?? '',
      entryConditions: _stringList(data['entryConditions']),
      createdAt: _toDateTime(data['createdAt']),
      updatedAt: _toDateTime(data['updatedAt']),
    );
  }

  static List<String> _stringList(dynamic value) {
    final list = value as List<dynamic>? ?? [];
    return list.map((item) => item.toString()).toList();
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

  static String _readDate(dynamic value) {
    if (value is Timestamp) {
      return _formatDate(value.toDate());
    }
    if (value is DateTime) {
      return _formatDate(value);
    }
    if (value == null) return '';
    return value.toString();
  }

  static String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
