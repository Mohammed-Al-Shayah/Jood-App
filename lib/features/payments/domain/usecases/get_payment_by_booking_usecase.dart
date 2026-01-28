import '../entities/payment_entity.dart';
import '../repositories/payment_repository.dart';

class GetPaymentByBookingUseCase {
  const GetPaymentByBookingUseCase(this.repository);

  final PaymentRepository repository;

  Future<PaymentEntity?> call(String bookingId) {
    return repository.getPaymentByBookingId(bookingId);
  }
}
