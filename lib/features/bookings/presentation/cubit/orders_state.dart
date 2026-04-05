import '../../../bookings/domain/entities/booking_entity.dart';

enum OrdersStatus { initial, loading, success, failure, unauthenticated }

class OrderVenueDetails {
  const OrderVenueDetails({required this.name, required this.coverImageUrl});

  final String name;
  final String coverImageUrl;
}

class OrdersState {
  static const _unset = Object();

  const OrdersState({
    this.status = OrdersStatus.initial,
    this.orders = const [],
    this.venueDetailsByKey = const {},
    this.errorMessage,
    this.cancellingBookingId,
  });

  final OrdersStatus status;
  final List<BookingEntity> orders;
  final Map<String, OrderVenueDetails> venueDetailsByKey;
  final String? errorMessage;
  final String? cancellingBookingId;

  OrdersState copyWith({
    OrdersStatus? status,
    List<BookingEntity>? orders,
    Map<String, OrderVenueDetails>? venueDetailsByKey,
    Object? errorMessage = _unset,
    Object? cancellingBookingId = _unset,
  }) {
    return OrdersState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      venueDetailsByKey: venueDetailsByKey ?? this.venueDetailsByKey,
      errorMessage: errorMessage == _unset
          ? this.errorMessage
          : errorMessage as String?,
      cancellingBookingId: cancellingBookingId == _unset
          ? this.cancellingBookingId
          : cancellingBookingId as String?,
    );
  }

  static OrdersState initial() => const OrdersState();
}
