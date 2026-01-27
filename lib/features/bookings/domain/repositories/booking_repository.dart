import '../entities/booking_entity.dart';

abstract class BookingRepository {
  Future<BookingEntity> createBookingWithTransaction({
    required String offerId,
    required String userId,
    required int adults,
    required int children,
  });
  Future<List<BookingEntity>> getMyBookings(String userId);
  Future<BookingEntity> getBookingById(String id);
}
