import 'package:jood/core/utils/number_utils.dart';
import '../../domain/entities/booking_offer.dart';

class BookingOfferModel extends BookingOffer {
  const BookingOfferModel({
    required super.time,
    required super.price,
    required super.status,
  });

  factory BookingOfferModel.fromMap(Map<String, dynamic> data) {
    return BookingOfferModel(
      time: data['time'] as String? ?? '',
      price: NumberUtils.parseNumber(data['price']),
      status: _parseStatus(data['status'] as String?),
    );
  }

  static BookingOfferStatus _parseStatus(String? value) {
    switch (value) {
      case 'low':
        return BookingOfferStatus.low;
      case 'soldOut':
        return BookingOfferStatus.soldOut;
      default:
        return BookingOfferStatus.available;
    }
  }
}


