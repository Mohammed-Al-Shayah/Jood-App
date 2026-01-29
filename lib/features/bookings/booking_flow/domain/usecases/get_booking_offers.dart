import '../entities/booking_offer.dart';
import '../repositories/booking_repository.dart';

class GetBookingOffers {
  const GetBookingOffers(this.repository);

  final BookingRepository repository;

  Future<List<BookingOffer>> call(DateTime date) {
    return repository.getOffersForDate(date);
  }
}


