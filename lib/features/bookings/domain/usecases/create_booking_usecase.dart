import '../entities/booking_entity.dart';
import '../repositories/booking_repository.dart';

class CreateBookingUseCase {
  CreateBookingUseCase(this.repository);

  final BookingRepository repository;

  Future<BookingEntity> call({
    required String offerId,
    required String userId,
    required int adults,
    required int children,
    String? paymentSessionId,
  }) {
    return repository.createBookingWithTransaction(
      offerId: offerId,
      userId: userId,
      adults: adults,
      children: children,
      paymentSessionId: paymentSessionId,
    );
  }
}
