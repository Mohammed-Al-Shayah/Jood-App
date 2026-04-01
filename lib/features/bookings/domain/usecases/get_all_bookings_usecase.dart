import '../entities/booking_entity.dart';
import '../repositories/booking_repository.dart';

class GetAllBookingsUseCase {
  GetAllBookingsUseCase(this.repository);

  final BookingRepository repository;

  Future<List<BookingEntity>> call() {
    return repository.getAllBookings();
  }
}
