import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'date_utils.dart';
import 'guest_pricing_utils.dart';

class SeedFirestore {
  const SeedFirestore._();

  static const String _seedMetaDocId = 'demo_dataset';
  static const String _seedVersion = 'v10_bilingual_full';

  static Future<void> ensureSeeded() async {
    if (!kDebugMode) return;

    final firestore = FirebaseFirestore.instance;
    final metaRef = firestore.collection('seed_meta').doc(_seedMetaDocId);
    final metaSnap = await metaRef.get();
    final currentVersion = (metaSnap.data()?['version'] as String? ?? '')
        .trim();

    if (currentVersion == _seedVersion) return;

    await _clearDemoData(firestore);
    await _seed(firestore);
    await metaRef.set({
      'version': _seedVersion,
      'seededAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<void> _clearDemoData(FirebaseFirestore firestore) async {
    await _deleteByPrefix(
      firestore: firestore,
      collection: firestore.collection('seed_meta'),
      prefix: 'demo_',
    );
    await _deleteByPrefix(
      firestore: firestore,
      collection: firestore.collection('restaurants'),
      prefix: 'demo_restaurant_',
    );
    await _deleteByPrefix(
      firestore: firestore,
      collection: firestore.collection('attractions'),
      prefix: 'demo_attraction_',
    );
    await _deleteByPrefix(
      firestore: firestore,
      collection: firestore.collection('offers'),
      prefix: 'offer_demo_',
    );
    await _deleteByPrefix(
      firestore: firestore,
      collection: firestore.collection('users'),
      prefix: 'demo_user_',
    );
    await _deleteByPrefix(
      firestore: firestore,
      collection: firestore.collection('bookings'),
      prefix: 'demo_booking_',
    );
    await _deleteByPrefix(
      firestore: firestore,
      collection: firestore.collection('payments'),
      prefix: 'pay_demo_booking_',
    );
  }

  static Future<void> _deleteByPrefix({
    required FirebaseFirestore firestore,
    required CollectionReference<Map<String, dynamic>> collection,
    required String prefix,
  }) async {
    while (true) {
      final snapshot = await collection
          .where(FieldPath.documentId, isGreaterThanOrEqualTo: prefix)
          .where(FieldPath.documentId, isLessThan: '$prefix\uf8ff')
          .limit(450)
          .get();

      if (snapshot.docs.isEmpty) return;

      final batch = firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      if (snapshot.docs.length < 450) return;
    }
  }

  static Future<void> _seed(FirebaseFirestore firestore) async {
    final batch = firestore.batch();
    final dates = List.generate(
      8,
      (index) => DateTime.now().add(Duration(days: index)),
    );

    for (final restaurant in _restaurantDocs()) {
      final id = restaurant['id'] as String;
      batch.set(firestore.collection('restaurants').doc(id), {
        ...restaurant,
        ..._seedMetaFields(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    for (final attraction in _attractionDocs()) {
      final id = attraction['id'] as String;
      batch.set(firestore.collection('attractions').doc(id), {
        ...attraction,
        ..._seedMetaFields(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    _seedBuffetOffers(batch, firestore, dates);
    _seedSetMenuOffers(batch, firestore, dates);
    _seedComboOffers(batch, firestore, dates);
    _seedAttractionOffers(batch, firestore, dates);
    _seedUsers(batch, firestore);
    _seedBookings(batch, firestore, dates);

    await batch.commit();
  }

  static void _seedBuffetOffers(
    WriteBatch batch,
    FirebaseFirestore firestore,
    List<DateTime> dates,
  ) {
    final configs = [
      {
        'restaurantId': 'demo_restaurant_1',
        'slots': [
          {
            'mealType': 'breakfast',
            'titleEn': 'Breakfast Buffet',
            'titleAr': 'بوفيه الإفطار',
            'start': '08:00',
            'end': '10:30',
            'adultBase': 8.5,
            'adultOriginal': 10.0,
            'childBase': 4.5,
            'capacityAdult': 28,
            'capacityChild': 12,
          },
          {
            'mealType': 'lunch',
            'titleEn': 'Lunch Buffet',
            'titleAr': 'بوفيه الغداء',
            'start': '13:00',
            'end': '15:30',
            'adultBase': 11.0,
            'adultOriginal': 13.0,
            'childBase': 6.0,
            'capacityAdult': 30,
            'capacityChild': 14,
          },
          {
            'mealType': 'dinner',
            'titleEn': 'Dinner Buffet',
            'titleAr': 'بوفيه العشاء',
            'start': '19:00',
            'end': '22:00',
            'adultBase': 14.0,
            'adultOriginal': 17.0,
            'childBase': 7.0,
            'capacityAdult': 34,
            'capacityChild': 16,
          },
        ],
      },
      {
        'restaurantId': 'demo_restaurant_2',
        'slots': [
          {
            'mealType': 'breakfast',
            'titleEn': 'Breakfast Buffet',
            'titleAr': 'بوفيه الإفطار',
            'start': '08:30',
            'end': '10:30',
            'adultBase': 7.0,
            'adultOriginal': 8.5,
            'childBase': 3.5,
            'capacityAdult': 22,
            'capacityChild': 10,
          },
          {
            'mealType': 'lunch',
            'titleEn': 'Lunch Buffet',
            'titleAr': 'بوفيه الغداء',
            'start': '12:30',
            'end': '15:00',
            'adultBase': 9.5,
            'adultOriginal': 11.0,
            'childBase': 5.0,
            'capacityAdult': 24,
            'capacityChild': 12,
          },
          {
            'mealType': 'dinner',
            'titleEn': 'Dinner Buffet',
            'titleAr': 'بوفيه العشاء',
            'start': '18:30',
            'end': '21:30',
            'adultBase': 12.5,
            'adultOriginal': 14.5,
            'childBase': 6.5,
            'capacityAdult': 26,
            'capacityChild': 12,
          },
        ],
      },
      {
        'restaurantId': 'demo_restaurant_3',
        'slots': [
          {
            'mealType': 'breakfast',
            'titleEn': 'Breakfast Buffet',
            'titleAr': 'بوفيه الإفطار',
            'start': '08:00',
            'end': '10:30',
            'adultBase': 9.0,
            'adultOriginal': 10.5,
            'childBase': 4.5,
            'capacityAdult': 20,
            'capacityChild': 10,
          },
          {
            'mealType': 'lunch',
            'titleEn': 'Lunch Buffet',
            'titleAr': 'بوفيه الغداء',
            'start': '13:00',
            'end': '15:30',
            'adultBase': 12.0,
            'adultOriginal': 14.0,
            'childBase': 6.0,
            'capacityAdult': 24,
            'capacityChild': 12,
          },
          {
            'mealType': 'dinner',
            'titleEn': 'Dinner Buffet',
            'titleAr': 'بوفيه العشاء',
            'start': '19:30',
            'end': '22:30',
            'adultBase': 16.0,
            'adultOriginal': 19.0,
            'childBase': 8.0,
            'capacityAdult': 28,
            'capacityChild': 14,
          },
        ],
      },
    ];

    for (final config in configs) {
      final restaurantId = config['restaurantId'] as String;
      final slots = config['slots'] as List<dynamic>;

      for (var dayIndex = 0; dayIndex < dates.length; dayIndex++) {
        final date = dates[dayIndex];
        for (var slotIndex = 0; slotIndex < slots.length; slotIndex++) {
          final slot = slots[slotIndex] as Map<String, dynamic>;
          final soldOut =
              restaurantId == 'demo_restaurant_2' &&
              dayIndex == 6 &&
              slot['mealType'] == 'dinner';
          final low = !soldOut && ((dayIndex + slotIndex) % 4 == 0);

          final capacityAdult = slot['capacityAdult'] as int;
          final capacityChild = slot['capacityChild'] as int;
          final bookedAdult = soldOut
              ? capacityAdult
              : low
              ? capacityAdult - 2
              : 4 + ((dayIndex + slotIndex) % 6);
          final bookedChild = soldOut
              ? capacityChild
              : low
              ? capacityChild - 1
              : 1 + ((dayIndex + slotIndex) % 4);

          batch.set(
            firestore
                .collection('offers')
                .doc(
                  _offerId(
                    restaurantId,
                    date,
                    slot['start'] as String,
                    suffix: 'buffet_${slot['mealType']}',
                  ),
                ),
            {
              ..._offerSeedFields(
                restaurantId: restaurantId,
                date: date,
                startTime: slot['start'] as String,
                endTime: slot['end'] as String,
                priceAdult: (slot['adultBase'] as double) + (dayIndex * 0.5),
                priceAdultOriginal:
                    (slot['adultOriginal'] as double) + (dayIndex * 0.5),
                priceChild: (slot['childBase'] as double) + (dayIndex * 0.25),
                capacityAdult: capacityAdult,
                capacityChild: capacityChild,
                bookedAdult: bookedAdult,
                bookedChild: bookedChild,
                status: soldOut
                    ? 'sold_out'
                    : low
                    ? 'low'
                    : 'active',
                titleEn: slot['titleEn'] as String,
                titleAr: slot['titleAr'] as String,
                bookingCategory: 'buffet',
                bookableType: 'restaurant',
                guestPricingMode: guestPricingModeAdultsChildren,
                mealType: slot['mealType'] as String,
                entryConditionsEn: [
                  'Arrive 15 minutes before your meal window.',
                  'Children under 5 can enter free when sharing a table.',
                ],
                entryConditionsAr: [
                  'يرجى الحضور قبل الموعد بـ 15 دقيقة.',
                  'الأطفال دون 5 سنوات يدخلون مجانًا عند مشاركة الطاولة.',
                ],
              ),
            },
          );
        }
      }
    }
  }

  static void _seedSetMenuOffers(
    WriteBatch batch,
    FirebaseFirestore firestore,
    List<DateTime> dates,
  ) {
    final configs = [
      {'restaurantId': 'demo_restaurant_1'},
      {'restaurantId': 'demo_restaurant_3'},
    ];
    final slots = [
      {
        'mealType': 'breakfast',
        'titleEn': 'Breakfast Set Menu',
        'titleAr': 'قائمة إفطار ثابتة',
        'start': '08:30',
        'end': '10:30',
        'base': 6.5,
        'original': 8.0,
      },
      {
        'mealType': 'lunch',
        'titleEn': 'Lunch Set Menu',
        'titleAr': 'قائمة غداء ثابتة',
        'start': '13:00',
        'end': '15:00',
        'base': 8.5,
        'original': 10.0,
      },
      {
        'mealType': 'dinner',
        'titleEn': 'Dinner Set Menu',
        'titleAr': 'قائمة عشاء ثابتة',
        'start': '19:30',
        'end': '22:00',
        'base': 11.0,
        'original': 13.0,
      },
    ];

    for (final config in configs) {
      final restaurantId = config['restaurantId'] as String;
      for (var dayIndex = 0; dayIndex < dates.length; dayIndex++) {
        final date = dates[dayIndex];
        for (var slotIndex = 0; slotIndex < slots.length; slotIndex++) {
          final slot = slots[slotIndex];
          final soldOut =
              restaurantId == 'demo_restaurant_3' &&
              dayIndex == 5 &&
              slot['mealType'] == 'dinner';
          final low =
              !soldOut &&
              restaurantId == 'demo_restaurant_1' &&
              dayIndex == 3 &&
              slot['mealType'] == 'lunch';
          final capacity = 20 + (slotIndex * 3);
          final booked = soldOut
              ? capacity
              : low
              ? capacity - 2
              : 3 + ((dayIndex + slotIndex) % 5);

          batch.set(
            firestore
                .collection('offers')
                .doc(
                  _offerId(
                    restaurantId,
                    date,
                    slot['start'] as String,
                    suffix: 'set_${slot['mealType']}',
                  ),
                ),
            {
              ..._offerSeedFields(
                restaurantId: restaurantId,
                date: date,
                startTime: slot['start'] as String,
                endTime: slot['end'] as String,
                priceAdult:
                    (slot['base'] as double) +
                    (dayIndex * 0.5) +
                    (slotIndex * 0.25),
                priceAdultOriginal:
                    (slot['original'] as double) +
                    (dayIndex * 0.5) +
                    (slotIndex * 0.25),
                priceChild: 0,
                capacityAdult: capacity,
                capacityChild: 0,
                bookedAdult: booked,
                bookedChild: 0,
                status: soldOut
                    ? 'sold_out'
                    : low
                    ? 'low'
                    : 'active',
                titleEn: slot['titleEn'] as String,
                titleAr: slot['titleAr'] as String,
                bookingCategory: 'set_menu',
                bookableType: 'restaurant',
                guestPricingMode: guestPricingModePerson,
                mealType: slot['mealType'] as String,
                entryConditionsEn: [
                  'One fixed menu is charged per guest.',
                  'Dish selection is completed after the booking step.',
                ],
                entryConditionsAr: [
                  'يتم احتساب قائمة ثابتة واحدة لكل شخص.',
                  'اختيار الأطباق يتم بعد خطوة الحجز.',
                ],
              ),
            },
          );
        }
      }
    }
  }

  static void _seedComboOffers(
    WriteBatch batch,
    FirebaseFirestore firestore,
    List<DateTime> dates,
  ) {
    final configs = [
      {
        'restaurantId': 'demo_restaurant_2',
        'start': '11:00',
        'end': '23:00',
        'items': [
          {
            'titleEn': 'Broasted Box',
            'titleAr': 'بوكس بروست',
            'descriptionEn':
                'Chicken, fries, garlic sauce, and a soft drink in one box.',
            'descriptionAr':
                'دجاج وبطاطس وصوص ثوم ومشروب غازي داخل باقة واحدة.',
            'base': 4.5,
            'original': 5.5,
            'capacity': 40,
          },
          {
            'titleEn': 'Family Crunch Combo',
            'titleAr': 'كومبو العائلة المقرمش',
            'descriptionEn':
                'A sharing combo with chicken, sides, sauces, and drinks.',
            'descriptionAr':
                'كومبو للمشاركة مع الدجاج والأطباق الجانبية والصلصات والمشروبات.',
            'base': 9.5,
            'original': 11.5,
            'capacity': 24,
          },
          {
            'titleEn': 'Late Night Snack Combo',
            'titleAr': 'كومبو سناك آخر الليل',
            'descriptionEn': 'A lighter combo for late-night orders.',
            'descriptionAr': 'كومبو أخف لطلبات آخر الليل.',
            'base': 3.5,
            'original': 4.5,
            'capacity': 28,
          },
        ],
      },
      {
        'restaurantId': 'demo_restaurant_3',
        'start': '12:00',
        'end': '22:30',
        'items': [
          {
            'titleEn': 'Majlis Lunch Combo',
            'titleAr': 'كومبو غداء المجلس',
            'descriptionEn': 'One main plate, side, dessert, and drink.',
            'descriptionAr': 'طبق رئيسي وطبق جانبي وحلى ومشروب.',
            'base': 6.5,
            'original': 8.0,
            'capacity': 26,
          },
          {
            'titleEn': 'Sea View Sharing Box',
            'titleAr': 'بوكس المشاركة بإطلالة بحرية',
            'descriptionEn': 'A sharing meal with grills, rice, and drinks.',
            'descriptionAr': 'وجبة مشاركة مع مشاوي وأرز ومشروبات.',
            'base': 11.5,
            'original': 13.5,
            'capacity': 18,
          },
          {
            'titleEn': 'Dessert & Coffee Duo',
            'titleAr': 'ثنائي القهوة والحلى',
            'descriptionEn': 'Two desserts with specialty coffee.',
            'descriptionAr': 'حصتان من الحلى مع قهوة مختصة.',
            'base': 5.0,
            'original': 6.0,
            'capacity': 20,
          },
        ],
      },
    ];

    for (final config in configs) {
      final restaurantId = config['restaurantId'] as String;
      final items = config['items'] as List<dynamic>;
      final start = config['start'] as String;
      final end = config['end'] as String;

      for (var dayIndex = 0; dayIndex < dates.length; dayIndex++) {
        final date = dates[dayIndex];
        for (var itemIndex = 0; itemIndex < items.length; itemIndex++) {
          final item = items[itemIndex] as Map<String, dynamic>;
          final soldOut =
              restaurantId == 'demo_restaurant_2' &&
              dayIndex == 4 &&
              itemIndex == 1;
          final low = !soldOut && ((dayIndex + itemIndex) % 5 == 0);
          final capacity = item['capacity'] as int;
          final booked = soldOut
              ? capacity
              : low
              ? capacity - 2
              : 3 + ((dayIndex + itemIndex) % 5);

          batch.set(
            firestore
                .collection('offers')
                .doc(
                  _offerId(
                    restaurantId,
                    date,
                    start,
                    suffix: 'combo_$itemIndex',
                  ),
                ),
            {
              ..._offerSeedFields(
                restaurantId: restaurantId,
                date: date,
                startTime: start,
                endTime: end,
                priceAdult: (item['base'] as double) + ((dayIndex % 3) * 0.25),
                priceAdultOriginal:
                    (item['original'] as double) + ((dayIndex % 3) * 0.25),
                priceChild: 0,
                capacityAdult: capacity,
                capacityChild: 0,
                bookedAdult: booked,
                bookedChild: 0,
                status: soldOut
                    ? 'sold_out'
                    : low
                    ? 'low'
                    : 'active',
                titleEn: item['titleEn'] as String,
                titleAr: item['titleAr'] as String,
                bookingCategory: 'combo',
                bookableType: 'restaurant',
                guestPricingMode: guestPricingModePerson,
                packageDescriptionEn: item['descriptionEn'] as String,
                packageDescriptionAr: item['descriptionAr'] as String,
                entryConditionsEn: [
                  'Each quantity equals one combo package.',
                  'Prepared fresh once the order is confirmed.',
                ],
                entryConditionsAr: [
                  'كل كمية تعادل طلب كومبو واحد.',
                  'يتم التحضير طازجًا بعد تأكيد الطلب.',
                ],
              ),
            },
          );
        }
      }
    }
  }

  static void _seedAttractionOffers(
    WriteBatch batch,
    FirebaseFirestore firestore,
    List<DateTime> dates,
  ) {
    final configs = [
      {
        'attractionId': 'demo_attraction_1',
        'guestPricingMode': guestPricingModeAdultsChildren,
        'slots': [
          {
            'start': '10:00',
            'end': '14:00',
            'packages': [
              {
                'nameEn': 'Explorer Pass',
                'nameAr': 'تذكرة المستكشف',
                'descriptionEn': 'Standard park access with main activities.',
                'descriptionAr': 'دخول عادي للمنتزه مع الأنشطة الأساسية.',
                'adultBase': 7.5,
                'adultOriginal': 9.0,
                'childBase': 4.0,
                'capacityAdult': 22,
                'capacityChild': 14,
              },
              {
                'nameEn': 'Family Splash Pass',
                'nameAr': 'تذكرة المرح العائلية',
                'descriptionEn':
                    'Family-oriented package with wider activity access.',
                'descriptionAr': 'باقة عائلية بتغطية أوسع للأنشطة.',
                'adultBase': 10.0,
                'adultOriginal': 12.0,
                'childBase': 5.0,
                'capacityAdult': 16,
                'capacityChild': 10,
              },
            ],
          },
          {
            'start': '16:00',
            'end': '20:00',
            'packages': [
              {
                'nameEn': 'Sunset Adventure',
                'nameAr': 'مغامرة الغروب',
                'descriptionEn':
                    'Evening package with cooler weather and peak fun.',
                'descriptionAr': 'باقة مسائية مع طقس ألطف وأجواء أكثر حيوية.',
                'adultBase': 8.5,
                'adultOriginal': 10.0,
                'childBase': 4.5,
                'capacityAdult': 20,
                'capacityChild': 12,
              },
              {
                'nameEn': 'VIP Family Zone',
                'nameAr': 'منطقة العائلة VIP',
                'descriptionEn':
                    'Premium seating and faster entry for families.',
                'descriptionAr': 'جلسات مميزة ودخول أسرع للعائلات.',
                'adultBase': 12.0,
                'adultOriginal': 14.0,
                'childBase': 6.0,
                'capacityAdult': 12,
                'capacityChild': 8,
              },
            ],
          },
        ],
      },
      {
        'attractionId': 'demo_attraction_2',
        'guestPricingMode': guestPricingModePerson,
        'slots': [
          {
            'start': '17:30',
            'end': '19:00',
            'packages': [
              {
                'nameEn': 'Classic Cruise',
                'nameAr': 'الرحلة الكلاسيكية',
                'descriptionEn': 'Shared boarding with open deck seating.',
                'descriptionAr': 'صعود مشترك مع جلسات سطح مفتوح.',
                'adultBase': 6.0,
                'adultOriginal': 7.5,
                'capacity': 28,
              },
              {
                'nameEn': 'Dinner Cruise',
                'nameAr': 'رحلة العشاء',
                'descriptionEn': 'Dinner seating with skyline view.',
                'descriptionAr': 'جلسة عشاء مع إطلالة على الأفق.',
                'adultBase': 11.0,
                'adultOriginal': 13.0,
                'capacity': 18,
              },
              {
                'nameEn': 'Upper Deck Lounge',
                'nameAr': 'صالة السطح العلوي',
                'descriptionEn': 'Premium deck seating and priority boarding.',
                'descriptionAr': 'جلسة مميزة على السطح مع أولوية الصعود.',
                'adultBase': 13.5,
                'adultOriginal': 15.5,
                'capacity': 10,
              },
            ],
          },
          {
            'start': '20:00',
            'end': '21:30',
            'packages': [
              {
                'nameEn': 'Classic Cruise',
                'nameAr': 'الرحلة الكلاسيكية',
                'descriptionEn': 'Late sailing with standard shared seating.',
                'descriptionAr': 'رحلة متأخرة مع جلسات مشتركة عادية.',
                'adultBase': 7.0,
                'adultOriginal': 8.5,
                'capacity': 24,
              },
              {
                'nameEn': 'Dinner Cruise',
                'nameAr': 'رحلة العشاء',
                'descriptionEn': 'Late dinner sailing with table service.',
                'descriptionAr': 'رحلة عشاء متأخرة مع خدمة على الطاولة.',
                'adultBase': 12.0,
                'adultOriginal': 14.0,
                'capacity': 16,
              },
              {
                'nameEn': 'Upper Deck Lounge',
                'nameAr': 'صالة السطح العلوي',
                'descriptionEn': 'Night lounge with premium skyline focus.',
                'descriptionAr': 'صالة ليلية مميزة مع تركيز على الإطلالة.',
                'adultBase': 14.5,
                'adultOriginal': 16.5,
                'capacity': 8,
              },
            ],
          },
        ],
      },
      {
        'attractionId': 'demo_attraction_3',
        'guestPricingMode': guestPricingModeCoupon,
        'slots': [
          {
            'start': '12:00',
            'end': '23:00',
            'packages': [
              {
                'nameEn': '10 Games Coupon',
                'nameAr': 'كوبون 10 ألعاب',
                'descriptionEn':
                    'Includes 10 game credits for selected arcade machines.',
                'descriptionAr':
                    'يشمل 10 أرصدة ألعاب للأجهزة المحددة داخل الصالة.',
                'adultBase': 3.0,
                'adultOriginal': 4.0,
                'capacity': 60,
              },
              {
                'nameEn': '25 Games Coupon',
                'nameAr': 'كوبون 25 لعبة',
                'descriptionEn':
                    'Value pack for frequent players with 25 game credits.',
                'descriptionAr':
                    'باقة اقتصادية للاعبين المتكررين وتشمل 25 رصيد لعبة.',
                'adultBase': 6.0,
                'adultOriginal': 8.0,
                'capacity': 36,
              },
              {
                'nameEn': 'VR + Arcade Bundle',
                'nameAr': 'باقة الواقع الافتراضي والأركيد',
                'descriptionEn':
                    'One bundle coupon for VR entry and arcade play.',
                'descriptionAr':
                    'كوبون باقة واحدة لدخول الواقع الافتراضي مع الأركيد.',
                'adultBase': 9.0,
                'adultOriginal': 11.0,
                'capacity': 20,
              },
            ],
          },
        ],
      },
    ];

    for (final config in configs) {
      final attractionId = config['attractionId'] as String;
      final guestPricingMode = config['guestPricingMode'] as String;
      final slots = config['slots'] as List<dynamic>;

      for (var dayIndex = 0; dayIndex < dates.length; dayIndex++) {
        final date = dates[dayIndex];
        for (var slotIndex = 0; slotIndex < slots.length; slotIndex++) {
          final slot = slots[slotIndex] as Map<String, dynamic>;
          final packages = slot['packages'] as List<dynamic>;
          for (
            var packageIndex = 0;
            packageIndex < packages.length;
            packageIndex++
          ) {
            final package = packages[packageIndex] as Map<String, dynamic>;
            final soldOut =
                attractionId == 'demo_attraction_2' &&
                dayIndex == 4 &&
                slotIndex == 1 &&
                packageIndex == 2;
            final low =
                !soldOut &&
                ((dayIndex + packageIndex + slotIndex) % 4 == 0 ||
                    (attractionId == 'demo_attraction_3' &&
                        dayIndex == 3 &&
                        packageIndex == 1));
            final splitPricing =
                guestPricingMode == guestPricingModeAdultsChildren;

            final capacityAdult = splitPricing
                ? package['capacityAdult'] as int
                : package['capacity'] as int;
            final capacityChild = splitPricing
                ? package['capacityChild'] as int
                : 0;
            final bookedAdult = soldOut
                ? capacityAdult
                : low
                ? capacityAdult - 2
                : 2 + ((dayIndex + packageIndex) % 5);
            final bookedChild = splitPricing
                ? soldOut
                      ? capacityChild
                      : low
                      ? capacityChild - 1
                      : 1 + ((dayIndex + slotIndex) % 4)
                : 0;

            batch.set(
              firestore
                  .collection('offers')
                  .doc(
                    _offerId(
                      attractionId,
                      date,
                      slot['start'] as String,
                      suffix: 'pkg_${slotIndex}_$packageIndex',
                    ),
                  ),
              {
                ..._offerSeedFields(
                  restaurantId: attractionId,
                  date: date,
                  startTime: slot['start'] as String,
                  endTime: slot['end'] as String,
                  priceAdult:
                      (package['adultBase'] as double) + (dayIndex * 0.25),
                  priceAdultOriginal:
                      (package['adultOriginal'] as double) + (dayIndex * 0.25),
                  priceChild: splitPricing
                      ? (package['childBase'] as double) + (dayIndex * 0.25)
                      : 0,
                  capacityAdult: capacityAdult,
                  capacityChild: capacityChild,
                  bookedAdult: bookedAdult,
                  bookedChild: bookedChild,
                  status: soldOut
                      ? 'sold_out'
                      : low
                      ? 'low'
                      : 'active',
                  titleEn: package['nameEn'] as String,
                  titleAr: package['nameAr'] as String,
                  packageNameEn: package['nameEn'] as String,
                  packageNameAr: package['nameAr'] as String,
                  packageDescriptionEn: package['descriptionEn'] as String,
                  packageDescriptionAr: package['descriptionAr'] as String,
                  bookingCategory: 'attraction',
                  bookableType: 'attraction',
                  guestPricingMode: guestPricingMode,
                  entryConditionsEn: guestPricingMode == guestPricingModeCoupon
                      ? [
                          'Valid for one visit only.',
                          'Cannot be split across multiple visits.',
                        ]
                      : [
                          'Present your confirmation before entering the venue.',
                          'Package access applies only during the selected slot.',
                        ],
                  entryConditionsAr: guestPricingMode == guestPricingModeCoupon
                      ? [
                          'صالح لزيارة واحدة فقط.',
                          'لا يمكن تقسيمه على عدة زيارات.',
                        ]
                      : [
                          'يجب إبراز التأكيد قبل دخول المكان.',
                          'الدخول صالح فقط خلال الفترة الزمنية المختارة.',
                        ],
                ),
              },
            );
          }
        }
      }
    }
  }

  static void _seedUsers(WriteBatch batch, FirebaseFirestore firestore) {
    final users = [
      {
        'id': 'demo_user_1',
        'fullName': 'Noor Al Balushi',
        'email': 'noor@example.com',
        'phone': '+968 9000 0001',
        'role': 'guest',
      },
      {
        'id': 'demo_user_2',
        'fullName': 'Ahmed Al Hinai',
        'email': 'ahmed@example.com',
        'phone': '+968 9000 0002',
        'role': 'guest',
      },
      {
        'id': 'demo_user_3',
        'fullName': 'Fatma Al Riyami',
        'email': 'fatma@example.com',
        'phone': '+968 9000 0003',
        'role': 'guest',
      },
      {
        'id': 'demo_user_4',
        'fullName': 'Saeed Al Lawati',
        'email': 'saeed@example.com',
        'phone': '+968 9000 0004',
        'role': 'guest',
      },
    ];

    for (final user in users) {
      batch.set(firestore.collection('users').doc(user['id'] as String), {
        ...user,
        ..._seedMetaFields(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  static void _seedBookings(
    WriteBatch batch,
    FirebaseFirestore firestore,
    List<DateTime> dates,
  ) {
    final bookings = [
      _bookingSeed(
        id: 'demo_booking_1',
        userId: 'demo_user_1',
        venueId: 'demo_restaurant_1',
        venueName: 'Saffron Court',
        coverImageUrl:
            'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?auto=format&fit=crop&w=1200&q=80',
        date: dates[0],
        offerId: _offerId(
          'demo_restaurant_1',
          dates[0],
          '13:00',
          suffix: 'buffet_lunch',
        ),
        startTime: '13:00',
        endTime: '15:30',
        adults: 2,
        children: 1,
        unitPriceAdult: 11.0,
        unitPriceChild: 6.0,
        offerTitle: 'Lunch Buffet',
        bookingCategory: 'buffet',
        bookableType: 'restaurant',
        guestPricingMode: guestPricingModeAdultsChildren,
      ),
      _bookingSeed(
        id: 'demo_booking_2',
        userId: 'demo_user_2',
        venueId: 'demo_restaurant_3',
        venueName: 'Harbor Majlis',
        coverImageUrl:
            'https://images.unsplash.com/photo-1521017432531-fbd92d768814?auto=format&fit=crop&w=1200&q=80',
        date: dates[1],
        offerId: _offerId(
          'demo_restaurant_3',
          dates[1],
          '19:30',
          suffix: 'set_dinner',
        ),
        startTime: '19:30',
        endTime: '22:00',
        adults: 3,
        children: 0,
        unitPriceAdult: 12.75,
        unitPriceChild: 0,
        offerTitle: 'Dinner Set Menu',
        bookingCategory: 'set_menu',
        bookableType: 'restaurant',
        guestPricingMode: guestPricingModePerson,
      ),
      _bookingSeed(
        id: 'demo_booking_3',
        userId: 'demo_user_3',
        venueId: 'demo_restaurant_2',
        venueName: 'Broast District',
        coverImageUrl:
            'https://images.unsplash.com/photo-1421622548261-c45bfe178854?auto=format&fit=crop&w=1200&q=80',
        date: dates[2],
        offerId: _offerId(
          'demo_restaurant_2',
          dates[2],
          '11:00',
          suffix: 'combo_1',
        ),
        startTime: '11:00',
        endTime: '23:00',
        adults: 2,
        children: 0,
        unitPriceAdult: 9.75,
        unitPriceChild: 0,
        offerTitle: 'Family Crunch Combo',
        bookingCategory: 'combo',
        bookableType: 'restaurant',
        guestPricingMode: guestPricingModePerson,
      ),
      _bookingSeed(
        id: 'demo_booking_4',
        userId: 'demo_user_4',
        venueId: 'demo_attraction_1',
        venueName: 'Wadi Adventure Park',
        coverImageUrl:
            'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=1200&q=80',
        date: dates[1],
        offerId: _offerId(
          'demo_attraction_1',
          dates[1],
          '10:00',
          suffix: 'pkg_0_0',
        ),
        startTime: '10:00',
        endTime: '14:00',
        adults: 2,
        children: 1,
        unitPriceAdult: 7.75,
        unitPriceChild: 4.25,
        offerTitle: 'Explorer Pass',
        bookingCategory: 'attraction',
        bookableType: 'attraction',
        guestPricingMode: guestPricingModeAdultsChildren,
      ),
      _bookingSeed(
        id: 'demo_booking_5',
        userId: 'demo_user_1',
        venueId: 'demo_attraction_2',
        venueName: 'Sunset Marina Cruise',
        coverImageUrl:
            'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=1200&q=80',
        date: dates[3],
        offerId: _offerId(
          'demo_attraction_2',
          dates[3],
          '20:00',
          suffix: 'pkg_1_1',
        ),
        startTime: '20:00',
        endTime: '21:30',
        adults: 4,
        children: 0,
        unitPriceAdult: 12.75,
        unitPriceChild: 0,
        offerTitle: 'Dinner Cruise',
        bookingCategory: 'attraction',
        bookableType: 'attraction',
        guestPricingMode: guestPricingModePerson,
      ),
      _bookingSeed(
        id: 'demo_booking_6',
        userId: 'demo_user_2',
        venueId: 'demo_attraction_3',
        venueName: 'Arcade Galaxy',
        coverImageUrl:
            'https://images.unsplash.com/photo-1511512578047-dfb367046420?auto=format&fit=crop&w=1200&q=80',
        date: dates[2],
        offerId: _offerId(
          'demo_attraction_3',
          dates[2],
          '12:00',
          suffix: 'pkg_0_0',
        ),
        startTime: '12:00',
        endTime: '23:00',
        adults: 2,
        children: 0,
        unitPriceAdult: 3.5,
        unitPriceChild: 0,
        offerTitle: '10 Games Coupon',
        bookingCategory: 'attraction',
        bookableType: 'attraction',
        guestPricingMode: guestPricingModeCoupon,
      ),
    ];

    for (final booking in bookings) {
      final bookingId = booking['id'] as String;
      final subtotal =
          (booking['unitPriceAdult'] as double) * (booking['adults'] as int) +
          (booking['unitPriceChild'] as double) * (booking['children'] as int);
      final tax = subtotal * 0.05;
      final total = subtotal + tax;

      batch.set(firestore.collection('bookings').doc(bookingId), {
        ...booking,
        ..._seedMetaFields(),
        'currency': 'OMR',
        'subtotal': subtotal,
        'tax': tax,
        'discount': 0.0,
        'total': total,
        'status': 'paid',
        'qrPayload': 'BOOKING:${booking['bookingCode']}',
        'createdAt': FieldValue.serverTimestamp(),
        'paidAt': FieldValue.serverTimestamp(),
      });

      batch.set(firestore.collection('payments').doc('pay_$bookingId'), {
        'bookingId': bookingId,
        'amount': total,
        'status': 'success',
        'method': 'card',
        ..._seedMetaFields(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  static List<Map<String, dynamic>> _restaurantDocs() {
    return [
      _restaurantDoc(
        id: 'demo_restaurant_1',
        nameEn: 'Saffron Court',
        nameAr: 'بلاط الزعفران',
        cityEn: 'Muscat',
        cityAr: 'مسقط',
        areaEn: 'Qurum',
        areaAr: 'القرم',
        aboutEn: 'Buffet and set menu venue with polished all-day service.',
        aboutAr:
            'مطعم يجمع بين البوفيه والقائمة الثابتة بخدمة أنيقة طوال اليوم.',
        addressEn: 'Qurum Beach Road, Muscat',
        addressAr: 'طريق شاطئ القرم، مسقط',
        phone: '+968 9000 1010',
        rating: 4.7,
        reviewsCount: 214,
        lat: 23.6139,
        lng: 58.4103,
        openFrom: '08:00',
        openTo: '23:00',
        coverImageUrl:
            'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?auto=format&fit=crop&w=1200&q=80',
        highlightsEn: ['Open buffet counters', 'Set menu dining', 'Terrace'],
        highlightsAr: ['محطات بوفيه مفتوحة', 'قوائم ثابتة', 'تراس'],
        inclusionsEn: ['Welcome drink', 'Dessert station'],
        inclusionsAr: ['مشروب ترحيبي', 'ركن حلويات'],
        exclusionsEn: ['Valet service'],
        exclusionsAr: ['خدمة صف السيارات'],
        cancellationEn: ['Free cancellation up to 4 hours before booking.'],
        cancellationAr: ['إلغاء مجاني حتى 4 ساعات قبل موعد الحجز.'],
        knowBeforeEn: ['Smart casual dress code.'],
        knowBeforeAr: ['اللباس الذكي غير الرسمي مناسب.'],
        badgeEn: 'Chef favorite',
        badgeAr: 'اختيار الشيف',
        priceFromValue: 8.0,
        discountValue: 6.5,
        slotsLeft: 9,
        supportedCategories: ['buffet', 'set_menu'],
        buffet: _restaurantCategoryData(
          descriptionEn:
              'Flexible buffet windows for breakfast, lunch, and dinner.',
          descriptionAr: 'فترات بوفيه مرنة للإفطار والغداء والعشاء.',
          highlightsEn: ['Live carving', 'Daily meal windows'],
          highlightsAr: ['محطة تقطيع', 'فترات يومية متنوعة'],
          includedEn: ['Buffet access', 'Soft drinks'],
          includedAr: ['دخول البوفيه', 'مشروبات غازية'],
          notesEn: ['Dinner slots move faster on weekends.'],
          notesAr: ['مواعيد العشاء تنفد أسرع في نهاية الأسبوع.'],
          availableMealsEn: ['Breakfast', 'Lunch', 'Dinner'],
          availableMealsAr: ['إفطار', 'غداء', 'عشاء'],
          badgeEn: '20% off',
          badgeAr: 'خصم 20%',
          priceFromValue: 10.0,
          discountValue: 8.0,
          slotsLeft: 9,
        ),
        setMenu: _restaurantCategoryData(
          descriptionEn:
              'Fixed per-person menu with item choice after booking.',
          descriptionAr: 'قائمة ثابتة بسعر للشخص مع اختيار الأصناف بعد الحجز.',
          highlightsEn: ['Per-person pricing', 'Curated meals'],
          highlightsAr: ['تسعير حسب الشخص', 'وجبات مختارة'],
          includedEn: ['Starter, main, dessert'],
          includedAr: ['مقبلات وطبق رئيسي وحلى'],
          notesEn: ['Dish selection is completed after booking.'],
          notesAr: ['اختيار الأطباق يتم بعد الحجز.'],
          availableMealsEn: [
            'Breakfast Set Menu',
            'Lunch Set Menu',
            'Dinner Set Menu',
          ],
          availableMealsAr: [
            'قائمة إفطار ثابتة',
            'قائمة غداء ثابتة',
            'قائمة عشاء ثابتة',
          ],
          requiresItemSelection: true,
          badgeEn: 'Fixed price',
          badgeAr: 'سعر ثابت',
          priceFromValue: 8.0,
          discountValue: 6.5,
          slotsLeft: 6,
        ),
      ),
      _restaurantDoc(
        id: 'demo_restaurant_2',
        nameEn: 'Broast District',
        nameAr: 'حي البروست',
        cityEn: 'Muscat',
        cityAr: 'مسقط',
        areaEn: 'Al Khuwair',
        areaAr: 'الخوير',
        aboutEn: 'Casual venue for buffet rushes and quantity-based combos.',
        aboutAr: 'وجهة سريعة للبوفيه وطلبات الكومبو حسب الكمية.',
        addressEn: 'Al Khuwair Main Street, Muscat',
        addressAr: 'الشارع الرئيسي بالخوير، مسقط',
        phone: '+968 9000 2020',
        rating: 4.3,
        reviewsCount: 148,
        lat: 23.5859,
        lng: 58.4078,
        openFrom: '08:00',
        openTo: '23:30',
        coverImageUrl:
            'https://images.unsplash.com/photo-1421622548261-c45bfe178854?auto=format&fit=crop&w=1200&q=80',
        highlightsEn: ['Quick service', 'Combo ordering', 'Family seating'],
        highlightsAr: ['خدمة سريعة', 'طلبات كومبو', 'جلسات عائلية'],
        inclusionsEn: ['Sauce station'],
        inclusionsAr: ['ركن صلصات'],
        exclusionsEn: ['Table reservation guarantee'],
        exclusionsAr: ['ضمان حجز الطاولة'],
        cancellationEn: ['No refund after order confirmation.'],
        cancellationAr: ['لا يوجد استرجاع بعد تأكيد الطلب.'],
        knowBeforeEn: ['Peak times are usually after 7 PM.'],
        knowBeforeAr: ['فترة الذروة غالبًا بعد الساعة 7 مساءً.'],
        badgeEn: 'Popular',
        badgeAr: 'الأكثر طلبًا',
        priceFromValue: 5.5,
        discountValue: 4.5,
        slotsLeft: 12,
        supportedCategories: ['buffet', 'combo'],
        buffet: _restaurantCategoryData(
          descriptionEn: 'Simple buffet windows with strong lunch demand.',
          descriptionAr: 'فترات بوفيه بسيطة مع طلب قوي وقت الغداء.',
          highlightsEn: ['Affordable pricing', 'Fast turnover'],
          highlightsAr: ['تسعير مناسب', 'دوران سريع'],
          includedEn: ['Buffet access'],
          includedAr: ['دخول البوفيه'],
          availableMealsEn: ['Breakfast', 'Lunch', 'Dinner'],
          availableMealsAr: ['إفطار', 'غداء', 'عشاء'],
          badgeEn: 'Hot deal',
          badgeAr: 'عرض قوي',
          priceFromValue: 8.5,
          discountValue: 7.0,
          slotsLeft: 10,
        ),
        combo: _restaurantCategoryData(
          descriptionEn: 'Fixed-price combos designed for quantity ordering.',
          descriptionAr: 'كومبوهات بسعر ثابت ومصممة للطلب حسب الكمية.',
          highlightsEn: ['Ready boxes', 'One quantity = one combo'],
          highlightsAr: ['صناديق جاهزة', 'كل كمية = كومبو واحد'],
          includedEn: ['Combo package'],
          includedAr: ['باقة كومبو'],
          notesEn: ['Works well for takeaway and quick dine-in.'],
          notesAr: ['مناسب للسفري والطلبات السريعة.'],
          availableCombosEn: [
            'Broasted Box',
            'Family Crunch Combo',
            'Late Night Snack Combo',
          ],
          availableCombosAr: [
            'بوكس بروست',
            'كومبو العائلة المقرمش',
            'كومبو سناك آخر الليل',
          ],
          badgeEn: 'Combo ready',
          badgeAr: 'كومبو جاهز',
          priceFromValue: 5.5,
          discountValue: 4.5,
          slotsLeft: 12,
        ),
      ),
      _restaurantDoc(
        id: 'demo_restaurant_3',
        nameEn: 'Harbor Majlis',
        nameAr: 'مجلس الميناء',
        cityEn: 'Sohar',
        cityAr: 'صحار',
        areaEn: 'Corniche',
        areaAr: 'الكورنيش',
        aboutEn: 'Sea-facing venue that supports buffet, set menu, and combo.',
        aboutAr: 'وجهة بحرية تدعم البوفيه والقائمة الثابتة والكومبو.',
        addressEn: 'Corniche Road, Sohar',
        addressAr: 'طريق الكورنيش، صحار',
        phone: '+968 9000 3030',
        rating: 4.8,
        reviewsCount: 267,
        lat: 24.3474,
        lng: 56.7294,
        openFrom: '08:00',
        openTo: '23:30',
        coverImageUrl:
            'https://images.unsplash.com/photo-1521017432531-fbd92d768814?auto=format&fit=crop&w=1200&q=80',
        highlightsEn: ['Sea view', 'Premium dinner', 'Multiple modes'],
        highlightsAr: ['إطلالة بحرية', 'عشاء مميز', 'أنماط متعددة'],
        inclusionsEn: ['Welcome water'],
        inclusionsAr: ['مياه ترحيبية'],
        exclusionsEn: ['Special event nights'],
        exclusionsAr: ['ليالي الفعاليات الخاصة'],
        cancellationEn: ['Free cancellation up to 6 hours before booking.'],
        cancellationAr: ['إلغاء مجاني حتى 6 ساعات قبل موعد الحجز.'],
        knowBeforeEn: ['Dinner demand can sell out earlier.'],
        knowBeforeAr: ['قد تنفد مواعيد العشاء أبكر من غيرها.'],
        badgeEn: 'Top rated',
        badgeAr: 'الأعلى تقييمًا',
        priceFromValue: 6.0,
        discountValue: 5.0,
        slotsLeft: 7,
        supportedCategories: ['buffet', 'set_menu', 'combo'],
        buffet: _restaurantCategoryData(
          descriptionEn: 'Premium buffet windows with stronger evening demand.',
          descriptionAr: 'فترات بوفيه مميزة مع طلب أقوى مساءً.',
          highlightsEn: ['Sea seating', 'Expanded dinner counters'],
          highlightsAr: ['جلسات بحرية', 'محطات عشاء أوسع'],
          includedEn: ['Buffet access', 'Dessert tasting'],
          includedAr: ['دخول البوفيه', 'تذوق حلويات'],
          availableMealsEn: ['Breakfast', 'Lunch', 'Dinner'],
          availableMealsAr: ['إفطار', 'غداء', 'عشاء'],
          badgeEn: 'Premium',
          badgeAr: 'مميز',
          priceFromValue: 10.5,
          discountValue: 9.0,
          slotsLeft: 7,
        ),
        setMenu: _restaurantCategoryData(
          descriptionEn:
              'Structured set menu periods with one price per guest.',
          descriptionAr: 'فترات قائمة ثابتة منظمة بسعر موحد لكل شخص.',
          highlightsEn: ['Curated courses', 'Guest pricing'],
          highlightsAr: ['أطباق مختارة', 'تسعير حسب الشخص'],
          includedEn: ['Starter, main, dessert'],
          includedAr: ['مقبلات وطبق رئيسي وحلى'],
          availableMealsEn: [
            'Breakfast Set Menu',
            'Lunch Set Menu',
            'Dinner Set Menu',
          ],
          availableMealsAr: [
            'قائمة إفطار ثابتة',
            'قائمة غداء ثابتة',
            'قائمة عشاء ثابتة',
          ],
          requiresItemSelection: true,
          badgeEn: 'Curated',
          badgeAr: 'مختارة',
          priceFromValue: 8.5,
          discountValue: 7.0,
          slotsLeft: 5,
        ),
        combo: _restaurantCategoryData(
          descriptionEn: 'Ready-to-order combos for lunch, sharing, or sweets.',
          descriptionAr: 'كومبوهات جاهزة للغداء أو المشاركة أو التحلية.',
          highlightsEn: ['Quantity ordering', 'Different combo tiers'],
          highlightsAr: ['طلب حسب الكمية', 'مستويات متعددة'],
          includedEn: ['Combo pack'],
          includedAr: ['باقة كومبو'],
          availableCombosEn: [
            'Majlis Lunch Combo',
            'Sea View Sharing Box',
            'Dessert & Coffee Duo',
          ],
          availableCombosAr: [
            'كومبو غداء المجلس',
            'بوكس المشاركة بإطلالة بحرية',
            'ثنائي القهوة والحلى',
          ],
          badgeEn: 'Best value',
          badgeAr: 'أفضل قيمة',
          priceFromValue: 6.0,
          discountValue: 5.0,
          slotsLeft: 8,
        ),
      ),
    ];
  }

  static List<Map<String, dynamic>> _attractionDocs() {
    return [
      _attractionDoc(
        id: 'demo_attraction_1',
        nameEn: 'Wadi Adventure Park',
        nameAr: 'منتزه وادي المغامرات',
        cityEn: 'Muscat',
        cityAr: 'مسقط',
        areaEn: 'Seeb',
        areaAr: 'السيب',
        aboutEn:
            'Family attraction with split adult and child package pricing.',
        aboutAr: 'وجهة عائلية بتسعير منفصل للبالغين والأطفال داخل الباقات.',
        addressEn: 'Seeb Waterfront, Muscat',
        addressAr: 'واجهة السيب، مسقط',
        phone: '+968 9000 5050',
        rating: 4.6,
        reviewsCount: 301,
        coverImageUrl:
            'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=1200&q=80',
        highlightsEn: ['Timed entry', 'Family zones', 'Adventure activities'],
        highlightsAr: ['دخول بوقت محدد', 'مناطق عائلية', 'أنشطة مغامرات'],
        inclusionsEn: ['Park access'],
        inclusionsAr: ['دخول المنتزه'],
        badgeEn: 'Family day out',
        badgeAr: 'طلعة عائلية',
        priceFromValue: 9.0,
        discountValue: 7.5,
        slotsLeft: 14,
        bookingCatalog: _attractionCatalogData(
          descriptionEn: 'Pick a slot first, then choose the matching package.',
          descriptionAr: 'اختر الفترة أولًا ثم الباقة المناسبة لها.',
          highlightsEn: ['Adult + child pricing', 'More than one package'],
          highlightsAr: ['تسعير بالغ + طفل', 'أكثر من باقة'],
          includedEn: ['Entry access', 'Family zones'],
          includedAr: ['دخول', 'مناطق عائلية'],
          packageOverviewEn: [
            'Explorer Pass for standard entry.',
            'Family Splash Pass for wider coverage.',
          ],
          packageOverviewAr: [
            'تذكرة المستكشف للدخول العادي.',
            'تذكرة المرح العائلية لتغطية أوسع.',
          ],
          notesEn: ['Some packages have fewer child spots than adult spots.'],
          notesAr: ['بعض الباقات سعة الأطفال فيها أقل من سعة البالغين.'],
          badgeEn: 'Split pricing',
          badgeAr: 'تسعير منفصل',
          priceFromValue: 9.0,
          discountValue: 7.5,
          slotsLeft: 14,
        ),
      ),
      _attractionDoc(
        id: 'demo_attraction_2',
        nameEn: 'Sunset Marina Cruise',
        nameAr: 'رحلة غروب المارينا',
        cityEn: 'Muscat',
        cityAr: 'مسقط',
        areaEn: 'Muttrah',
        areaAr: 'مطرح',
        aboutEn: 'Timed cruise attraction with per-person package pricing.',
        aboutAr: 'رحلة بحرية بوقت محدد مع تسعير حسب الشخص الواحد.',
        addressEn: 'Muttrah Marina Gate, Muscat',
        addressAr: 'بوابة مارينا مطرح، مسقط',
        phone: '+968 9000 6060',
        rating: 4.5,
        reviewsCount: 187,
        coverImageUrl:
            'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=1200&q=80',
        highlightsEn: ['Two sailings', 'Per-person packages', 'Premium tiers'],
        highlightsAr: ['فترتا إبحار', 'باقات حسب الشخص', 'فئات مميزة'],
        inclusionsEn: ['Boarding access'],
        inclusionsAr: ['دخول الرحلة'],
        badgeEn: 'Evening favorite',
        badgeAr: 'مفضل مسائي',
        priceFromValue: 7.5,
        discountValue: 6.0,
        slotsLeft: 8,
        bookingCatalog: _attractionCatalogData(
          descriptionEn:
              'Choose your sailing, then compare the packages there.',
          descriptionAr: 'اختر الرحلة ثم قارن الباقات المتاحة عليها.',
          highlightsEn: ['Per-person pricing', 'Different package tiers'],
          highlightsAr: ['تسعير حسب الشخص', 'مستويات باقات مختلفة'],
          includedEn: ['Cruise access', 'Marina boarding'],
          includedAr: ['دخول الرحلة', 'الصعود من المارينا'],
          packageOverviewEn: [
            'Classic Cruise for shared boarding.',
            'Dinner Cruise for table seating.',
            'Upper Deck Lounge for premium views.',
          ],
          packageOverviewAr: [
            'الرحلة الكلاسيكية للصعود المشترك.',
            'رحلة العشاء للجلسات على الطاولة.',
            'صالة السطح العلوي للإطلالات المميزة.',
          ],
          notesEn: ['Premium packages can sell out faster at night.'],
          notesAr: ['قد تنفد الباقات المميزة أسرع في الليل.'],
          badgeEn: 'Per person',
          badgeAr: 'حسب الشخص',
          priceFromValue: 7.5,
          discountValue: 6.0,
          slotsLeft: 8,
        ),
      ),
      _attractionDoc(
        id: 'demo_attraction_3',
        nameEn: 'Arcade Galaxy',
        nameAr: 'مجرة الألعاب',
        cityEn: 'Muscat',
        cityAr: 'مسقط',
        areaEn: 'Mall of Oman',
        areaAr: 'مول عمان',
        aboutEn: 'Indoor arcade with coupon bundles instead of guest count.',
        aboutAr: 'صالة ألعاب داخلية تعتمد على باقات كوبونات بدل عدد الضيوف.',
        addressEn: 'Mall of Oman, Muscat',
        addressAr: 'مول عمان، مسقط',
        phone: '+968 9000 7070',
        rating: 4.4,
        reviewsCount: 224,
        coverImageUrl:
            'https://images.unsplash.com/photo-1511512578047-dfb367046420?auto=format&fit=crop&w=1200&q=80',
        highlightsEn: ['Coupon mode', 'Arcade + VR bundles', 'All-day access'],
        highlightsAr: ['وضع الكوبون', 'باقات أركيد وVR', 'دخول طوال اليوم'],
        inclusionsEn: ['Coupon packs'],
        inclusionsAr: ['باقات كوبونات'],
        badgeEn: 'Coupon mode',
        badgeAr: 'وضع الكوبون',
        priceFromValue: 4.0,
        discountValue: 3.0,
        slotsLeft: 20,
        bookingCatalog: _attractionCatalogData(
          descriptionEn:
              'Book coupons as units, then redeem them in the arcade.',
          descriptionAr: 'احجز الكوبونات كوحدات ثم استخدمها داخل الصالة.',
          highlightsEn: ['Supports coupon pricing', '10 or 25 games packs'],
          highlightsAr: ['يدعم التسعير بالكوبونات', 'باقات 10 أو 25 لعبة'],
          includedEn: ['Coupon credits'],
          includedAr: ['أرصدة كوبونات'],
          packageOverviewEn: [
            '10 Games Coupon for light visits.',
            '25 Games Coupon for regular players.',
            'VR + Arcade Bundle for mixed play.',
          ],
          packageOverviewAr: [
            'كوبون 10 ألعاب للزيارات الخفيفة.',
            'كوبون 25 لعبة للاعبين المتكررين.',
            'باقة الواقع الافتراضي والأركيد للعب المتنوع.',
          ],
          notesEn: ['Coupons are units, not adults or children.'],
          notesAr: ['الكوبونات وحدات وليست بالغين أو أطفال.'],
          badgeEn: 'Coupons',
          badgeAr: 'كوبونات',
          priceFromValue: 4.0,
          discountValue: 3.0,
          slotsLeft: 20,
        ),
      ),
    ];
  }

  static Map<String, dynamic> _restaurantDoc({
    required String id,
    required String nameEn,
    required String nameAr,
    required String cityEn,
    required String cityAr,
    required String areaEn,
    required String areaAr,
    required String aboutEn,
    required String aboutAr,
    required String addressEn,
    required String addressAr,
    required String phone,
    required double rating,
    required int reviewsCount,
    required double lat,
    required double lng,
    required String openFrom,
    required String openTo,
    required String coverImageUrl,
    required List<String> highlightsEn,
    required List<String> highlightsAr,
    required List<String> inclusionsEn,
    required List<String> inclusionsAr,
    required List<String> exclusionsEn,
    required List<String> exclusionsAr,
    required List<String> cancellationEn,
    required List<String> cancellationAr,
    required List<String> knowBeforeEn,
    required List<String> knowBeforeAr,
    required String badgeEn,
    required String badgeAr,
    required double priceFromValue,
    required double discountValue,
    required int slotsLeft,
    required List<String> supportedCategories,
    Map<String, dynamic>? buffet,
    Map<String, dynamic>? setMenu,
    Map<String, dynamic>? combo,
  }) {
    return {
      'id': id,
      ..._textPair('name', nameEn, nameAr),
      ..._textPair('cityId', cityEn, cityAr),
      ..._textPair('area', areaEn, areaAr),
      ..._textPair('about', aboutEn, aboutAr),
      ..._textPair('address', addressEn, addressAr),
      ..._listPair('highlights', highlightsEn, highlightsAr),
      ..._listPair('inclusions', inclusionsEn, inclusionsAr),
      ..._listPair('exclusions', exclusionsEn, exclusionsAr),
      ..._listPair('cancellationPolicy', cancellationEn, cancellationAr),
      ..._listPair('knowBeforeYouGo', knowBeforeEn, knowBeforeAr),
      'phone': phone,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'coverImageUrl': coverImageUrl,
      'geo': {'lat': lat, 'lng': lng},
      'openHours': {'from': openFrom, 'to': openTo},
      ..._catalogLabels(
        badgeEn: badgeEn,
        badgeAr: badgeAr,
        priceFromValue: priceFromValue,
        discountValue: discountValue,
        slotsLeft: slotsLeft,
      ),
      'priceFromValue': priceFromValue,
      'discountValue': discountValue,
      'isActive': true,
      'bookingCatalog': {
        'supportedCategories': supportedCategories,
        if (buffet != null) 'buffet': buffet,
        if (setMenu != null) 'setMenu': setMenu,
        if (combo != null) 'combo': combo,
      },
    };
  }

  static Map<String, dynamic> _attractionDoc({
    required String id,
    required String nameEn,
    required String nameAr,
    required String cityEn,
    required String cityAr,
    required String areaEn,
    required String areaAr,
    required String aboutEn,
    required String aboutAr,
    required String addressEn,
    required String addressAr,
    required String phone,
    required double rating,
    required int reviewsCount,
    required String coverImageUrl,
    required List<String> highlightsEn,
    required List<String> highlightsAr,
    required List<String> inclusionsEn,
    required List<String> inclusionsAr,
    required String badgeEn,
    required String badgeAr,
    required double priceFromValue,
    required double discountValue,
    required int slotsLeft,
    required Map<String, dynamic> bookingCatalog,
  }) {
    return {
      'id': id,
      ..._textPair('name', nameEn, nameAr),
      ..._textPair('cityId', cityEn, cityAr),
      ..._textPair('area', areaEn, areaAr),
      ..._textPair('about', aboutEn, aboutAr),
      ..._textPair('address', addressEn, addressAr),
      ..._listPair('highlights', highlightsEn, highlightsAr),
      ..._listPair('inclusions', inclusionsEn, inclusionsAr),
      'phone': phone,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'coverImageUrl': coverImageUrl,
      ..._catalogLabels(
        badgeEn: badgeEn,
        badgeAr: badgeAr,
        priceFromValue: priceFromValue,
        discountValue: discountValue,
        slotsLeft: slotsLeft,
      ),
      'isActive': true,
      'bookingCatalog': bookingCatalog,
    };
  }

  static Map<String, dynamic> _restaurantCategoryData({
    required String descriptionEn,
    required String descriptionAr,
    required List<String> highlightsEn,
    required List<String> highlightsAr,
    required List<String> includedEn,
    required List<String> includedAr,
    List<String> notesEn = const [],
    List<String> notesAr = const [],
    List<String> availableMealsEn = const [],
    List<String> availableMealsAr = const [],
    List<String> availableCombosEn = const [],
    List<String> availableCombosAr = const [],
    bool requiresItemSelection = false,
    String badgeEn = '',
    String badgeAr = '',
    required double priceFromValue,
    required double discountValue,
    required int slotsLeft,
  }) {
    return {
      ..._textPair('description', descriptionEn, descriptionAr),
      ..._listPair('highlights', highlightsEn, highlightsAr),
      ..._listPair('included', includedEn, includedAr),
      ..._listPair('notes', notesEn, notesAr),
      if (availableMealsEn.isNotEmpty) 'availableMeals': availableMealsEn,
      if (availableMealsAr.isNotEmpty) 'availableMealsAr': availableMealsAr,
      if (availableCombosEn.isNotEmpty) 'availableCombos': availableCombosEn,
      if (availableCombosAr.isNotEmpty) 'availableCombosAr': availableCombosAr,
      if (requiresItemSelection) 'requiresItemSelection': true,
      ..._catalogLabels(
        badgeEn: badgeEn,
        badgeAr: badgeAr,
        priceFromValue: priceFromValue,
        discountValue: discountValue,
        slotsLeft: slotsLeft,
      ),
    };
  }

  static Map<String, dynamic> _attractionCatalogData({
    required String descriptionEn,
    required String descriptionAr,
    required List<String> highlightsEn,
    required List<String> highlightsAr,
    required List<String> includedEn,
    required List<String> includedAr,
    required List<String> packageOverviewEn,
    required List<String> packageOverviewAr,
    required List<String> notesEn,
    required List<String> notesAr,
    required String badgeEn,
    required String badgeAr,
    required double priceFromValue,
    required double discountValue,
    required int slotsLeft,
  }) {
    return {
      ..._textPair('description', descriptionEn, descriptionAr),
      ..._listPair('highlights', highlightsEn, highlightsAr),
      ..._listPair('included', includedEn, includedAr),
      ..._listPair('packageOverview', packageOverviewEn, packageOverviewAr),
      ..._listPair('notes', notesEn, notesAr),
      ..._catalogLabels(
        badgeEn: badgeEn,
        badgeAr: badgeAr,
        priceFromValue: priceFromValue,
        discountValue: discountValue,
        slotsLeft: slotsLeft,
      ),
    };
  }

  static Map<String, dynamic> _offerSeedFields({
    required String restaurantId,
    required DateTime date,
    required String startTime,
    required String endTime,
    required double priceAdult,
    required double priceAdultOriginal,
    required double priceChild,
    required int capacityAdult,
    required int capacityChild,
    required int bookedAdult,
    required int bookedChild,
    required String status,
    required String titleEn,
    required String titleAr,
    required String bookingCategory,
    required String bookableType,
    required String guestPricingMode,
    String mealType = '',
    String packageNameEn = '',
    String packageNameAr = '',
    String packageDescriptionEn = '',
    String packageDescriptionAr = '',
    List<String> entryConditionsEn = const [],
    List<String> entryConditionsAr = const [],
  }) {
    return {
      'restaurantId': restaurantId,
      'date': AppDateUtils.formatDate(date),
      'startTime': startTime,
      'endTime': endTime,
      'currency': 'OMR',
      'priceAdult': priceAdult,
      'priceAdultOriginal': priceAdultOriginal,
      'priceChild': priceChild,
      'time': startTime,
      'price': _moneyEn(priceAdult),
      'status': status,
      'capacityAdult': capacityAdult,
      'capacityChild': capacityChild,
      'bookedAdult': bookedAdult,
      'bookedChild': bookedChild,
      ..._textPair('title', titleEn, titleAr),
      ..._textPair('packageName', packageNameEn, packageNameAr),
      ..._textPair(
        'packageDescription',
        packageDescriptionEn,
        packageDescriptionAr,
      ),
      ..._listPair('entryConditions', entryConditionsEn, entryConditionsAr),
      'bookingCategory': bookingCategory,
      'bookableType': bookableType,
      'guestPricingMode': guestPricingMode,
      'mealType': mealType,
      ..._seedMetaFields(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static Map<String, dynamic> _bookingSeed({
    required String id,
    required String userId,
    required String venueId,
    required String venueName,
    required String coverImageUrl,
    required DateTime date,
    required String offerId,
    required String startTime,
    required String endTime,
    required int adults,
    required int children,
    required double unitPriceAdult,
    required double unitPriceChild,
    required String offerTitle,
    required String bookingCategory,
    required String bookableType,
    required String guestPricingMode,
  }) {
    return {
      'id': id,
      'userId': userId,
      'restaurantId': venueId,
      'offerId': offerId,
      'date': AppDateUtils.formatDate(date),
      'startTime': startTime,
      'endTime': endTime,
      'adults': adults,
      'children': children,
      'unitPriceAdult': unitPriceAdult,
      'unitPriceChild': unitPriceChild,
      'bookingCode': 'BKG_${id.toUpperCase()}',
      'restaurantNameSnapshot': venueName,
      'offerTitleSnapshot': offerTitle,
      'bookingCategory': bookingCategory,
      'bookableType': bookableType,
      'guestPricingMode': guestPricingMode,
      'coverImageUrlSnapshot': coverImageUrl,
    };
  }

  static Map<String, dynamic> _catalogLabels({
    required String badgeEn,
    required String badgeAr,
    required double priceFromValue,
    required double discountValue,
    required int slotsLeft,
  }) {
    return {
      ..._textPair('badge', badgeEn, badgeAr),
      ..._textPair(
        'priceFrom',
        'From ${_moneyEn(priceFromValue)}',
        'ابتداءً من ${_moneyAr(priceFromValue)}',
      ),
      ..._textPair(
        'discount',
        _moneyEn(discountValue),
        _moneyAr(discountValue),
      ),
      ..._textPair(
        'slotsLeft',
        '$slotsLeft spots left',
        '$slotsLeft أماكن متبقية',
      ),
    };
  }

  static Map<String, dynamic> _seedMetaFields() {
    return {'isDemoSeed': true, 'seedVersion': _seedVersion};
  }

  static Map<String, dynamic> _textPair(
    String key,
    String english,
    String arabic,
  ) {
    return {key: english.trim(), '${key}Ar': arabic.trim()};
  }

  static Map<String, dynamic> _listPair(
    String key,
    List<String> english,
    List<String> arabic,
  ) {
    return {
      key: english
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList(),
      '${key}Ar': arabic
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList(),
    };
  }

  static String _moneyEn(double amount) => 'OMR ${amount.toStringAsFixed(1)}';

  static String _moneyAr(double amount) => '${amount.toStringAsFixed(1)} ر.ع';

  static String _offerId(
    String restaurantId,
    DateTime date,
    String startTime, {
    String? suffix,
  }) {
    final safeTime = startTime.replaceAll(':', '');
    final safeSuffix = (suffix ?? '').trim();
    final suffixPart = safeSuffix.isEmpty ? '' : '_$safeSuffix';
    return 'offer_${restaurantId}_${AppDateUtils.formatDate(date)}_$safeTime$suffixPart';
  }
}
