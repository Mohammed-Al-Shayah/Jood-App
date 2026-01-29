import '../entities/booking_offer.dart';

abstract class BookingRepository {
  Future<List<BookingOffer>> getOffersForDate(DateTime date);
}


