import '../entities/booking_entity.dart';

abstract class BookingRepository {
  Future<BookingEntity> createBookingWithTransaction({
    required String offerId,
    required String userId,
    required int adults,
    required int children,
    String? paymentSessionId,
  });
  Future<List<BookingEntity>> getMyBookings(String userId);
  Future<List<BookingEntity>> getAllBookings();
  Stream<List<BookingEntity>> watchMyBookings(String userId);
  Stream<List<BookingEntity>> watchAllBookings();
  Future<BookingEntity> getBookingById(String id);
  Future<BookingEntity> getBookingByCode(String code);
  Future<void> cancelBooking({
    required String bookingId,
    required String actorUserId,
  });
  Future<void> completeBooking({
    required String bookingId,
    required String staffRestaurantId,
    required String actorUserId,
  });
  Future<void> updateRefundStatus({
    required String bookingId,
    required String status,
    required String actorUserId,
  });
}
