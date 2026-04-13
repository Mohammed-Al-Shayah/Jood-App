import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'date_utils.dart';
import 'guest_pricing_utils.dart';

class SeedFirestore {
  const SeedFirestore._();

  static const String _seedDocId = 'demo_v9_combo';

  static Future<void> ensureSeeded() async {
    if (!kDebugMode) return;
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
        ..._restaurantCatalogOverride(restaurant['id'] as String),
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    final attractions = [
      {
        'id': 'demo_attraction_1',
        'name': 'Desert Safari Escape',
        'cityId': 'Dubai',
        'area': 'Al Marmoom',
        'rating': 4.7,
        'reviewsCount': 312,
        'coverImageUrl':
            'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=1200&q=80',
        'about':
            'Premium desert safari with dune bashing, sunset lounge access, and live entertainment.',
        'phone': '+971 55 404 9191',
        'address': 'Al Marmoom Desert Conservation Reserve, Dubai',
        'highlights': [
          'Sunset dune drive',
          'VIP seating area',
          'Live fire and tanoura show',
        ],
        'inclusions': ['Round-trip transport', 'Dinner buffet', 'Camel ride'],
        'badge': 'Best seller',
        'priceFrom': 'From OMR 38',
        'discount': 'OMR 31',
        'slotsLeft': '18 slots left',
        'isActive': true,
        'bookingCatalog': {
          'description':
              'Choose your arrival time, then book the package that matches the experience you want.',
          'highlights': [
            'Shared and VIP packages',
            'Time-based availability',
            'Live camp entertainment',
          ],
          'included': [
            'Transport from Dubai',
            'Desert activities',
            'Dinner included on selected packages',
          ],
          'packageOverview': [
            'Standard Camp: shared seating and core activities.',
            'VIP Majlis: premium seating with priority service.',
            'Adventure Plus: extra activities and premium dining.',
          ],
          'notes': [
            'Children under 2 are not permitted on dune bashing.',
            'More than one package can be available for the same time slot.',
            'Packages can vary by selected time slot.',
          ],
        },
      },
      {
        'id': 'demo_attraction_2',
        'name': 'Skyline Marina Cruise',
        'cityId': 'Dubai',
        'area': 'Dubai Marina',
        'rating': 4.5,
        'reviewsCount': 185,
        'coverImageUrl':
            'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=1200&q=80',
        'about':
            'A city-light cruise through the marina with multiple boarding times and package tiers.',
        'phone': '+971 56 220 1110',
        'address': 'Marina Walk Pier 7, Dubai',
        'highlights': [
          'Indoor and upper-deck seating',
          'Sunset and night departures',
          'Dinner cruise upgrade',
        ],
        'inclusions': ['Cruise ticket', 'Welcome drink'],
        'badge': 'Evening favorite',
        'priceFrom': 'From OMR 24',
        'discount': 'OMR 19',
        'slotsLeft': '24 slots left',
        'isActive': true,
        'bookingCatalog': {
          'description':
              'Pick a departure slot first, then select the package available on that sailing.',
          'highlights': [
            'Sunset and night departures',
            'Different prices by package and time',
          ],
          'included': ['Boarding access', 'Cruise route around Marina'],
          'packageOverview': [
            'Classic Deck: standard boarding access.',
            'Window Dining: dinner seating with skyline views.',
            'Premium Upper Deck: best view with upgraded service.',
          ],
          'notes': [
            'Each sailing can include multiple package options.',
            'Some premium packages are available only on selected sailings.',
          ],
        },
      },
    ];

    for (final attraction in attractions) {
      final ref = firestore
          .collection('attractions')
          .doc(attraction['id'] as String);
      batch.set(ref, {
        ...attraction,
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

          final baseAdult = 70.0 + (rIndex * 15) + (tIndex * 8) + (dIndex * 6);
          final baseChild = baseAdult * 0.5;
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
            'price': 'OMR ${baseAdult.toStringAsFixed(1)}',
            'status': status,
            'capacityAdult': capacityAdult,
            'capacityChild': capacityChild,
            'bookedAdult': bookedAdult,
            'bookedChild': bookedChild,
            'title': time['title'],
            'bookableType': 'restaurant',
            'bookingCategory': 'buffet',
            'guestPricingMode': guestPricingModeAdultsChildren,
            'mealType': _mealTypeForBaseOfferIndex(tIndex),
            'packageName': '',
            'packageDescription': '',
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

    final brunchDays = <int>{1, 4};
    final brunchRestaurantIds = <String>{
      'demo_restaurant_1',
      'demo_restaurant_6',
    };
    for (final restaurantId in brunchRestaurantIds) {
      for (final dayIndex in brunchDays) {
        final date = dates[dayIndex];
        final offerRef = firestore
            .collection('offers')
            .doc(_offerId(restaurantId, date, '11:30', suffix: 'brunch'));
        final adultPrice = restaurantId == 'demo_restaurant_1' ? 96.0 : 72.0;
        final childPrice = restaurantId == 'demo_restaurant_1' ? 48.0 : 36.0;
        final remainingBoost = restaurantId == 'demo_restaurant_1' ? 0 : 4;
        batch.set(offerRef, {
          'restaurantId': restaurantId,
          'date': AppDateUtils.formatDate(date),
          'startTime': '11:30',
          'endTime': '14:30',
          'currency': 'OMR',
          'priceAdult': adultPrice + (dayIndex * 2),
          'priceAdultOriginal': adultPrice + 18 + (dayIndex * 2),
          'priceChild': childPrice + dayIndex,
          'time': '11:30',
          'price': 'OMR ${(adultPrice + (dayIndex * 2)).toStringAsFixed(1)}',
          'status': dayIndex == 4 ? 'low' : 'active',
          'capacityAdult': 18,
          'capacityChild': 10,
          'bookedAdult': 12 - remainingBoost,
          'bookedChild': 5,
          'title': 'Brunch',
          'bookableType': 'restaurant',
          'bookingCategory': 'buffet',
          'guestPricingMode': guestPricingModeAdultsChildren,
          'mealType': 'brunch',
          'packageName': '',
          'packageDescription': '',
          'entryConditions': [
            'Weekend brunch seating',
            'Mocktail station included',
          ],
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    }

    final setMenuRestaurants = <String, double>{
      'demo_restaurant_2': 82,
      'demo_restaurant_3': 110,
      'demo_restaurant_5': 95,
    };
    final setMenuOptions = [
      {
        'mealType': 'breakfast',
        'start': '08:30',
        'end': '10:30',
        'delta': 0.0,
        'entryConditions': [
          'Morning set menu with bakery basket and hot drink',
          'Best suited for lighter early seating',
        ],
      },
      {
        'mealType': 'lunch',
        'start': '12:30',
        'end': '14:30',
        'delta': 12.0,
        'entryConditions': [
          'Midday set menu with starter and main course selection',
          'Designed for regular lunch seating',
        ],
      },
      {
        'mealType': 'dinner',
        'start': '19:00',
        'end': '21:30',
        'delta': 24.0,
        'entryConditions': [
          'Evening set menu with expanded main course choices',
          'Dessert course is part of the dinner experience',
        ],
      },
    ];
    for (final entry in setMenuRestaurants.entries) {
      final restaurantId = entry.key;
      final basePrice = entry.value;
      for (var dayIndex = 0; dayIndex < dates.length; dayIndex++) {
        final date = dates[dayIndex];
        for (
          var optionIndex = 0;
          optionIndex < setMenuOptions.length;
          optionIndex++
        ) {
          if (restaurantId == 'demo_restaurant_5' &&
              dayIndex == 3 &&
              optionIndex == 0) {
            continue;
          }
          final option = setMenuOptions[optionIndex];
          final adultPrice = basePrice + (option['delta'] as double) + dayIndex;
          final soldOut =
              restaurantId == 'demo_restaurant_3' &&
              dayIndex == 5 &&
              option['mealType'] == 'dinner';
          final low =
              !soldOut &&
              restaurantId == 'demo_restaurant_2' &&
              dayIndex == 2 &&
              option['mealType'] == 'lunch';
          final bookedAdultsBase = soldOut
              ? 16
              : low
              ? 14
              : 4 + optionIndex;
          final bookedChildrenBase = soldOut
              ? 8
              : low
              ? 7
              : 2 + (dayIndex % 2);
          final offerRef = firestore
              .collection('offers')
              .doc(
                _offerId(
                  restaurantId,
                  date,
                  option['start'] as String,
                  suffix: 'set_${option['mealType']}',
                ),
              );
          batch.set(offerRef, {
            'restaurantId': restaurantId,
            'date': AppDateUtils.formatDate(date),
            'startTime': option['start'],
            'endTime': option['end'],
            'currency': 'OMR',
            'priceAdult': adultPrice,
            'priceAdultOriginal': adultPrice + 16,
            'priceChild': 0.0,
            'time': option['start'],
            'price': 'OMR ${adultPrice.toStringAsFixed(1)}',
            'status': soldOut
                ? 'sold_out'
                : low
                ? 'low'
                : 'active',
            'capacityAdult': 24,
            'capacityChild': 0,
            'bookedAdult': bookedAdultsBase + bookedChildrenBase,
            'bookedChild': 0,
            'title': '${_titleize(option['mealType'] as String)} Set Menu',
            'bookableType': 'restaurant',
            'bookingCategory': 'set_menu',
            'guestPricingMode': guestPricingModePerson,
            'mealType': option['mealType'],
            'packageName': '',
            'packageDescription': '',
            'entryConditions': [
              'Set menu selection required',
              'Final item choice will be completed after booking',
            ],
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }
      }
    }

    final comboRestaurants = <String, Map<String, dynamic>>{
      'demo_restaurant_4': {
        'start': '11:00',
        'end': '23:00',
        'options': [
          {
            'title': '10 pcs Broasted',
            'description':
                'Ten pieces of broasted chicken with fries, garlic sauce, and soft drinks.',
            'adultBase': 10.0,
            'adultOriginal': 12.0,
            'capacityAdult': 30,
            'bookedAdult': 6,
          },
          {
            'title': '15 pcs Broasted',
            'description':
                'Fifteen pieces of broasted chicken prepared for sharing with fries and dips.',
            'adultBase': 14.0,
            'adultOriginal': 17.0,
            'capacityAdult': 22,
            'bookedAdult': 4,
          },
          {
            'title': 'Family Combo',
            'description':
                'Family combo with mixed broasted pieces, fries, sauces, and drinks.',
            'adultBase': 22.0,
            'adultOriginal': 26.0,
            'capacityAdult': 14,
            'bookedAdult': 2,
          },
        ],
      },
      'demo_restaurant_6': {
        'start': '08:00',
        'end': '16:00',
        'options': [
          {
            'title': 'Breakfast Duo',
            'description':
                'Two breakfast plates with tea service and fresh bakery items.',
            'adultBase': 8.0,
            'adultOriginal': 10.0,
            'capacityAdult': 24,
            'bookedAdult': 5,
          },
          {
            'title': 'Heritage Breakfast Box',
            'description':
                'Traditional breakfast assortment packed as one ready-to-order combo.',
            'adultBase': 11.0,
            'adultOriginal': 13.0,
            'capacityAdult': 18,
            'bookedAdult': 3,
          },
          {
            'title': 'Tea & Sweets Combo',
            'description':
                'Arabic tea service with date cake, luqaimat, and assorted sweets.',
            'adultBase': 9.0,
            'adultOriginal': 11.0,
            'capacityAdult': 16,
            'bookedAdult': 2,
          },
        ],
      },
    };

    for (final entry in comboRestaurants.entries) {
      final restaurantId = entry.key;
      final config = entry.value;
      final startTime = config['start'] as String;
      final endTime = config['end'] as String;
      final options = config['options'] as List<dynamic>;

      for (var dayIndex = 0; dayIndex < dates.length; dayIndex++) {
        final date = dates[dayIndex];
        for (var optionIndex = 0; optionIndex < options.length; optionIndex++) {
          final option = options[optionIndex] as Map<String, dynamic>;
          final soldOut =
              restaurantId == 'demo_restaurant_6' &&
              dayIndex == 5 &&
              optionIndex == 1;
          final low =
              !soldOut &&
              restaurantId == 'demo_restaurant_4' &&
              dayIndex == 2 &&
              optionIndex == 0;
          final capacityAdult = option['capacityAdult'] as int;
          final bookedAdult = soldOut
              ? capacityAdult
              : low
              ? capacityAdult - 2
              : (option['bookedAdult'] as int) + (dayIndex % 3);
          final priceAdult = option['adultBase'] as double;
          final priceAdultOriginal = option['adultOriginal'] as double;
          final offerRef = firestore
              .collection('offers')
              .doc(
                _offerId(
                  restaurantId,
                  date,
                  startTime,
                  suffix: 'combo_$optionIndex',
                ),
              );

          batch.set(offerRef, {
            'restaurantId': restaurantId,
            'date': AppDateUtils.formatDate(date),
            'startTime': startTime,
            'endTime': endTime,
            'currency': 'OMR',
            'priceAdult': priceAdult,
            'priceAdultOriginal': priceAdultOriginal,
            'priceChild': 0.0,
            'time': startTime,
            'price': 'OMR ${priceAdult.toStringAsFixed(1)}',
            'status': soldOut
                ? 'sold_out'
                : low
                ? 'low'
                : 'active',
            'capacityAdult': capacityAdult,
            'capacityChild': 0,
            'bookedAdult': bookedAdult,
            'bookedChild': 0,
            'title': option['title'],
            'bookableType': 'restaurant',
            'bookingCategory': 'combo',
            'guestPricingMode': guestPricingModePerson,
            'mealType': '',
            'packageName': '',
            'packageDescription': option['description'],
            'entryConditions': [
              'Quantity-based combo order',
              'One unit equals one combo package',
            ],
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }
      }
    }

    final attractionSchedules = <String, List<Map<String, dynamic>>>{
      'demo_attraction_1': [
        {
          'start': '15:00',
          'end': '21:00',
          'packages': [
            {
              'name': 'Standard Camp',
              'description':
                  'Shared camp seating with dinner and core activities.',
              'adultBase': 31.0,
              'childBase': 18.0,
              'capacityAdult': 20,
              'capacityChild': 12,
            },
            {
              'name': 'VIP Majlis',
              'description': 'Private seating area with priority service.',
              'adultBase': 44.0,
              'childBase': 25.0,
              'capacityAdult': 10,
              'capacityChild': 6,
            },
            {
              'name': 'Adventure Plus',
              'description':
                  'Premium desert activities with upgraded dinner setup.',
              'adultBase': 49.0,
              'childBase': 28.0,
              'capacityAdult': 12,
              'capacityChild': 8,
            },
          ],
        },
        {
          'start': '16:30',
          'end': '22:30',
          'packages': [
            {
              'name': 'Adventure Plus',
              'description':
                  'Premium desert activities with upgraded dinner setup.',
              'adultBase': 52.0,
              'childBase': 29.0,
              'capacityAdult': 12,
              'capacityChild': 8,
            },
            {
              'name': 'VIP Majlis',
              'description': 'Private seating area with priority service.',
              'adultBase': 47.0,
              'childBase': 27.0,
              'capacityAdult': 10,
              'capacityChild': 6,
            },
            {
              'name': 'Standard Camp',
              'description':
                  'Shared camp seating with dinner and core activities.',
              'adultBase': 36.0,
              'childBase': 20.0,
              'capacityAdult': 18,
              'capacityChild': 10,
            },
          ],
        },
      ],
      'demo_attraction_2': [
        {
          'start': '17:30',
          'end': '19:00',
          'packages': [
            {
              'name': 'Classic Deck',
              'description': 'Entry-level cruise package with shared seating.',
              'adultBase': 19.0,
              'childBase': 11.0,
              'capacityAdult': 24,
              'capacityChild': 12,
            },
            {
              'name': 'Window Dining',
              'description': 'Cruise with dinner seating by the glass windows.',
              'adultBase': 29.0,
              'childBase': 17.0,
              'capacityAdult': 14,
              'capacityChild': 8,
            },
            {
              'name': 'Premium Upper Deck',
              'description':
                  'Upper-deck lounge seating with best skyline views.',
              'adultBase': 33.0,
              'childBase': 19.0,
              'capacityAdult': 10,
              'capacityChild': 6,
            },
          ],
        },
        {
          'start': '20:00',
          'end': '21:30',
          'packages': [
            {
              'name': 'Classic Deck',
              'description': 'Entry-level cruise package with shared seating.',
              'adultBase': 22.0,
              'childBase': 12.0,
              'capacityAdult': 20,
              'capacityChild': 10,
            },
            {
              'name': 'Premium Upper Deck',
              'description':
                  'Upper-deck lounge seating with best skyline views.',
              'adultBase': 35.0,
              'childBase': 20.0,
              'capacityAdult': 8,
              'capacityChild': 4,
            },
            {
              'name': 'Window Dining',
              'description': 'Cruise with dinner seating by the glass windows.',
              'adultBase': 31.0,
              'childBase': 18.0,
              'capacityAdult': 12,
              'capacityChild': 8,
            },
          ],
        },
      ],
    };

    for (final attraction in attractions) {
      final attractionId = attraction['id'] as String;
      final schedule = attractionSchedules[attractionId] ?? const [];
      for (var dayIndex = 0; dayIndex < dates.length; dayIndex++) {
        final date = dates[dayIndex];
        for (var slotIndex = 0; slotIndex < schedule.length; slotIndex++) {
          final slot = schedule[slotIndex];
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
                packageIndex == 1;
            final low =
                !soldOut &&
                attractionId == 'demo_attraction_1' &&
                dayIndex == 2 &&
                slotIndex == 0 &&
                packageIndex == 1;
            final guestPricingMode = attractionId == 'demo_attraction_1'
                ? guestPricingModePerson
                : guestPricingModeAdultsChildren;
            final usesPersonPricing =
                guestPricingMode == guestPricingModePerson;
            final adultPrice =
                (package['adultBase'] as double) + dayIndex + (slotIndex * 2);
            final childPrice = usesPersonPricing
                ? 0.0
                : (package['childBase'] as double) + (dayIndex * 0.5);
            final rawCapacityAdult = package['capacityAdult'] as int;
            final rawCapacityChild = package['capacityChild'] as int;
            final bookedAdultBase = soldOut
                ? rawCapacityAdult
                : low
                ? rawCapacityAdult - 2
                : 3 + dayIndex;
            final bookedChildBase = soldOut
                ? rawCapacityChild
                : low
                ? rawCapacityChild - 1
                : 1 + packageIndex;
            final capacityAdult = usesPersonPricing
                ? rawCapacityAdult + rawCapacityChild
                : rawCapacityAdult;
            final capacityChild = usesPersonPricing ? 0 : rawCapacityChild;
            final bookedAdult = usesPersonPricing
                ? bookedAdultBase + bookedChildBase
                : bookedAdultBase;
            final bookedChild = usesPersonPricing ? 0 : bookedChildBase;
            final offerRef = firestore
                .collection('offers')
                .doc(
                  _offerId(
                    attractionId,
                    date,
                    slot['start'] as String,
                    suffix: 'pkg_${slotIndex}_$packageIndex',
                  ),
                );
            batch.set(offerRef, {
              'restaurantId': attractionId,
              'date': AppDateUtils.formatDate(date),
              'startTime': slot['start'],
              'endTime': slot['end'],
              'currency': 'OMR',
              'priceAdult': adultPrice,
              'priceAdultOriginal': adultPrice + 7,
              'priceChild': childPrice,
              'time': slot['start'],
              'price': 'OMR ${adultPrice.toStringAsFixed(1)}',
              'status': soldOut
                  ? 'sold_out'
                  : low
                  ? 'low'
                  : 'active',
              'capacityAdult': capacityAdult,
              'capacityChild': capacityChild,
              'bookedAdult': bookedAdult,
              'bookedChild': bookedChild,
              'title': package['name'],
              'bookableType': 'attraction',
              'bookingCategory': 'attraction',
              'guestPricingMode': guestPricingMode,
              'mealType': '',
              'packageName': package['name'],
              'packageDescription': package['description'],
              'entryConditions': [
                'Present your confirmation on arrival',
                if (attractionId == 'demo_attraction_1')
                  'Transport timing depends on selected slot',
              ],
              'createdAt': FieldValue.serverTimestamp(),
              'updatedAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
          }
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
        'bookingCategory': 'buffet',
        'bookableType': 'restaurant',
        'guestPricingMode': guestPricingModeAdultsChildren,
        'offerTitleSnapshot': 'Lunch Entry',
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
        'bookingCategory': 'buffet',
        'bookableType': 'restaurant',
        'guestPricingMode': guestPricingModeAdultsChildren,
        'offerTitleSnapshot': 'Dinner Entry',
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
        'bookingCategory': 'buffet',
        'bookableType': 'restaurant',
        'guestPricingMode': guestPricingModeAdultsChildren,
        'offerTitleSnapshot': 'Breakfast Entry',
      },
      {
        'id': 'demo_booking_4',
        'userId': 'demo_user_1',
        'restaurantId': 'demo_attraction_1',
        'dateIndex': 1,
        'offerId': _offerId(
          'demo_attraction_1',
          dates[1],
          '15:00',
          suffix: 'pkg_0_1',
        ),
        'startTime': '15:00',
        'endTime': '21:00',
        'adults': 3,
        'children': 0,
        'unitPriceAdult': 45.0,
        'unitPriceChild': 0.0,
        'code': 'BKG1769509738999',
        'bookingCategory': 'attraction',
        'bookableType': 'attraction',
        'guestPricingMode': guestPricingModePerson,
        'restaurantNameSnapshot': 'Desert Safari Escape',
        'coverImageUrlSnapshot':
            'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=1200&q=80',
        'offerTitleSnapshot': 'VIP Majlis',
      },
      {
        'id': 'demo_booking_5',
        'userId': 'demo_user_2',
        'restaurantId': 'demo_restaurant_4',
        'dateIndex': 2,
        'offerId': _offerId(
          'demo_restaurant_4',
          dates[2],
          '11:00',
          suffix: 'combo_0',
        ),
        'startTime': '11:00',
        'endTime': '23:00',
        'adults': 2,
        'children': 0,
        'unitPriceAdult': 10.0,
        'unitPriceChild': 0.0,
        'code': 'BKG1769509740123',
        'bookingCategory': 'combo',
        'bookableType': 'restaurant',
        'guestPricingMode': guestPricingModePerson,
        'restaurantNameSnapshot': 'Spice Avenue',
        'offerTitleSnapshot': '10 pcs Broasted',
      },
    ];

    for (final booking in bookings) {
      final restaurantId = booking['restaurantId'] as String;
      final date = dates[booking['dateIndex'] as int];
      final timeIndex = booking['timeIndex'] as int?;
      final time = timeIndex == null ? null : times[timeIndex];
      final offerId =
          booking['offerId'] as String? ??
          _offerId(restaurantId, date, time!['start'] as String);
      final adults = booking['adults'] as int;
      final children = booking['children'] as int;
      final unitPriceAdult =
          (booking['unitPriceAdult'] as num?)?.toDouble() ??
          (100.0 + (timeIndex ?? 0) * 15);
      final unitPriceChild =
          (booking['unitPriceChild'] as num?)?.toDouble() ??
          (unitPriceAdult * 0.5);
      final subtotal = unitPriceAdult * adults + unitPriceChild * children;
      final tax = subtotal * 0.05;
      final discount = 0.0;
      final total = subtotal + tax - discount;

      final bookingRef = firestore
          .collection('bookings')
          .doc(booking['id'] as String);
      batch.set(bookingRef, {
        'userId': booking['userId'],
        'restaurantId': restaurantId,
        'offerId': offerId,
        'date': AppDateUtils.formatDate(date),
        'startTime': booking['startTime'] ?? time?['start'],
        'endTime': booking['endTime'] ?? time?['end'] ?? '',
        'adults': adults,
        'children': children,
        'currency': 'OMR',
        'unitPriceAdult': unitPriceAdult,
        'unitPriceChild': unitPriceChild,
        'subtotal': subtotal,
        'tax': tax,
        'discount': discount,
        'total': total,
        'status': 'paid',
        'bookingCode': booking['code'],
        'qrPayload': 'BOOKING:${booking['code']}',
        'restaurantNameSnapshot':
            booking['restaurantNameSnapshot'] ??
            _nameForVenueId(restaurantId, restaurants, attractions),
        'offerTitleSnapshot':
            booking['offerTitleSnapshot'] ?? time?['title'] ?? '',
        'bookingCategory': booking['bookingCategory'] ?? '',
        'bookableType': booking['bookableType'] ?? 'restaurant',
        'guestPricingMode': booking['guestPricingMode'],
        'coverImageUrlSnapshot':
            booking['coverImageUrlSnapshot'] ??
            _coverForVenueId(restaurantId, restaurants, attractions),
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

  static Map<String, dynamic> _restaurantCatalogOverride(String restaurantId) {
    switch (restaurantId) {
      case 'demo_restaurant_1':
        return {
          'bookingCatalog': {
            'supportedCategories': ['buffet'],
            'buffet': {
              'description':
                  'Seafood buffet with breakfast, lunch, dinner, and brunch on selected days.',
              'included': [
                'Live cooking stations',
                'Dessert corner',
                'Welcome drink',
              ],
              'availableMeals': ['Breakfast', 'Lunch', 'Dinner', 'Brunch'],
              'notes': ['Brunch appears only on selected dates.'],
            },
          },
        };
      case 'demo_restaurant_2':
        return {
          'bookingCatalog': {
            'supportedCategories': ['buffet', 'set_menu'],
            'buffet': {
              'description':
                  'Family-friendly buffet with lighter breakfast service and strong lunch turnover.',
              'included': ['Soft drinks', 'Family seating'],
              'availableMeals': ['Breakfast', 'Lunch', 'Dinner'],
            },
            'setMenu': {
              'description':
                  'A curated set menu with one price per guest by meal period.',
              'included': [
                'Starter, main, and dessert',
                'Set menu pricing per person',
              ],
              'notes': [
                'Guests will choose the actual dishes after this booking step.',
              ],
              'requiresItemSelection': true,
            },
          },
        };
      case 'demo_restaurant_3':
        return {
          'bookingCatalog': {
            'supportedCategories': ['buffet', 'set_menu'],
            'buffet': {
              'description':
                  'Panoramic terrace buffet with stronger evening demand and premium dinner pricing.',
              'included': ['Sea-view seating', 'Chef dessert tasting'],
              'availableMeals': ['Breakfast', 'Lunch', 'Dinner'],
            },
            'setMenu': {
              'description':
                  'Premium set menu experience with breakfast, lunch, and dinner options.',
              'included': ['Curated courses', 'Premium service lane'],
              'notes': [
                'Dinner set menu can sell out faster than the daytime options.',
              ],
              'requiresItemSelection': true,
            },
          },
        };
      case 'demo_restaurant_4':
        return {
          'bookingCatalog': {
            'supportedCategories': ['buffet', 'combo'],
            'buffet': {
              'description':
                  'Street-food buffet service with flexible lunch and dinner timings.',
              'included': ['Soft drinks', 'Free Wi-Fi'],
              'availableMeals': ['Breakfast', 'Lunch', 'Dinner'],
            },
            'combo': {
              'description':
                  'Ready-to-order restaurant combos with one fixed price per combo unit.',
              'included': [
                'Fast service combo packaging',
                'Fixed pricing per combo order',
              ],
              'availableCombos': [
                '10 pcs Broasted',
                '15 pcs Broasted',
                'Family Combo',
              ],
              'notes': [
                'Increase quantity to order more than one combo.',
                'Each combo option has its own daily availability.',
              ],
            },
          },
        };
      case 'demo_restaurant_5':
        return {
          'bookingCatalog': {
            'supportedCategories': ['buffet', 'set_menu'],
            'buffet': {
              'description':
                  'Marina-side grill buffet with open kitchen and family-friendly lunch seating.',
              'included': ['Salad bar', 'Dessert'],
              'availableMeals': ['Breakfast', 'Lunch', 'Dinner'],
            },
            'setMenu': {
              'description':
                  'Grill-driven set menu with a per-person rate that changes across breakfast, lunch, and dinner.',
              'included': ['Fixed grill menu', 'One per-person set menu rate'],
              'notes': [
                'Some breakfast set menu dates are intentionally unavailable for testing.',
              ],
              'requiresItemSelection': true,
            },
          },
        };
      case 'demo_restaurant_6':
        return {
          'bookingCatalog': {
            'supportedCategories': ['buffet', 'combo'],
            'buffet': {
              'description':
                  'Traditional brunch-focused buffet with lighter weekday operations.',
              'included': ['Tea service', 'Traditional sweets'],
              'availableMeals': ['Breakfast', 'Lunch', 'Brunch'],
              'notes': ['Brunch is available only on selected dates.'],
            },
            'combo': {
              'description':
                  'Traditional ready-made combos sold by quantity instead of guest count.',
              'included': ['Tea service', 'Freshly packed combo sets'],
              'availableCombos': [
                'Breakfast Duo',
                'Heritage Breakfast Box',
                'Tea & Sweets Combo',
              ],
              'notes': [
                'Combos are ideal for takeaway or quick dine-in service.',
              ],
            },
          },
        };
      default:
        return {
          'bookingCatalog': {
            'supportedCategories': ['buffet'],
            'buffet': {
              'description':
                  'Standard buffet configuration used for catalog testing.',
              'included': ['Main buffet access'],
              'availableMeals': ['Breakfast', 'Lunch', 'Dinner'],
            },
          },
        };
    }
  }

  static String _mealTypeForBaseOfferIndex(int index) {
    switch (index) {
      case 0:
        return 'breakfast';
      case 1:
        return 'lunch';
      default:
        return 'dinner';
    }
  }

  static String _nameForVenueId(
    String venueId,
    List<Map<String, dynamic>> restaurants,
    List<Map<String, dynamic>> attractions,
  ) {
    for (final venue in [...restaurants, ...attractions]) {
      if (venue['id'] == venueId) {
        return venue['name'] as String? ?? '';
      }
    }
    return '';
  }

  static String _coverForVenueId(
    String venueId,
    List<Map<String, dynamic>> restaurants,
    List<Map<String, dynamic>> attractions,
  ) {
    for (final venue in [...restaurants, ...attractions]) {
      if (venue['id'] == venueId) {
        return venue['coverImageUrl'] as String? ?? '';
      }
    }
    return '';
  }

  static String _titleize(String value) {
    if (value.isEmpty) return value;
    final parts = value.split('_');
    return parts
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }

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
