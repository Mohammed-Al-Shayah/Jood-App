import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/payment_entity.dart';
import '../../../../core/utils/number_utils.dart';

class PaymentModel extends PaymentEntity {
  const PaymentModel({
    required super.id,
    required super.bookingId,
    required super.amount,
    required super.status,
    required super.method,
    required super.createdAt,
  });

  factory PaymentModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return PaymentModel(
      id: doc.id,
      bookingId: data['bookingId'] as String? ?? '',
      amount: NumberUtils.toDouble(data['amount']),
      status: data['status'] as String? ?? 'pending',
      method: data['method'] as String? ?? 'card',
      createdAt: _toDateTime(data['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bookingId': bookingId,
      'amount': amount,
      'status': status,
      'method': method,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Number parsing moved to NumberUtils

  static DateTime _toDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.now();
  }
}
