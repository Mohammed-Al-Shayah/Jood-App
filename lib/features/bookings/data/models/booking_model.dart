import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/utils/number_utils.dart';
import '../../domain/entities/booking_entity.dart';

class BookingModel extends BookingEntity {
  const BookingModel({
    required super.id,
    required super.userId,
    required super.restaurantId,
    required super.offerId,
    required super.date,
    required super.startTime,
    super.endTime,
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
    super.paymentSessionId,
    super.paidAt,
    super.restaurantNameSnapshot,
    super.offerTitleSnapshot,
    super.bookableType,
    super.guestPricingMode,
    super.coverImageUrlSnapshot,
    super.refundStatus,
    super.cancelledAt,
    super.cancelledBy,
    super.cancelledByRole,
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
      endTime: data['endTime'] as String? ?? '',
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
      paymentSessionId: data['paymentSessionId'] as String?,
      paidAt: _toDateTimeNullable(data['paidAt']),
      restaurantNameSnapshot: data['restaurantNameSnapshot'] as String?,
      offerTitleSnapshot: data['offerTitleSnapshot'] as String?,
      bookableType: data['bookableType'] as String?,
      guestPricingMode: data['guestPricingMode'] as String?,
      coverImageUrlSnapshot: data['coverImageUrlSnapshot'] as String?,
      refundStatus: data['refundStatus'] as String?,
      cancelledAt: _toDateTimeNullable(data['cancelledAt']),
      cancelledBy: data['cancelledBy'] as String?,
      cancelledByRole: data['cancelledByRole'] as String?,
    );
  }

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
