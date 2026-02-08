import 'package:cloud_firestore/cloud_firestore.dart';
import 'date_utils.dart';

class SeedFirestore {
  const SeedFirestore._();

  static const String _seedDocId = 'demo_v5_omr';

  static Future<void> ensureSeeded() async {
    final firestore = FirebaseFirestore.instance;
    final metaRef = firestore.collection('seed_meta').doc(_seedDocId);
    final metaSnap = await metaRef.get();
    if (metaSnap.exists) return;

    await _seed(firestore);
    await metaRef.set({'seededAt': FieldValue.serverTimestamp()});
  }

  static Future<void> _seed(FirebaseFirestore firestore) async {
    final batch = firestore.batch();

    final restaurants = [
      {
        'id': 'demo_restaurant_1',
        'name': 'Harbor Feast',
        'cityId': 'Dubai',
        'area': 'Jumeirah',
        'rating': 4.6,
        'reviewsCount': 128,
        'coverImageUrl':
            'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?auto=format&fit=crop&w=1200&q=80',
        'about':
            'Seafood-forward buffet with live stations, sunset views, and a relaxed coastal vibe.',
        'phone': '+971 55 123 4567',
        'address': 'Jumeirah Beach Rd, Dubai',
        'geo': {'lat': 25.2048, 'lng': 55.2708},
        'openHours': {'from': '10:00', 'to': '23:00'},
        'highlights': ['Seafood buffet', 'Live stations', 'Outdoor seating'],
        'inclusions': ['Welcome drink', 'Dessert bar'],
        'exclusions': ['Alcoholic beverages'],
        'cancellationPolicy': [
          'Free cancellation up to 4 hours before booking',
          'No refund within 4 hours',
        ],
        'knowBeforeYouGo': ['Bring ID', 'Smart casual dress code'],
        'badge': '20% off',
        'priceFrom': 'From OMR 150',
        'discount': 'OMR 120',
        'discountPercent': 20,
        'slotsLeft': '6 slots left',
        'isActive': true,
      },
      {
        'id': 'demo_restaurant_2',
        'name': 'City Garden',
        'cityId': 'Dubai',
        'area': 'Downtown',
        'rating': 4.3,
        'reviewsCount': 92,
        'coverImageUrl':
            'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?auto=format&fit=crop&w=1200&q=80',
        'about':
            'Downtown dining with seasonal menus, family-friendly seating, and a skyline backdrop.',
        'phone': '+971 50 987 6543',
        'address': 'Downtown Boulevard, Dubai',
        'geo': {'lat': 25.2048, 'lng': 55.2708},
        'openHours': {'from': '09:00', 'to': '22:00'},
        'highlights': ['Organic menu', 'Kids friendly', 'City view'],
        'inclusions': ['Soft drinks'],
        'exclusions': ['Valet parking'],
        'cancellationPolicy': ['No cancellation within 2 hours'],
        'knowBeforeYouGo': ['Arrive 10 mins early'],
        'badge': '15% off',
        'priceFrom': 'From OMR 120',
        'discount': 'OMR 95',
        'discountPercent': 15,
        'slotsLeft': '10 slots left',
        'isActive': true,
      },
      {
        'id': 'demo_restaurant_3',
        'name': 'Palm Terrace',
        'cityId': 'Dubai',
        'area': 'Palm Jumeirah',
        'rating': 4.8,
        'reviewsCount': 214,
        'coverImageUrl':
            'https://images.unsplash.com/photo-1521017432531-fbd92d768814?auto=format&fit=crop&w=1200&q=80',
        'about':
            'Palm-side terrace featuring chef specials, live music nights, and panoramic views.',
        'phone': '+971 52 222 3344',
        'address': 'The Palm, Crescent Rd, Dubai',
        'geo': {'lat': 25.1124, 'lng': 55.1390},
        'openHours': {'from': '12:00', 'to': '00:00'},
        'highlights': ['Sea view', 'Chef specials', 'Live music'],
        'inclusions': ['Welcome mocktail', 'Dessert platter'],
        'exclusions': ['Shisha'],
        'cancellationPolicy': [
          'Free cancellation up to 6 hours before booking',
          '50% refund within 6 hours',
        ],
        'knowBeforeYouGo': ['Smart casual dress code', 'Valet available'],
        'badge': 'Top rated',
        'priceFrom': 'From OMR 200',
        'discount': 'OMR 160',
        'discountPercent': 20,
        'slotsLeft': '4 slots left',
        'isActive': true,
      },
      {
        'id': 'demo_restaurant_4',
        'name': 'Spice Avenue',
        'cityId': 'Dubai',
        'area': 'Business Bay',
        'rating': 4.1,
        'reviewsCount': 76,
        'coverImageUrl':
            'https://images.unsplash.com/photo-1421622548261-c45bfe178854?auto=format&fit=crop&w=1200&q=80',
        'about':
            'Bold street-food flavors with late-night bites and casual indoor-outdoor seating.',
        'phone': '+971 56 888 9922',
        'address': 'Bay Square, Business Bay, Dubai',
        'geo': {'lat': 25.1886, 'lng': 55.2636},
        'openHours': {'from': '08:00', 'to': '23:30'},
        'highlights': ['Street food', 'Late night bites'],
        'inclusions': ['Soft drinks', 'Free Wi-Fi'],
        'exclusions': ['Parking fees'],
        'cancellationPolicy': ['No cancellation within 3 hours'],
        'knowBeforeYouGo': ['Arrive 10 mins early', 'Family seating available'],
        'badge': 'Popular',
        'priceFrom': 'From OMR 95',
        'discount': 'OMR 75',
        'discountPercent': 21,
        'slotsLeft': '12 slots left',
        'isActive': true,
      },
      {
        'id': 'demo_restaurant_5',
        'name': 'Marina Grill',
        'cityId': 'Dubai',
        'area': 'Dubai Marina',
        'rating': 4.4,
        'reviewsCount': 143,
        'coverImageUrl':
            'https://images.unsplash.com/photo-1528605248644-14dd04022da1?auto=format&fit=crop&w=1200&q=80',
        'about':
            'Marina-side grill buffet with open kitchen, fresh salads, and a breezy terrace.',
        'phone': '+971 55 707 8899',
        'address': 'Marina Walk, Dubai',
        'geo': {'lat': 25.0800, 'lng': 55.1400},
        'openHours': {'from': '11:00', 'to': '23:00'},
        'highlights': ['Grill buffet', 'Outdoor terrace'],
        'inclusions': ['Salad bar', 'Dessert'],
        'exclusions': ['Alcohol'],
        'cancellationPolicy': [
          'Free cancellation up to 2 hours before booking',
        ],
        'knowBeforeYouGo': ['Smart casual'],
        'badge': '10% off',
        'priceFrom': 'From OMR 125',
        'discount': 'OMR 110',
        'discountPercent': 12,
        'slotsLeft': '8 slots left',
        'isActive': true,
      },
      {
        'id': 'demo_restaurant_6',
        'name': 'Old Town Brunch',
        'cityId': 'Dubai',
        'area': 'Al Fahidi',
        'rating': 3.9,
        'reviewsCount': 41,
        'coverImageUrl':
            'https://images.unsplash.com/photo-1481931098730-318b6f776db0?auto=format&fit=crop&w=1200&q=80',
        'about':
            'Laid-back brunch spot with traditional dishes, tea service, and heritage vibes.',
        'phone': '+971 54 111 2233',
        'address': 'Al Fahidi Historical District, Dubai',
        'geo': {'lat': 25.2630, 'lng': 55.2972},
        'openHours': {'from': '07:00', 'to': '16:00'},
        'highlights': ['Traditional dishes', 'Family friendly'],
        'inclusions': ['Tea & coffee'],
        'exclusions': ['Parking'],
        'cancellationPolicy': ['No cancellation within 1 hour'],
        'knowBeforeYouGo': ['Casual dress', 'Outdoor seating limited'],
        'badge': '',
        'priceFrom': 'From OMR 80',
        'discount': 'OMR 65',
        'discountPercent': 18,
        'slotsLeft': '15 slots left',
        'isActive': true,
      },
    ];

    for (final restaurant in restaurants) {
      final ref = firestore
          .collection('restaurants')
          .doc(restaurant['id'] as String);
      batch.set(ref, {
        ...restaurant,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    final dates = List.generate(
      7,
      (index) => DateTime.now().add(Duration(days: index)),
    );
    final times = [
      {'start': '09:00', 'end': '11:00', 'title': 'Breakfast Entry'},
      {'start': '12:00', 'end': '14:00', 'title': 'Lunch Entry'},
      {'start': '18:00', 'end': '20:00', 'title': 'Dinner Entry'},
      {'start': '20:30', 'end': '22:00', 'title': 'Late Dinner'},
      {'start': '22:30', 'end': '00:00', 'title': 'Night Bites'},
    ];
    final breakfastLunchOnlyDays = <int>{1, 3, 5};

    for (var rIndex = 0; rIndex < restaurants.length; rIndex++) {
      final restaurant = restaurants[rIndex];
      for (var dIndex = 0; dIndex < dates.length; dIndex++) {
        final date = dates[dIndex];
        for (var tIndex = 0; tIndex < times.length; tIndex++) {
          final time = times[tIndex];
          final isBreakfastOrLunch = tIndex == 0 || tIndex == 1;
          if (breakfastLunchOnlyDays.contains(dIndex) && !isBreakfastOrLunch) {
            continue;
          }
          final offerRef = firestore
              .collection('offers')
              .doc(
                _offerId(
                  restaurant['id'] as String,
                  date,
                  time['start'] as String,
                ),
              );

          final baseAdult = 70 + (rIndex * 15) + (tIndex * 8) + (dIndex * 6);
          final baseChild = (baseAdult * 0.5).round();
          final capacityAdult = 20 + (rIndex * 5);
          final capacityChild = 10 + (tIndex * 3);
          final bookedAdult = (dIndex % 3 == 0)
              ? (capacityAdult - 2)
              : (rIndex);
          final bookedChild = (dIndex % 4 == 0)
              ? (capacityChild - 1)
              : (tIndex);

          final isSoldOut =
              bookedAdult >= capacityAdult ||
              bookedChild >= capacityChild ||
              (dIndex == 6 && tIndex == 4);
          final isLow =
              !isSoldOut &&
              ((capacityAdult - bookedAdult) <= 3 ||
                  (capacityChild - bookedChild) <= 3);
          final status = isSoldOut
              ? 'sold_out'
              : isLow
              ? 'low'
              : 'active';

          batch.set(offerRef, {
            'restaurantId': restaurant['id'],
            'date': AppDateUtils.formatDate(date),
            'startTime': time['start'],
            'endTime': time['end'],
            'currency': 'OMR',
            'priceAdult': baseAdult,
            'priceAdultOriginal': baseAdult + 25,
            'priceChild': baseChild,
            'time': time['start'],
            'price': 'OMR $baseAdult',
            'status': status,
            'capacityAdult': capacityAdult,
            'capacityChild': capacityChild,
            'bookedAdult': bookedAdult,
            'bookedChild': bookedChild,
            'title': time['title'],
            'entryConditions': [
              'Arrive 15 minutes early',
              'Mobile voucher accepted',
              if (tIndex == 4) 'Late entry allowed',
            ],
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }
    }

    final users = [
      {
        'id': 'demo_user_1',
        'fullName': 'John Doe',
        'email': 'john@example.com',
        'phone': '+971 50 000 0000',
        'role': 'guest',
      },
      {
        'id': 'demo_user_2',
        'fullName': 'Sara Ali',
        'email': 'sara@example.com',
        'phone': '+971 55 123 0001',
        'role': 'guest',
      },
      {
        'id': 'demo_user_3',
        'fullName': 'Omar Khan',
        'email': 'omar@example.com',
        'phone': '+971 52 777 1000',
        'role': 'guest',
      },
    ];
    for (final user in users) {
      final userRef = firestore.collection('users').doc(user['id'] as String);
      batch.set(userRef, {
        'fullName': user['fullName'],
        'email': user['email'],
        'phone': user['phone'],
        'role': user['role'],
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    final bookings = [
      {
        'id': 'demo_booking_1',
        'userId': 'demo_user_1',
        'restaurantId': 'demo_restaurant_1',
        'dateIndex': 0,
        'timeIndex': 1,
        'adults': 2,
        'children': 1,
        'code': 'BKG1769509734255',
      },
      {
        'id': 'demo_booking_2',
        'userId': 'demo_user_2',
        'restaurantId': 'demo_restaurant_3',
        'dateIndex': 2,
        'timeIndex': 2,
        'adults': 4,
        'children': 0,
        'code': 'BKG1769509735001',
      },
      {
        'id': 'demo_booking_3',
        'userId': 'demo_user_3',
        'restaurantId': 'demo_restaurant_5',
        'dateIndex': 4,
        'timeIndex': 0,
        'adults': 1,
        'children': 2,
        'code': 'BKG1769509737001',
      },
    ];

    for (final booking in bookings) {
      final restaurantId = booking['restaurantId'] as String;
      final date = dates[booking['dateIndex'] as int];
      final time = times[booking['timeIndex'] as int];
      final offerId = _offerId(restaurantId, date, time['start'] as String);
      final adults = booking['adults'] as int;
      final children = booking['children'] as int;
      final unitPriceAdult = 100.0 + (booking['timeIndex'] as int) * 15;
      final unitPriceChild = unitPriceAdult * 0.5;
      final subtotal = unitPriceAdult * adults + unitPriceChild * children;
      final discount = 0.0;
      final total = subtotal - discount;

      final bookingRef = firestore
          .collection('bookings')
          .doc(booking['id'] as String);
      batch.set(bookingRef, {
        'userId': booking['userId'],
        'restaurantId': restaurantId,
        'offerId': offerId,
        'date': AppDateUtils.formatDate(date),
        'startTime': time['start'],
        'adults': adults,
        'children': children,
        'currency': 'OMR',
        'unitPriceAdult': unitPriceAdult,
        'unitPriceChild': unitPriceChild,
        'subtotal': subtotal,
        'discount': discount,
        'total': total,
        'status': 'confirmed',
        'bookingCode': booking['code'],
        'qrPayload': 'BOOKING:${booking['code']}',
        'createdAt': FieldValue.serverTimestamp(),
        'paidAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      final offerRef = firestore.collection('offers').doc(offerId);
      batch.update(offerRef, {
        'bookedAdult': FieldValue.increment(adults),
        'bookedChild': FieldValue.increment(children),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final paymentRef = firestore
          .collection('payments')
          .doc('pay_${booking['id']}');
      batch.set(paymentRef, {
        'bookingId': booking['id'],
        'amount': total,
        'status': 'success',
        'method': 'card',
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    await batch.commit();
  }

  // Date formatting moved to DateUtils

  static String _offerId(String restaurantId, DateTime date, String startTime) {
    final safeTime = startTime.replaceAll(':', '');
    return 'offer_${restaurantId}_${AppDateUtils.formatDate(date)}_$safeTime';
  }
}

