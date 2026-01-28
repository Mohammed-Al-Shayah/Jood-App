import '../../domain/entities/booking_offer.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/booking_local_data_source.dart';

class BookingRepositoryImpl implements BookingRepository {
  const BookingRepositoryImpl({required this.localDataSource});

  final BookingLocalDataSource localDataSource;

  @override
  Future<List<BookingOffer>> getOffersForDate(DateTime date) {
    return localDataSource.getOffers(date);
  }
}
