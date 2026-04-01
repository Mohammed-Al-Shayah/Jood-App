import '../entities/booking_entity.dart';
import '../repositories/booking_repository.dart';

class WatchAllBookingsUseCase {
  WatchAllBookingsUseCase(this.repository);

  final BookingRepository repository;

  Stream<List<BookingEntity>> call() {
    return repository.watchAllBookings();
  }
}
