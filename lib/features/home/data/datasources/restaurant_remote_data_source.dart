import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/utils/app_strings.dart';
import '../../../restaurants/data/models/restaurant_model.dart';
import '../../../restaurants/domain/entities/restaurant_entity.dart';
import '../../../../core/utils/number_utils.dart';
import '../../../../core/utils/date_utils.dart';

abstract class RestaurantRemoteDataSource {
  Future<List<RestaurantEntity>> fetchRestaurants();
}

class RestaurantRemoteDataSourceImpl implements RestaurantRemoteDataSource {
  RestaurantRemoteDataSourceImpl({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  @override
  Future<List<RestaurantEntity>> fetchRestaurants() async {
    final snapshot = await _firestore
        .collection('restaurants')
        .where('isActive', isEqualTo: true)
        .get();
    final today = AppDateUtils.formatDate(DateTime.now());
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
      final offers =
          offersByRestaurant[doc.id] ?? const <Map<String, dynamic>>[];

      var minPrice = double.infinity;
      var minOriginalPrice = double.infinity;
      var remainingTotal = 0;
      var currency = '';

      for (final offer in offers) {
        final status = (offer['status'] as String? ?? 'active')
            .toLowerCase()
            .replaceAll(' ', '');
        if (status == 'soldout' || status == 'sold_out') continue;
        final priceAdult = NumberUtils.toDouble(offer['priceAdult']);
        if (priceAdult > 0 && priceAdult < minPrice) {
          minPrice = priceAdult;
          currency = offer['currency'] as String? ?? currency;
        }
        final originalAdult = NumberUtils.toDouble(offer['priceAdultOriginal']);
        if (originalAdult > 0 && originalAdult < minOriginalPrice) {
          minOriginalPrice = originalAdult;
          currency = offer['currency'] as String? ?? currency;
        }
        final remainingAdult =
            NumberUtils.toInt(offer['capacityAdult']) -
            NumberUtils.toInt(offer['bookedAdult']);
        final remainingChild =
            NumberUtils.toInt(offer['capacityChild']) -
            NumberUtils.toInt(offer['bookedChild']);
        remainingTotal += (remainingAdult + remainingChild);
      }

      final labelPriceFrom = NumberUtils.parseNumber(data['priceFrom']);
      final labelDiscount = NumberUtils.parseNumber(data['discount']);
      // final resolvedMinPrice = minPrice.isFinite ? minPrice : 0.0;
      final resolvedOriginal = minOriginalPrice.isFinite
          ? minOriginalPrice
          : _max(labelPriceFrom, labelDiscount);
      final resolvedCurrent = minPrice.isFinite
          ? minPrice
          : _min(labelPriceFrom, labelDiscount);
      final discountPercent = _resolveDiscountPercent(
        data: data,
        originalPrice: resolvedOriginal,
        minPrice: resolvedCurrent,
        preferComputed: resolvedCurrent > 0 && resolvedOriginal > 0,
      );
      final labelCurrency = currency.isNotEmpty
          ? currency
          : _currencyFromLabel(data['priceFrom']) ??
                _currencyFromLabel(data['discount']) ??
                '';
      if (resolvedCurrent > 0) {
        final priceLabel =
            '${labelCurrency.isEmpty ? '' : '$labelCurrency '}${resolvedCurrent.toStringAsFixed(1)}';
        data['discountValue'] = resolvedCurrent;
        if (resolvedOriginal > resolvedCurrent) {
          data['priceFrom'] = AppStrings.fromPrice(
            '${labelCurrency.isEmpty ? '' : '$labelCurrency '}${resolvedOriginal.toStringAsFixed(1)}',
          );
          data['discount'] = priceLabel;
          data['slotsLeft'] = AppStrings.afterDiscount(priceLabel);
          data['priceFromValue'] = resolvedOriginal;
        } else {
          data['priceFrom'] = AppStrings.fromPrice(
            '${labelCurrency.isEmpty ? '' : '$labelCurrency '}${resolvedCurrent.toStringAsFixed(1)}',
          );
          data['priceFromValue'] = resolvedCurrent;
        }
      }
      if ((data['slotsLeft'] as String?)?.isEmpty ?? true) {
        if (remainingTotal > 0) {
          data['slotsLeft'] = AppStrings.slotsLeftCount(remainingTotal);
        }
      }
      data['priceFromValue'] ??= NumberUtils.parseNumber(data['priceFrom']);
      data['discountValue'] ??= NumberUtils.parseNumber(data['discount']);

      if (discountPercent > 0) {
        data['badge'] = AppStrings.percentOff(discountPercent.round());
      } else {
        final ratingValue = NumberUtils.toDouble(data['rating']);
        final badgeText = (data['badge'] as String? ?? '').trim();
        if (badgeText.isEmpty) {
          if (ratingValue >= 4.5) {
            data['badge'] = AppStrings.topRated;
          } else if (ratingValue >= 4.0) {
            data['badge'] = AppStrings.popular;
          }
        } else {
          data['badge'] = _localizedBadge(badgeText);
        }
      }

      results.add(RestaurantModel.fromMap(id: doc.id, data: data));
    }

    return results;
  }

  static double _min(double a, double b) {
    if (a <= 0) return b;
    if (b <= 0) return a;
    return a < b ? a : b;
  }

  static double _max(double a, double b) {
    return a > b ? a : b;
  }

  static String? _currencyFromLabel(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    if (text.isEmpty) return null;
    final buffer = StringBuffer();
    for (final rune in text.runes) {
      final character = String.fromCharCode(rune);
      final isLetter =
          (rune >= 65 && rune <= 90) || (rune >= 97 && rune <= 122);
      if (isLetter) {
        buffer.write(character);
        continue;
      }
      if (buffer.isNotEmpty) {
        break;
      }
    }
    final result = buffer.toString();
    return result.isEmpty ? null : result;
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

    final percentValue = NumberUtils.toDouble(data['discountPercent']);
    if (percentValue > 0) return percentValue;

    if (originalPrice <= 0 || minPrice <= 0 || originalPrice <= minPrice) {
      return 0;
    }
    return ((originalPrice - minPrice) / originalPrice) * 100;
  }

  static String _localizedBadge(String badge) {
    final trimmed = badge.trim();
    if (trimmed.isEmpty) return trimmed;
    final percentIndex = trimmed.indexOf('%');
    if (percentIndex > 0) {
      final percent = int.tryParse(trimmed.substring(0, percentIndex).trim());
      if (percent != null) {
        return AppStrings.percentOff(percent);
      }
    }

    switch (trimmed.toLowerCase()) {
      case 'top rated':
        return AppStrings.topRated;
      case 'popular':
        return AppStrings.popular;
      default:
        return trimmed;
    }
  }
}
