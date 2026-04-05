import '../repositories/booking_repository.dart';

class CancelBookingUseCase {
  CancelBookingUseCase(this.repository);

  final BookingRepository repository;

  Future<void> call({required String bookingId, required String actorUserId}) {
    return repository.cancelBooking(
      bookingId: bookingId,
      actorUserId: actorUserId,
    );
  }
}
