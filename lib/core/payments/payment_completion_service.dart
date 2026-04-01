import 'package:jood/features/bookings/domain/entities/booking_entity.dart';
import 'package:jood/features/bookings/domain/usecases/create_booking_usecase.dart';
import 'package:jood/features/payments/domain/entities/payment_entity.dart';
import 'package:jood/features/payments/domain/usecases/create_payment_usecase.dart';

class PaymentCompletionResult {
  const PaymentCompletionResult({required this.booking, required this.payment});

  final BookingEntity booking;
  final PaymentEntity payment;
}

class PaymentCompletionService {
  const PaymentCompletionService({
    required CreateBookingUseCase createBooking,
    required CreatePaymentUseCase createPayment,
  }) : _createBooking = createBooking,
       _createPayment = createPayment;

  final CreateBookingUseCase _createBooking;
  final CreatePaymentUseCase _createPayment;

  Future<PaymentCompletionResult> completeSuccessfulPayment({
    required String offerId,
    required String userId,
    required int adults,
    required int children,
    required double totalAmount,
    String? paymentSessionId,
  }) async {
    final booking = await _createBooking(
      offerId: offerId,
      userId: userId,
      adults: adults,
      children: children,
      paymentSessionId: paymentSessionId,
    );

    final payment = PaymentEntity(
      id: paymentSessionId != null && paymentSessionId.isNotEmpty
          ? 'pay_${paymentSessionId.replaceAll('/', '_')}'
          : 'pay_${booking.id}',
      bookingId: booking.id,
      amount: totalAmount,
      status: 'success',
      method: 'thawani',
      createdAt: DateTime.now(),
      paymentSessionId: paymentSessionId,
    );

    await _createPayment(payment);
    return PaymentCompletionResult(booking: booking, payment: payment);
  }
}
