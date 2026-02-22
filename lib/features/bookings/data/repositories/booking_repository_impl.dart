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
  Future<BookingEntity> getBookingById(String id) {
    return remoteDataSource.getBookingById(id);
  }
}
