import 'package:cloud_firestore/cloud_firestore.dart';

class SeedFirestore {
  const SeedFirestore._();

  static const String _seedDocId = 'demo_v1';

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
        'phone': '+971 55 123 4567',
        'address': 'Jumeirah Beach Rd, Dubai',
        'geo': {'lat': 25.2048, 'lng': 55.2708},
        'openHours': {'from': '10:00', 'to': '23:00'},
        'highlights': ['Seafood buffet', 'Live stations', 'Outdoor seating'],
        'inclusions': ['Welcome drink', 'Dessert bar'],
        'exclusions': ['Alcoholic beverages'],
        'cancellationPolicy': 'Free cancellation up to 4 hours before.',
        'knowBeforeYouGo': ['Bring ID', 'Smart casual dress code'],
        'badge': '20% off',
        'priceFrom': 'From AED 120',
        'discount': 'AED 150',
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
        'phone': '+971 50 987 6543',
        'address': 'Downtown Boulevard, Dubai',
        'geo': {'lat': 25.2048, 'lng': 55.2708},
        'openHours': {'from': '09:00', 'to': '22:00'},
        'highlights': ['Organic menu', 'Kids friendly', 'City view'],
        'inclusions': ['Soft drinks'],
        'exclusions': ['Valet parking'],
        'cancellationPolicy': 'No cancellation within 2 hours.',
        'knowBeforeYouGo': ['Arrive 10 mins early'],
        'badge': '15% off',
        'priceFrom': 'From AED 95',
        'discount': 'AED 120',
        'discountPercent': 15,
        'slotsLeft': '10 slots left',
        'isActive': true,
      },
    ];

    for (final restaurant in restaurants) {
      final ref = firestore.collection('restaurants').doc(restaurant['id'] as String);
      batch.set(ref, {
        ...restaurant,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    final dates = List.generate(3, (index) => DateTime.now().add(Duration(days: index)));
    final times = [
      {'start': '12:00', 'end': '14:00', 'title': 'Lunch Entry'},
      {'start': '18:00', 'end': '20:00', 'title': 'Dinner Entry'},
      {'start': '20:30', 'end': '22:00', 'title': 'Late Dinner'},
    ];

    for (final restaurant in restaurants) {
      for (final date in dates) {
        for (final time in times) {
          final offerRef = firestore.collection('offers').doc();
          batch.set(offerRef, {
            'restaurantId': restaurant['id'],
            'date': _formatDate(date),
            'startTime': time['start'],
            'endTime': time['end'],
            'currency': 'AED',
            'priceAdult': 120,
            'priceChild': 60,
            'capacityAdult': 40,
            'capacityChild': 20,
            'bookedAdult': 0,
            'bookedChild': 0,
            'status': 'active',
            'title': time['title'],
            'entryConditions': [
              'Arrive 15 minutes early',
              'Mobile voucher accepted',
            ],
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }
    }

    await batch.commit();
  }

  static String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
