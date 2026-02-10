class BookingOffer {
  const BookingOffer({
    required this.time,
    required this.price,
    required this.status,
  });

  final String time;
  final double price;
  final BookingOfferStatus status;
}

enum BookingOfferStatus { available, low, soldOut }


