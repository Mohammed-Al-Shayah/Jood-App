import 'package:equatable/equatable.dart';

import '../../../../core/utils/guest_pricing_utils.dart' as guest_pricing;

class BookingEntity extends Equatable {
  const BookingEntity({
    required this.id,
    required this.userId,
    required this.restaurantId,
    required this.offerId,
    required this.date,
    required this.startTime,
    this.endTime = '',
    required this.adults,
    required this.children,
    required this.currency,
    required this.unitPriceAdult,
    required this.unitPriceChild,
    required this.subtotal,
    required this.tax,
    required this.discount,
    required this.total,
    required this.status,
    required this.bookingCode,
    required this.qrPayload,
    required this.createdAt,
    this.paymentSessionId,
    this.paidAt,
    this.restaurantNameSnapshot,
    this.offerTitleSnapshot,
    this.bookingCategory,
    this.bookableType,
    this.guestPricingMode,
    this.coverImageUrlSnapshot,
    this.refundStatus,
    this.cancelledAt,
    this.cancelledBy,
    this.cancelledByRole,
  });

  final String id;
  final String userId;
  final String restaurantId;
  final String offerId;
  final String date;
  final String startTime;
  final String endTime;
  final int adults;
  final int children;
  final String currency;
  final double unitPriceAdult;
  final double unitPriceChild;
  final double subtotal;
  final double tax;
  final double discount;
  final double total;
  final String status;
  final String bookingCode;
  final String qrPayload;
  final DateTime createdAt;
  final String? paymentSessionId;
  final DateTime? paidAt;
  final String? restaurantNameSnapshot;
  final String? offerTitleSnapshot;
  final String? bookingCategory;
  final String? bookableType;
  final String? guestPricingMode;
  final String? coverImageUrlSnapshot;
  final String? refundStatus;
  final DateTime? cancelledAt;
  final String? cancelledBy;
  final String? cancelledByRole;
  String get resolvedGuestPricingMode =>
      guest_pricing.normalizeGuestPricingMode(
        guestPricingMode,
        bookingCategory: bookingCategory ?? '',
        bookableType: bookableType ?? '',
      );
  bool get usesUnifiedGuestCount => guest_pricing.usesUnifiedGuestCount(
    guestPricingMode: guestPricingMode,
    bookingCategory: bookingCategory ?? '',
    bookableType: bookableType ?? '',
  );

  @override
  List<Object?> get props => [
    id,
    userId,
    restaurantId,
    offerId,
    date,
    startTime,
    endTime,
    adults,
    children,
    currency,
    unitPriceAdult,
    unitPriceChild,
    subtotal,
    tax,
    discount,
    total,
    status,
    bookingCode,
    qrPayload,
    createdAt,
    paymentSessionId,
    paidAt,
    restaurantNameSnapshot,
    offerTitleSnapshot,
    bookingCategory,
    bookableType,
    guestPricingMode,
    coverImageUrlSnapshot,
    refundStatus,
    cancelledAt,
    cancelledBy,
    cancelledByRole,
  ];
}
