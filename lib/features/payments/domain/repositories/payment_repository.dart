import '../entities/payment_entity.dart';

abstract class PaymentRepository {
  Future<PaymentEntity?> getPaymentByBookingId(String bookingId);
  Future<void> createPayment(PaymentEntity payment);
}
