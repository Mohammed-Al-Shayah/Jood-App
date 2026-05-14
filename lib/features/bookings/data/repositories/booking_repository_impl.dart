import '../../domain/entities/booking_entity.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/booking_remote_data_source.dart';

class BookingRepositoryImpl implements BookingRepository {
  BookingRepositoryImpl(this.remoteDataSource);

  final BookingRemoteDataSource remoteDataSource;

  @override
  Future<BookingEntity> createBookingWithTransaction({
    required String offerId,
    required String userId,
    required int adults,
    required int children,
    String? paymentSessionId,
  }) {
    return remoteDataSource.createBookingWithTransaction(
      offerId: offerId,
      userId: userId,
      adults: adults,
      children: children,
      paymentSessionId: paymentSessionId,
    );
  }

  @override
  Future<List<BookingEntity>> getMyBookings(String userId) {
    return remoteDataSource.getMyBookings(userId);
  }

  @override
  Future<List<BookingEntity>> getAllBookings() {
    return remoteDataSource.getAllBookings();
  }

  @override
  Stream<List<BookingEntity>> watchMyBookings(String userId) {
    return remoteDataSource.watchMyBookings(userId);
  }

  @override
  Stream<List<BookingEntity>> watchAllBookings() {
    return remoteDataSource.watchAllBookings();
  }

  @override
  Future<BookingEntity> getBookingById(String id) {
    return remoteDataSource.getBookingById(id);
  }

  @override
  Future<BookingEntity> getBookingByCode(String code) {
    return remoteDataSource.getBookingByCode(code);
  }

  @override
  Future<void> cancelBooking({
    required String bookingId,
    required String actorUserId,
  }) {
    return remoteDataSource.cancelBooking(
      bookingId: bookingId,
      actorUserId: actorUserId,
    );
  }

  @override
  Future<void> completeBooking({
    required String bookingId,
    required String staffRestaurantId,
    required String actorUserId,
  }) {
    return remoteDataSource.completeBooking(
      bookingId: bookingId,
      staffRestaurantId: staffRestaurantId,
      actorUserId: actorUserId,
    );
  }

  @override
  Future<void> updateRefundStatus({
    required String bookingId,
    required String status,
    required String actorUserId,
  }) {
    return remoteDataSource.updateRefundStatus(
      bookingId: bookingId,
      status: status,
      actorUserId: actorUserId,
    );
  }

  @override
  Future<void> deleteBooking(String bookingId) {
    return remoteDataSource.deleteBooking(bookingId);
  }
}
