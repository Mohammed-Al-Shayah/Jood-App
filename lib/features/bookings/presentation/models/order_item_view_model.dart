import 'package:cloud_firestore/cloud_firestore.dart';

class OrderItemViewModel {
  const OrderItemViewModel({
    required this.bookingCode,
    required this.qrPayload,
    required this.restaurantId,
    required this.date,
    required this.startTime,
    required this.adults,
    required this.children,
    required this.currency,
    required this.unitPriceAdult,
    required this.unitPriceChild,
    required this.subtotal,
    required this.tax,
    required this.discount,
    required this.status,
    required this.total,
    required this.createdAt,
    required this.restaurantNameSnapshot,
    required this.offerTitleSnapshot,
  });

  final String bookingCode;
  final String qrPayload;
  final String restaurantId;
  final String date;
  final String startTime;
  final int adults;
  final int children;
  final String currency;
  final double unitPriceAdult;
  final double unitPriceChild;
  final double subtotal;
  final double tax;
  final double discount;
  final String status;
  final double total;
  final Timestamp? createdAt;
  final String restaurantNameSnapshot;
  final String offerTitleSnapshot;

  factory OrderItemViewModel.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const <String, dynamic>{};
    return OrderItemViewModel(
      bookingCode: (data['bookingCode'] as String?) ?? '',
      qrPayload: (data['qrPayload'] as String?) ?? '',
      restaurantId: (data['restaurantId'] as String?) ?? '',
      date: (data['date'] as String?) ?? '',
      startTime: (data['startTime'] as String?) ?? '',
      adults: (data['adults'] as num?)?.toInt() ?? 0,
      children: (data['children'] as num?)?.toInt() ?? 0,
      currency: (data['currency'] as String?) ?? 'USD',
      unitPriceAdult: (data['unitPriceAdult'] as num?)?.toDouble() ?? 0,
      unitPriceChild: (data['unitPriceChild'] as num?)?.toDouble() ?? 0,
      subtotal: (data['subtotal'] as num?)?.toDouble() ?? 0,
      tax: (data['tax'] as num?)?.toDouble() ?? 0,
      discount: (data['discount'] as num?)?.toDouble() ?? 0,
      status: (data['status'] as String?) ?? 'paid',
      total: (data['total'] as num?)?.toDouble() ?? 0,
      createdAt: data['createdAt'] as Timestamp?,
      restaurantNameSnapshot: (data['restaurantNameSnapshot'] as String? ?? '')
          .trim(),
      offerTitleSnapshot: (data['offerTitleSnapshot'] as String? ?? '').trim(),
    );
  }
}

class RestaurantSummaryViewModel {
  const RestaurantSummaryViewModel({
    required this.name,
    required this.coverImageUrl,
  });

  final String name;
  final String coverImageUrl;

  factory RestaurantSummaryViewModel.fromDoc({
    required Map<String, dynamic>? data,
    required String fallbackId,
  }) {
    final name = (data?['name'] as String?)?.trim();
    return RestaurantSummaryViewModel(
      name: (name != null && name.isNotEmpty) ? name : fallbackId,
      coverImageUrl: (data?['coverImageUrl'] as String?) ?? '',
    );
  }
}
