import '../models/booking_review_view_model.dart';

enum OrderQrScannerStatus {
  initial,
  verifying,
  ready,
  completing,
  success,
  failure,
}

class OrderQrScannerState {
  static const _unset = Object();

  const OrderQrScannerState({
    this.status = OrderQrScannerStatus.initial,
    this.booking,
    this.staffRestaurantId,
    this.message,
  });

  final OrderQrScannerStatus status;
  final BookingReviewViewModel? booking;
  final String? staffRestaurantId;
  final String? message;

  OrderQrScannerState copyWith({
    OrderQrScannerStatus? status,
    Object? booking = _unset,
    Object? staffRestaurantId = _unset,
    Object? message = _unset,
  }) {
    return OrderQrScannerState(
      status: status ?? this.status,
      booking: booking == _unset
          ? this.booking
          : booking as BookingReviewViewModel?,
      staffRestaurantId: staffRestaurantId == _unset
          ? this.staffRestaurantId
          : staffRestaurantId as String?,
      message: message == _unset ? this.message : message as String?,
    );
  }

  static OrderQrScannerState initial() => const OrderQrScannerState();
}
