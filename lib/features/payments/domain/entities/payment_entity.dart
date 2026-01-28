import 'package:equatable/equatable.dart';

class PaymentEntity extends Equatable {
  const PaymentEntity({
    required this.id,
    required this.bookingId,
    required this.amount,
    required this.status,
    required this.method,
    required this.createdAt,
  });

  final String id;
  final String bookingId;
  final double amount;
  final String status;
  final String method;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, bookingId, amount, status, method, createdAt];
}
