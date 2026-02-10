import '../models/booking_offer_model.dart';
import '../../domain/entities/booking_offer.dart';

class BookingLocalDataSource {
  const BookingLocalDataSource();

  Future<List<BookingOfferModel>> getOffers(DateTime date) async {
    return const [
      BookingOfferModel(
        time: '07:00 AM',
        price: 499.0,
        status: BookingOfferStatus.available,
      ),
      BookingOfferModel(
        time: '09:00 AM',
        price: 599.0,
        status: BookingOfferStatus.low,
      ),
      BookingOfferModel(
        time: '12:00 PM',
        price: 699.0,
        status: BookingOfferStatus.soldOut,
      ),
      BookingOfferModel(
        time: '02:30 PM',
        price: 599.0,
        status: BookingOfferStatus.available,
      ),
    ];
  }
}


