import '../entities/booking_entity.dart';
import '../repositories/booking_repository.dart';

class WatchMyBookingsUseCase {
  WatchMyBookingsUseCase(this.repository);

  final BookingRepository repository;

  Stream<List<BookingEntity>> call(String userId) {
    return repository.watchMyBookings(userId);
  }
}
