import 'package:cloud_firestore/cloud_firestore.dart';

class StaffAccessModel {
  const StaffAccessModel({required this.role, required this.restaurantId});

  final String role;
  final String restaurantId;

  bool get canRedeemOrder =>
      role == 'staff' || role == 'restaurant_staff' || role == 'admin';

  factory StaffAccessModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    return StaffAccessModel(
      role: (data['role'] as String? ?? '').toLowerCase(),
      restaurantId: (data['restaurantId'] as String? ?? '').trim(),
    );
  }
}

class ScannedBookingModel {
  const ScannedBookingModel({
    required this.id,
    required this.bookingCode,
    required this.restaurantId,
    required this.status,
    required this.offerId,
    required this.date,
    required this.startTime,
    required this.adults,
    required this.children,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.restaurantNameSnapshot,
    required this.offerTitleSnapshot,
  });

  final String id;
  final String bookingCode;
  final String restaurantId;
  final String status;
  final String offerId;
  final String date;
  final String startTime;
  final int adults;
  final int children;
  final double subtotal;
  final double tax;
  final double total;
  final String restaurantNameSnapshot;
  final String offerTitleSnapshot;

  factory ScannedBookingModel.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};
    return ScannedBookingModel(
      id: doc.id,
      bookingCode: (data['bookingCode'] as String? ?? '').trim(),
      restaurantId: (data['restaurantId'] as String? ?? '').trim(),
      status: (data['status'] as String? ?? '').toLowerCase(),
      offerId: (data['offerId'] as String? ?? '').trim(),
      date: data['date'] as String? ?? '-',
      startTime: data['startTime'] as String? ?? '-',
      adults: (data['adults'] as num?)?.toInt() ?? 0,
      children: (data['children'] as num?)?.toInt() ?? 0,
      subtotal: (data['subtotal'] as num?)?.toDouble() ?? 0,
      tax: (data['tax'] as num?)?.toDouble() ?? 0,
      total: (data['total'] as num?)?.toDouble() ?? 0,
      restaurantNameSnapshot: (data['restaurantNameSnapshot'] as String? ?? '')
          .trim(),
      offerTitleSnapshot: (data['offerTitleSnapshot'] as String? ?? '').trim(),
    );
  }
}
