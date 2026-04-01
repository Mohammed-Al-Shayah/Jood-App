import '../repositories/booking_repository.dart';

class UpdateBookingRefundStatusUseCase {
  UpdateBookingRefundStatusUseCase(this.repository);

  final BookingRepository repository;

  Future<void> call({
    required String bookingId,
    required String status,
    required String actorUserId,
  }) {
    return repository.updateRefundStatus(
      bookingId: bookingId,
      status: status,
      actorUserId: actorUserId,
    );
  }
}
