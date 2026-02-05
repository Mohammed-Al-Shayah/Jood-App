import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/booking_entity.dart';
import '../../../../core/utils/number_utils.dart';

class BookingModel extends BookingEntity {
  const BookingModel({
    required super.id,
    required super.userId,
    required super.restaurantId,
    required super.offerId,
    required super.date,
    required super.startTime,
    required super.adults,
    required super.children,
    required super.currency,
    required super.unitPriceAdult,
    required super.unitPriceChild,
    required super.subtotal,
    required super.tax,
    required super.discount,
    required super.total,
    required super.status,
    required super.bookingCode,
    required super.qrPayload,
    required super.createdAt,
    super.paidAt,
    super.restaurantNameSnapshot,
    super.offerTitleSnapshot,
  });

  factory BookingModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return BookingModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      restaurantId: data['restaurantId'] as String? ?? '',
      offerId: data['offerId'] as String? ?? '',
      date: data['date'] as String? ?? '',
      startTime: data['startTime'] as String? ?? '',
      adults: (data['adults'] as num?)?.toInt() ?? 0,
      children: (data['children'] as num?)?.toInt() ?? 0,
      currency: data['currency'] as String? ?? 'USD',
      unitPriceAdult: NumberUtils.toDouble(data['unitPriceAdult']),
      unitPriceChild: NumberUtils.toDouble(data['unitPriceChild']),
      subtotal: NumberUtils.toDouble(data['subtotal']),
      tax: NumberUtils.toDouble(data['tax']),
      discount: NumberUtils.toDouble(data['discount']),
      total: NumberUtils.toDouble(data['total']),
      status: data['status'] as String? ?? 'confirmed',
      bookingCode: data['bookingCode'] as String? ?? '',
      qrPayload: data['qrPayload'] as String? ?? '',
      createdAt: _toDateTime(data['createdAt']),
      paidAt: _toDateTimeNullable(data['paidAt']),
      restaurantNameSnapshot: data['restaurantNameSnapshot'] as String?,
      offerTitleSnapshot: data['offerTitleSnapshot'] as String?,
    );
  }

  // Number parsing moved to NumberUtils

  static DateTime _toDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.now();
  }

  static DateTime? _toDateTimeNullable(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
