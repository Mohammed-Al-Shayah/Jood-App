import '../entities/booking_entity.dart';
import '../repositories/booking_repository.dart';

class GetBookingByCodeUseCase {
  GetBookingByCodeUseCase(this.repository);

  final BookingRepository repository;

  Future<BookingEntity> call(String code) {
    return repository.getBookingByCode(code);
  }
}
