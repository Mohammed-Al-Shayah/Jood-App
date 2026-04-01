import '../repositories/booking_repository.dart';

class CompleteBookingUseCase {
  CompleteBookingUseCase(this.repository);

  final BookingRepository repository;

  Future<void> call({
    required String bookingId,
    required String staffRestaurantId,
    required String actorUserId,
  }) {
    return repository.completeBooking(
      bookingId: bookingId,
      staffRestaurantId: staffRestaurantId,
      actorUserId: actorUserId,
    );
  }
}
