import '../entities/booking_entity.dart';
import '../repositories/booking_repository.dart';

class GetBookingByIdUseCase {
  GetBookingByIdUseCase(this.repository);

  final BookingRepository repository;

  Future<BookingEntity> call(String id) => repository.getBookingById(id);
}
