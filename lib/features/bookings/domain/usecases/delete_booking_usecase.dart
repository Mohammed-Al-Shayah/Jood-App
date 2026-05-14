import '../repositories/booking_repository.dart';

class DeleteBookingUseCase {
  DeleteBookingUseCase(this.repository);

  final BookingRepository repository;

  Future<void> call(String bookingId) {
    return repository.deleteBooking(bookingId);
  }
}
