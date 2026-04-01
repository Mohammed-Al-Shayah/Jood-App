import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/errors/exceptions.dart';
import '../../domain/services/booking_order_policy.dart';
import '../../domain/services/booking_redemption_policy.dart';
import '../models/booking_model.dart';
import '../../../../core/utils/number_utils.dart';

class BookingRemoteDataSource {
  BookingRemoteDataSource(this.firestore);

  final FirebaseFirestore firestore;
  static const double _taxRate = 0.05;

  Future<BookingModel> createBookingWithTransaction({
    required String offerId,
    required String userId,
    required int adults,
    required int children,
    String? paymentSessionId,
  }) async {
    final offerRef = firestore.collection('offers').doc(offerId);
    final sessionKey = (paymentSessionId ?? '').trim();
    final safeSessionKey = sessionKey.replaceAll('/', '_');
    final bookingRef = safeSessionKey.isNotEmpty
        ? firestore.collection('bookings').doc('thawani_$safeSessionKey')
        : firestore.collection('bookings').doc();

    return firestore.runTransaction((transaction) async {
      if (sessionKey.isNotEmpty) {
        final existingSnap = await transaction.get(bookingRef);
        if (existingSnap.exists) {
          return BookingModel.fromDoc(existingSnap);
        }
      }

      final offerSnap = await transaction.get(offerRef);
      final data = offerSnap.data() ?? {};
      final restaurantId = (data['restaurantId'] as String? ?? '').trim();
      final offerTitle = (data['title'] as String? ?? '').trim();
      final bookableType = (data['bookableType'] as String? ?? 'restaurant')
          .trim()
          .toLowerCase();

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
      final tax = subtotal * _taxRate;
      final discount = 0.0;
      final total = subtotal + tax - discount;
      final bookingCode = _generateCode();
      String restaurantNameSnapshot = '';
      String coverImageUrlSnapshot = '';
      if (restaurantId.isNotEmpty) {
        final collection = bookableType == 'attraction'
            ? 'attractions'
            : 'restaurants';
        final restaurantRef = firestore
            .collection(collection)
            .doc(restaurantId);
        final restaurantSnap = await transaction.get(restaurantRef);
        final restaurantData =
            restaurantSnap.data() ?? const <String, dynamic>{};
        restaurantNameSnapshot = (restaurantData['name'] as String? ?? '')
            .trim();
        coverImageUrlSnapshot =
            (restaurantData['coverImageUrl'] as String? ?? '').trim();
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
        'endTime': data['endTime'],
        'adults': adults,
        'children': children,
        'currency': data['currency'] ?? 'USD',
        'unitPriceAdult': priceAdult,
        'unitPriceChild': priceChild,
        'subtotal': subtotal,
        'tax': tax,
        'discount': discount,
        'total': total,
        'status': 'paid',
        'bookingCode': bookingCode,
        'qrPayload': bookingCode,
        'paymentSessionId': sessionKey.isEmpty ? null : sessionKey,
        'restaurantNameSnapshot': restaurantNameSnapshot,
        'offerTitleSnapshot': offerTitle,
        'bookableType': bookableType,
        'coverImageUrlSnapshot': coverImageUrlSnapshot,
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
        endTime: data['endTime'] as String? ?? '',
        adults: adults,
        children: children,
        currency: data['currency'] as String? ?? 'USD',
        unitPriceAdult: priceAdult,
        unitPriceChild: priceChild,
        subtotal: subtotal,
        tax: tax,
        discount: discount,
        total: total,
        status: 'paid',
        bookingCode: bookingCode,
        qrPayload: bookingCode,
        createdAt: DateTime.now(),
        paymentSessionId: sessionKey.isEmpty ? null : sessionKey,
        paidAt: DateTime.now(),
        restaurantNameSnapshot: restaurantNameSnapshot,
        offerTitleSnapshot: offerTitle,
        bookableType: bookableType,
        coverImageUrlSnapshot: coverImageUrlSnapshot,
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

  Stream<List<BookingModel>> watchMyBookings(String userId) {
    return firestore
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(BookingModel.fromDoc).toList());
  }

  Future<List<BookingModel>> getAllBookings() async {
    final snapshot = await firestore
        .collection('bookings')
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map(BookingModel.fromDoc).toList();
  }

  Stream<List<BookingModel>> watchAllBookings() {
    return firestore
        .collection('bookings')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(BookingModel.fromDoc).toList());
  }

  Future<BookingModel> getBookingById(String id) async {
    final doc = await firestore.collection('bookings').doc(id).get();
    return BookingModel.fromDoc(doc);
  }

  Future<BookingModel> getBookingByCode(String code) async {
    final cleanedCode = code.trim();
    final query = await firestore
        .collection('bookings')
        .where('bookingCode', isEqualTo: cleanedCode)
        .limit(1)
        .get();
    if (query.docs.isEmpty) {
      throw BookingException('Order not found.');
    }
    return BookingModel.fromDoc(query.docs.first);
  }

  Future<void> cancelBooking({
    required String bookingId,
    required String actorUserId,
  }) async {
    await firestore.runTransaction((transaction) async {
      final bookingRef = firestore.collection('bookings').doc(bookingId);
      final bookingSnap = await transaction.get(bookingRef);
      if (!bookingSnap.exists) {
        throw BookingException('Booking not found.');
      }

      final data = bookingSnap.data() ?? const <String, dynamic>{};
      final status = (data['status'] as String? ?? '').trim().toLowerCase();
      if (BookingOrderPolicy.isCancelledStatus(status)) {
        throw BookingException('Booking already cancelled.');
      }
      if (BookingOrderPolicy.isCompletedStatus(status)) {
        throw BookingException('Completed booking cannot be cancelled.');
      }

      final bookingUserId = (data['userId'] as String? ?? '').trim();
      if (bookingUserId.isNotEmpty && bookingUserId != actorUserId) {
        throw BookingException('Not authorized.');
      }

      final date = (data['date'] as String? ?? '').trim();
      final startTime = (data['startTime'] as String? ?? '').trim();
      final endTime = (data['endTime'] as String? ?? '').trim();
      if (!BookingOrderPolicy.isCancellationAllowed(
        date: date,
        startTime: startTime,
        endTime: endTime,
      )) {
        throw BookingException('CANCELLATION_EXPIRED');
      }

      final offerId = (data['offerId'] as String? ?? '').trim();
      final adults = (data['adults'] as num?)?.toInt() ?? 0;
      final children = (data['children'] as num?)?.toInt() ?? 0;

      transaction.update(bookingRef, {
        'status': 'cancelled',
        'qrPayload': '',
        'cancelledAt': FieldValue.serverTimestamp(),
        'cancelledBy': actorUserId,
        'cancelledByRole': 'user',
        'refundStatus': 'pending',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (offerId.isNotEmpty) {
        final offerRef = firestore.collection('offers').doc(offerId);
        transaction.update(offerRef, {
          'bookedAdult': FieldValue.increment(-adults),
          'bookedChild': FieldValue.increment(-children),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  Future<void> completeBooking({
    required String bookingId,
    required String staffRestaurantId,
    required String actorUserId,
  }) async {
    await firestore.runTransaction((transaction) async {
      final bookingRef = firestore.collection('bookings').doc(bookingId);
      final bookingSnap = await transaction.get(bookingRef);
      if (!bookingSnap.exists) {
        throw BookingException('Order not found.');
      }

      final booking = BookingModel.fromDoc(bookingSnap);
      BookingRedemptionPolicy.validateBookingForStaff(
        bookingRestaurantId: booking.restaurantId,
        staffRestaurantId: staffRestaurantId,
        status: booking.status,
      );

      transaction.update(bookingRef, {
        'status': 'completed',
        'qrRedeemedAt': FieldValue.serverTimestamp(),
        'redeemedBy': actorUserId,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> updateRefundStatus({
    required String bookingId,
    required String status,
    required String actorUserId,
  }) async {
    final payload = <String, dynamic>{
      'refundStatus': status,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (status == 'checked') {
      payload['refundCheckedAt'] = FieldValue.serverTimestamp();
      payload['refundCheckedBy'] = actorUserId;
    }
    if (status == 'refunded') {
      payload['refundedAt'] = FieldValue.serverTimestamp();
      payload['refundedBy'] = actorUserId;
    }

    await firestore
        .collection('bookings')
        .doc(bookingId)
        .set(payload, SetOptions(merge: true));
  }

  // Number parsing moved to NumberUtils

  static String _generateCode() {
    final random = Random();
    final millis = DateTime.now().millisecondsSinceEpoch;
    final suffix = random.nextInt(9999).toString().padLeft(4, '0');
    return 'JD$millis$suffix';
  }
}
