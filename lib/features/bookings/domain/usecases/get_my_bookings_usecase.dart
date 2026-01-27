import '../entities/booking_entity.dart';
import '../repositories/booking_repository.dart';

class GetMyBookingsUseCase {
  GetMyBookingsUseCase(this.repository);

  final BookingRepository repository;

  Future<List<BookingEntity>> call(String userId) {
    return repository.getMyBookings(userId);
  }
}
