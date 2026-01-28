import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/restaurant_model.dart';

abstract class RestaurantRemoteDataSource {
  Future<List<RestaurantModel>> fetchRestaurants();
}

class RestaurantRemoteDataSourceImpl implements RestaurantRemoteDataSource {
  RestaurantRemoteDataSourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  @override
  Future<List<RestaurantModel>> fetchRestaurants() async {
    final snapshot = await _firestore.collection('restaurants').get();
    final today = _formatDate(DateTime.now());
    final offersSnapshot = await _firestore
        .collection('offers')
        .where('date', isEqualTo: today)
        .get();
    final offersByRestaurant = <String, List<Map<String, dynamic>>>{};
    for (final doc in offersSnapshot.docs) {
      final data = doc.data();
      final restaurantId = data['restaurantId'] as String?;
      if (restaurantId == null || restaurantId.isEmpty) continue;
      offersByRestaurant.putIfAbsent(restaurantId, () => []).add(data);
    }
    final results = <RestaurantModel>[];

    for (final doc in snapshot.docs) {
      final data = Map<String, dynamic>.from(doc.data());
      final offers = offersByRestaurant[doc.id] ?? const <Map<String, dynamic>>[];

      var minPrice = double.infinity;
      var remainingTotal = 0;
      var currency = '';

      for (final offer in offers) {
        final status = (offer['status'] as String? ?? 'active')
            .toLowerCase()
            .replaceAll(' ', '');
        if (status == 'soldout' || status == 'sold_out') continue;
        final priceAdult = _toDouble(offer['priceAdult']);
        if (priceAdult > 0 && priceAdult < minPrice) {
          minPrice = priceAdult;
          currency = offer['currency'] as String? ?? currency;
        }
        final remainingAdult = _toInt(offer['capacityAdult']) - _toInt(offer['bookedAdult']);
        final remainingChild = _toInt(offer['capacityChild']) - _toInt(offer['bookedChild']);
        remainingTotal += (remainingAdult + remainingChild);
      }

      final originalPrice = _parseNumber(data['discount']);
      final resolvedMinPrice = minPrice.isFinite ? minPrice : 0.0;
      final discountPercent = _resolveDiscountPercent(
        data: data,
        originalPrice: originalPrice,
        minPrice: resolvedMinPrice,
        preferComputed: minPrice.isFinite && originalPrice > 0,
      );
      if (minPrice.isFinite) {
        if (originalPrice > minPrice) {
          data['priceFrom'] = 'From ${currency.isEmpty ? '' : '$currency '}'
              '${originalPrice.toStringAsFixed(0)}';
          data['discount'] = '${currency.isEmpty ? '' : '$currency '}'
              '${minPrice.toStringAsFixed(0)}';
          data['slotsLeft'] = 'After discount '
              '${currency.isEmpty ? '' : '$currency '}'
              '${minPrice.toStringAsFixed(0)}';
        } else {
          data['priceFrom'] = 'From ${currency.isEmpty ? '' : '$currency '}'
              '${minPrice.toStringAsFixed(0)}';
        }
      }
      if ((data['slotsLeft'] as String?)?.isEmpty ?? true) {
        if (remainingTotal > 0) {
          data['slotsLeft'] = '$remainingTotal slots left';
        }
      }

      if (discountPercent > 0) {
        data['badge'] = '${discountPercent.round()}% off';
      }

      results.add(
        RestaurantModel.fromFirestore(
          id: doc.id,
          data: data,
        ),
      );
    }

    return results;
  }

  static String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  static double _toDouble(dynamic value) {
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return 0;
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is num) return value.toInt();
    return 0;
  }

  static double _parseNumber(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    final text = value.toString();
    final match = RegExp(r'(\d+(\.\d+)?)').firstMatch(text);
    if (match == null) return 0;
    return double.tryParse(match.group(1) ?? '') ?? 0;
  }

  static double _resolveDiscountPercent({
    required Map<String, dynamic> data,
    required double originalPrice,
    required double minPrice,
    required bool preferComputed,
  }) {
    if (preferComputed &&
        originalPrice > 0 &&
        minPrice > 0 &&
        originalPrice > minPrice) {
      return ((originalPrice - minPrice) / originalPrice) * 100;
    }

    final percentValue = _toDouble(data['discountPercent']);
    if (percentValue > 0) return percentValue;

    if (originalPrice <= 0 || minPrice <= 0 || originalPrice <= minPrice) {
      return 0;
    }
    return ((originalPrice - minPrice) / originalPrice) * 100;
  }
}
