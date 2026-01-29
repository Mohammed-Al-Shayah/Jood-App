import '../models/booking_offer_model.dart';
import '../../domain/entities/booking_offer.dart';

class BookingLocalDataSource {
  const BookingLocalDataSource();

  Future<List<BookingOfferModel>> getOffers(DateTime date) async {
    return const [
      BookingOfferModel(
        time: '07:00 AM',
        price: r'$499',
        status: BookingOfferStatus.available,
      ),
      BookingOfferModel(
        time: '09:00 AM',
        price: r'$599',
        status: BookingOfferStatus.low,
      ),
      BookingOfferModel(
        time: '12:00 PM',
        price: r'$699',
        status: BookingOfferStatus.soldOut,
      ),
      BookingOfferModel(
        time: '02:30 PM',
        price: r'$599',
        status: BookingOfferStatus.available,
      ),
    ];
  }
}


