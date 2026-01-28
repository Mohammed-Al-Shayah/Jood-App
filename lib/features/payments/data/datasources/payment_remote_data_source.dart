import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/payment_model.dart';

class PaymentRemoteDataSource {
  PaymentRemoteDataSource({required this.firestore});

  final FirebaseFirestore firestore;

  Future<PaymentModel?> getPaymentByBookingId(String bookingId) async {
    final query = await firestore
        .collection('payments')
        .where('bookingId', isEqualTo: bookingId)
        .limit(1)
        .get();
    if (query.docs.isEmpty) return null;
    return PaymentModel.fromDoc(query.docs.first);
  }

  Future<void> createPayment(PaymentModel payment) {
    return firestore.collection('payments').doc(payment.id).set(
          payment.toMap(),
          SetOptions(merge: true),
        );
  }
}
