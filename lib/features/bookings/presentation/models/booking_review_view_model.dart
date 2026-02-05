import '../utils/booking_pricing_utils.dart';

class BookingReviewViewModel {
  const BookingReviewViewModel({
    required this.bookingId,
    required this.bookingCode,
    required this.restaurantId,
    required this.offerId,
    required this.restaurantName,
    required this.offerTitle,
    required this.date,
    required this.startTime,
    required this.adults,
    required this.children,
    required this.status,
    required this.pricing,
  });

  final String bookingId;
  final String bookingCode;
  final String restaurantId;
  final String offerId;
  final String restaurantName;
  final String offerTitle;
  final String date;
  final String startTime;
  final int adults;
  final int children;
  final String status;
  final BookingPricing pricing;

  factory BookingReviewViewModel.fromValues({
    required String bookingId,
    required String bookingCode,
    required String restaurantId,
    required String offerId,
    required String date,
    required String startTime,
    required int adults,
    required int children,
    required String status,
    required double subtotal,
    required double tax,
    required double total,
    required String restaurantNameSnapshot,
    required String offerTitleSnapshot,
    required String fallbackCode,
  }) {
    return BookingReviewViewModel(
      bookingId: bookingId,
      bookingCode: bookingCode.isEmpty ? fallbackCode : bookingCode,
      restaurantId: restaurantId.trim(),
      offerId: offerId.trim(),
      restaurantName: restaurantNameSnapshot.trim(),
      offerTitle: offerTitleSnapshot.trim(),
      date: date,
      startTime: startTime,
      adults: adults,
      children: children,
      status: status,
      pricing: BookingPricing(subtotal: subtotal, tax: tax, total: total),
    );
  }

  BookingReviewViewModel copyWith({
    String? restaurantName,
    String? offerTitle,
  }) {
    return BookingReviewViewModel(
      bookingId: bookingId,
      bookingCode: bookingCode,
      restaurantId: restaurantId,
      offerId: offerId,
      restaurantName: restaurantName ?? this.restaurantName,
      offerTitle: offerTitle ?? this.offerTitle,
      date: date,
      startTime: startTime,
      adults: adults,
      children: children,
      status: status,
      pricing: pricing,
    );
  }
}
