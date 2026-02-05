import 'package:equatable/equatable.dart';

class BookingEntity extends Equatable {
  const BookingEntity({
    required this.id,
    required this.userId,
    required this.restaurantId,
    required this.offerId,
    required this.date,
    required this.startTime,
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
    this.paidAt,
    this.restaurantNameSnapshot,
    this.offerTitleSnapshot,
  });

  final String id;
  final String userId;
  final String restaurantId;
  final String offerId;
  final String date;
  final String startTime;
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
  final DateTime? paidAt;
  final String? restaurantNameSnapshot;
  final String? offerTitleSnapshot;

  @override
  List<Object?> get props => [
    id,
    userId,
    restaurantId,
    offerId,
    date,
    startTime,
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
    paidAt,
    restaurantNameSnapshot,
    offerTitleSnapshot,
  ];
}
