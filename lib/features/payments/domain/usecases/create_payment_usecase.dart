import '../entities/payment_entity.dart';
import '../repositories/payment_repository.dart';

class CreatePaymentUseCase {
  const CreatePaymentUseCase(this.repository);

  final PaymentRepository repository;

  Future<void> call(PaymentEntity payment) {
    return repository.createPayment(payment);
  }
}
