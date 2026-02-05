import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/booking_model.dart';
import '../../../../core/utils/number_utils.dart';

class BookingRemoteDataSource {
  BookingRemoteDataSource(this.firestore);

  final FirebaseFirestore firestore;

  Future<BookingModel> createBookingWithTransaction({
    required String offerId,
    required String userId,
    required int adults,
    required int children,
  }) async {
    final offerRef = firestore.collection('offers').doc(offerId);
    final bookingRef = firestore.collection('bookings').doc();

    return firestore.runTransaction((transaction) async {
      final offerSnap = await transaction.get(offerRef);
      final data = offerSnap.data() ?? {};
      final restaurantId = (data['restaurantId'] as String? ?? '').trim();
      final offerTitle = (data['title'] as String? ?? '').trim();

      final capacityAdult = (data['capacityAdult'] as num?)?.toInt() ?? 0;
      final capacityChild = (data['capacityChild'] as num?)?.toInt() ?? 0;
      final bookedAdult = (data['bookedAdult'] as num?)?.toInt() ?? 0;
      final bookedChild = (data['bookedChild'] as num?)?.toInt() ?? 0;
      final status = (data['status'] as String? ?? 'active')
          .toLowerCase()
          .replaceAll(' ', '');

      final remainingTotal =
          (capacityAdult + capacityChild) - (bookedAdult + bookedChild);

      if (status == 'soldout' || status == 'sold_out') {
        throw BookingException('Offer is not active.');
      }
      if (remainingTotal < (adults + children)) {
        throw BookingException('Sold out / Not enough tickets.');
      }

      final priceAdult = NumberUtils.toDouble(data['priceAdult']);
      final priceChild = NumberUtils.toDouble(data['priceChild']);
      final subtotal = priceAdult * adults + priceChild * children;
      final discount = 0.0;
      final total = subtotal - discount;
      final bookingCode = _generateCode();
      String restaurantNameSnapshot = '';
      if (restaurantId.isNotEmpty) {
        final restaurantRef = firestore
            .collection('restaurants')
            .doc(restaurantId);
        final restaurantSnap = await transaction.get(restaurantRef);
        final restaurantData =
            restaurantSnap.data() ?? const <String, dynamic>{};
        restaurantNameSnapshot = (restaurantData['name'] as String? ?? '')
            .trim();
      }

      transaction.update(offerRef, {
        'bookedAdult': bookedAdult + adults,
        'bookedChild': bookedChild + children,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      transaction.set(bookingRef, {
        'userId': userId,
        'restaurantId': restaurantId,
        'offerId': offerId,
        'date': data['date'],
        'startTime': data['startTime'],
        'adults': adults,
        'children': children,
        'currency': data['currency'] ?? 'USD',
        'unitPriceAdult': priceAdult,
        'unitPriceChild': priceChild,
        'subtotal': subtotal,
        'discount': discount,
        'total': total,
        'status': 'paid',
        'bookingCode': bookingCode,
        'qrPayload': bookingCode,
        'restaurantNameSnapshot': restaurantNameSnapshot,
        'offerTitleSnapshot': offerTitle,
        'createdAt': FieldValue.serverTimestamp(),
        'paidAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return BookingModel(
        id: bookingRef.id,
        userId: userId,
        restaurantId: restaurantId,
        offerId: offerId,
        date: data['date'] as String? ?? '',
        startTime: data['startTime'] as String? ?? '',
        adults: adults,
        children: children,
        currency: data['currency'] as String? ?? 'USD',
        unitPriceAdult: priceAdult,
        unitPriceChild: priceChild,
        subtotal: subtotal,
        discount: discount,
        total: total,
        status: 'paid',
        bookingCode: bookingCode,
        qrPayload: bookingCode,
        createdAt: DateTime.now(),
        paidAt: DateTime.now(),
        restaurantNameSnapshot: restaurantNameSnapshot,
        offerTitleSnapshot: offerTitle,
      );
    });
  }

  Future<List<BookingModel>> getMyBookings(String userId) async {
    final snapshot = await firestore
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map(BookingModel.fromDoc).toList();
  }

  Future<BookingModel> getBookingById(String id) async {
    final doc = await firestore.collection('bookings').doc(id).get();
    return BookingModel.fromDoc(doc);
  }

  // Number parsing moved to NumberUtils

  static String _generateCode() {
    final random = Random();
    final millis = DateTime.now().millisecondsSinceEpoch;
    final suffix = random.nextInt(9999).toString().padLeft(4, '0');
    return 'JD$millis$suffix';
  }
}
