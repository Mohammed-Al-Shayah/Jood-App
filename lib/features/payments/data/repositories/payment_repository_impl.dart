import '../../domain/entities/payment_entity.dart';
import '../../domain/repositories/payment_repository.dart';
import '../datasources/payment_remote_data_source.dart';
import '../models/payment_model.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  PaymentRepositoryImpl({required this.remoteDataSource});

  final PaymentRemoteDataSource remoteDataSource;

  @override
  Future<PaymentEntity?> getPaymentByBookingId(String bookingId) {
    return remoteDataSource.getPaymentByBookingId(bookingId);
  }

  @override
  Future<void> createPayment(PaymentEntity payment) {
    final model = PaymentModel(
      id: payment.id,
      bookingId: payment.bookingId,
      amount: payment.amount,
      status: payment.status,
      method: payment.method,
      createdAt: payment.createdAt,
    );
    return remoteDataSource.createPayment(model);
  }
}
