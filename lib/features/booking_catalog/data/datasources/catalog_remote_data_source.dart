import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/number_utils.dart';
import '../../../../core/utils/payment_amount_utils.dart';
import '../../domain/entities/catalog_category_type.dart';
import '../models/catalog_item_model.dart';

class CatalogRemoteDataSource {
  CatalogRemoteDataSource(this.firestore);

  final FirebaseFirestore firestore;

  Stream<void> watchCatalogChanges() {
    late final StreamController<void> controller;
    late final StreamSubscription<QuerySnapshot<Map<String, dynamic>>>
    restaurantsSubscription;
    late final StreamSubscription<QuerySnapshot<Map<String, dynamic>>>
    attractionsSubscription;
    late final StreamSubscription<QuerySnapshot<Map<String, dynamic>>>
    offersSubscription;

    controller = StreamController<void>(
      onListen: () {
        void emitChange(QuerySnapshot<Map<String, dynamic>> _) {
          if (!controller.isClosed) {
            controller.add(null);
          }
        }

        restaurantsSubscription = firestore
            .collection('restaurants')
            .snapshots()
            .skip(1)
            .listen(emitChange, onError: (_, _) {});
        attractionsSubscription = firestore
            .collection('attractions')
            .snapshots()
            .skip(1)
            .listen(emitChange, onError: (_, _) {});
        offersSubscription = firestore
            .collection('offers')
            .snapshots()
            .skip(1)
            .listen(emitChange, onError: (_, _) {});
      },
      onCancel: () async {
        await restaurantsSubscription.cancel();
        await attractionsSubscription.cancel();
        await offersSubscription.cancel();
      },
    );

    return controller.stream;
  }

  Future<List<CatalogItemModel>> getItems(CatalogCategoryType category) async {
    final offersByVenue = await _loadUpcomingOffers();
    switch (category) {
      case CatalogCategoryType.buffet:
      case CatalogCategoryType.setMenu:
      case CatalogCategoryType.combo:
        return _getRestaurantItems(category, offersByVenue);
      case CatalogCategoryType.attraction:
        return _getAttractionItems(offersByVenue);
    }
  }

  Future<List<CatalogItemModel>> _getRestaurantItems(
    CatalogCategoryType category,
    Map<String, List<Map<String, dynamic>>> offersByVenue,
  ) async {
    final snapshot = await firestore
        .collection('restaurants')
        .where('isActive', isEqualTo: true)
        .get();

    final items = <CatalogItemModel>[];
    for (final doc in snapshot.docs) {
      final data = doc.data();
      if (!_supportsRestaurantCategory(data, category)) {
        final matchingOffers = offersByVenue[doc.id] ?? const [];
        if (!_hasMatchingOffer(matchingOffers, category)) {
          continue;
        }
      }
      final labels = _buildLabels(
        data: data,
        offers: offersByVenue[doc.id] ?? const [],
        category: category,
      );
      items.add(
        CatalogItemModel.fromRestaurantDoc(
          doc: doc,
          category: category,
          labels: labels,
        ),
      );
    }

    _sortByHighestDiscount(items);
    return items;
  }

  Future<List<CatalogItemModel>> _getAttractionItems(
    Map<String, List<Map<String, dynamic>>> offersByVenue,
  ) async {
    final snapshot = await firestore
        .collection('attractions')
        .where('isActive', isEqualTo: true)
        .get();

    final items = snapshot.docs
        .map(
          (doc) => CatalogItemModel.fromAttractionDoc(
            doc: doc,
            labels: _buildLabels(
              data: doc.data(),
              offers: offersByVenue[doc.id] ?? const [],
              category: CatalogCategoryType.attraction,
            ),
          ),
        )
        .toList();

    _sortByHighestDiscount(items);
    return items;
  }

  void _sortByHighestDiscount(List<CatalogItemModel> items) {
    items.sort((left, right) {
      final discountCompare = _discountScore(
        right,
      ).compareTo(_discountScore(left));
      if (discountCompare != 0) return discountCompare;
      final ratingCompare = right.rating.compareTo(left.rating);
      if (ratingCompare != 0) return ratingCompare;
      return left.name.compareTo(right.name);
    });
  }

  double _discountScore(CatalogItemModel item) {
    if (item.slotsLeft.trim() == AppStrings.noOffersTodayExploreOtherDates) {
      return 0;
    }

    final badgePercent = _extractPercent(item.badge);
    if (badgePercent > 0) return badgePercent;

    final original = NumberUtils.parseNumber(item.priceFrom);
    final current = NumberUtils.parseNumber(item.discount);
    if (original > 0 && current > 0 && original >= current) {
      return ((original - current) / original) * 100;
    }
    return 0;
  }

  double _extractPercent(String value) {
    final percentIndex = value.indexOf('%');
    if (percentIndex < 0) return 0;

    final prefix = value.substring(0, percentIndex);
    final buffer = StringBuffer();
    for (final rune in prefix.runes) {
      final isDigit = (rune >= 48 && rune <= 57) || rune == 46;
      if (isDigit) {
        buffer.writeCharCode(rune);
      }
    }
    return double.tryParse(buffer.toString()) ?? 0;
  }

  Future<Map<String, List<Map<String, dynamic>>>> _loadUpcomingOffers() async {
    final now = DateTime.now();
    final start = AppDateUtils.formatDate(now);
    final end = AppDateUtils.formatDate(now.add(const Duration(days: 30)));

    QuerySnapshot<Map<String, dynamic>> snapshot;
    try {
      snapshot = await firestore
          .collection('offers')
          .where('date', isGreaterThanOrEqualTo: start)
          .where('date', isLessThanOrEqualTo: end)
          .orderBy('date')
          .get();
    } catch (_) {
      snapshot = await firestore.collection('offers').get();
    }

    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final venueId = (data['restaurantId'] as String? ?? '').trim();
      if (venueId.isEmpty) continue;
      grouped.putIfAbsent(venueId, () => <Map<String, dynamic>>[]).add(data);
    }
    return grouped;
  }

  bool _supportsRestaurantCategory(
    Map<String, dynamic> data,
    CatalogCategoryType category,
  ) {
    final bookingCatalog = _asMap(data['bookingCatalog']);
    final supported = _normalizedStringList(
      bookingCatalog['supportedCategories'],
    );

    if (category == CatalogCategoryType.buffet) {
      if (supported.isEmpty) return true;
      return supported.contains('buffet');
    }

    if (category == CatalogCategoryType.setMenu) {
      final setMenuConfig = _asMap(bookingCatalog['setMenu']);
      if (supported.contains('set_menu') || supported.contains('setmenu')) {
        return true;
      }
      if (setMenuConfig.isNotEmpty) {
        return setMenuConfig['enabled'] as bool? ?? true;
      }
      return false;
    }

    final comboConfig = _asMap(bookingCatalog['combo']);
    if (supported.contains('combo')) {
      return true;
    }
    if (comboConfig.isNotEmpty) {
      return comboConfig['enabled'] as bool? ?? true;
    }
    return false;
  }

  bool _hasMatchingOffer(
    List<Map<String, dynamic>> offers,
    CatalogCategoryType category,
  ) {
    for (final offer in offers) {
      if (_matchesCategory(offer, category)) {
        return true;
      }
    }
    return false;
  }

  CatalogListLabels _buildLabels({
    required Map<String, dynamic> data,
    required List<Map<String, dynamic>> offers,
    required CatalogCategoryType category,
  }) {
    final today = AppDateUtils.formatDate(DateTime.now());
    final matchingOffers = offers
        .where((offer) => _matchesCategory(offer, category))
        .toList();
    final todayOffers = matchingOffers
        .where((offer) => (offer['date'] as String? ?? '').trim() == today)
        .toList();

    var remainingTotal = 0;
    final candidates = <_CatalogOfferCandidate>[];

    for (final offer in todayOffers) {
      final status = (offer['status'] as String? ?? 'active')
          .toLowerCase()
          .replaceAll(' ', '');
      if (_isOfferExpired(offer)) {
        continue;
      }
      final remainingAdult =
          NumberUtils.toInt(offer['capacityAdult']) -
          NumberUtils.toInt(offer['bookedAdult']);
      final remainingChild =
          NumberUtils.toInt(offer['capacityChild']) -
          NumberUtils.toInt(offer['bookedChild']);
      remainingTotal += (remainingAdult + remainingChild).clamp(0, 1000000);

      if (status == 'soldout' || status == 'sold_out') {
        continue;
      }

      final currentPrice = NumberUtils.toDouble(offer['priceAdult']);
      if (currentPrice <= 0) continue;

      final originalRaw = NumberUtils.toDouble(offer['priceAdultOriginal']);
      final originalPrice = originalRaw > currentPrice
          ? originalRaw
          : currentPrice;
      final discountPercent = originalPrice > currentPrice
          ? ((originalPrice - currentPrice) / originalPrice) * 100
          : 0.0;
      final currency = (offer['currency'] as String? ?? '').trim();

      candidates.add(
        _CatalogOfferCandidate(
          currentPrice: currentPrice,
          originalPrice: originalPrice,
          discountPercent: discountPercent,
          currency: currency,
        ),
      );
    }

    final hasAvailableTodayOffers = candidates.isNotEmpty;
    if (!hasAvailableTodayOffers) {
      return CatalogListLabels(
        badge: '',
        priceFrom: '',
        discount: '',
        slotsLeft: AppStrings.noOffersTodayExploreOtherDates,
        overrideStoredValues: true,
      );
    }

    candidates.sort((left, right) {
      final discountCompare = right.discountPercent.compareTo(
        left.discountPercent,
      );
      if (discountCompare != 0) return discountCompare;
      final currentCompare = left.currentPrice.compareTo(right.currentPrice);
      if (currentCompare != 0) return currentCompare;
      return left.originalPrice.compareTo(right.originalPrice);
    });
    final selected = candidates.first;

    final currencyLabel = displayCurrencyLabel(
      selected.currency.isNotEmpty
          ? selected.currency
          : currencyFromFormattedLabel(data['priceFrom']) ??
                currencyFromFormattedLabel(data['discount']) ??
                '',
    );
    final prefix = currencyLabel.isEmpty ? '' : '$currencyLabel ';
    final hasDiscount = selected.discountPercent > 0;
    final priceFrom = hasDiscount
        ? AppStrings.fromPrice('$prefix${selected.originalPrice.toStringAsFixed(1)}')
        : AppStrings.fromPrice('$prefix${selected.currentPrice.toStringAsFixed(1)}');
    final discount = hasDiscount
        ? '$prefix${selected.currentPrice.toStringAsFixed(1)}'
        : '';
    final badge = hasDiscount
        ? AppStrings.percentOff(selected.discountPercent.round())
        : '';
    final slotsLeft = remainingTotal > 0
        ? AppStrings.slotsLeftCount(remainingTotal)
        : '';

    return CatalogListLabels(
      badge: badge,
      priceFrom: priceFrom,
      discount: discount,
      slotsLeft: slotsLeft,
      overrideStoredValues: true,
    );
  }

  bool _matchesCategory(
    Map<String, dynamic> offer,
    CatalogCategoryType category,
  ) {
    final raw = (offer['bookingCategory'] as String? ?? '')
        .trim()
        .toLowerCase()
        .replaceAll(' ', '_');
    if (category == CatalogCategoryType.buffet) {
      return raw.isEmpty || raw == 'buffet';
    }
    if (category == CatalogCategoryType.setMenu) {
      return raw == 'set_menu' || raw == 'setmenu';
    }
    if (category == CatalogCategoryType.combo) {
      return raw == 'combo';
    }
    final type = (offer['bookableType'] as String? ?? '').trim().toLowerCase();
    return raw == 'attraction' || type == 'attraction';
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, item) => MapEntry(key.toString(), item));
    }
    return const <String, dynamic>{};
  }

  static List<String> _normalizedStringList(dynamic value) {
    if (value is! List) return const [];
    return value
        .map(
          (item) => item.toString().trim().toLowerCase().replaceAll(' ', '_'),
        )
        .where((item) => item.isNotEmpty)
        .toList();
  }

  bool _isOfferExpired(Map<String, dynamic> offer) {
    final date = DateTime.tryParse((offer['date'] as String? ?? '').trim());
    if (date == null) return false;

    final now = DateTime.now();
    final offerDate = DateTime(date.year, date.month, date.day);
    final startMinutes = _parseTimeToMinutes(
      (offer['startTime'] as String? ?? '').trim(),
    );
    final endMinutes =
        _parseTimeToMinutes((offer['endTime'] as String? ?? '').trim()) ??
        startMinutes;

    if (endMinutes != null) {
      var endDateTime = offerDate.add(Duration(minutes: endMinutes));
      if (startMinutes != null && endMinutes <= startMinutes) {
        endDateTime = endDateTime.add(const Duration(days: 1));
      }
      return !now.isBefore(endDateTime);
    }

    final today = DateTime(now.year, now.month, now.day);
    return offerDate.isBefore(today);
  }

  int? _parseTimeToMinutes(String value) {
    final trimmed = value.trim().toLowerCase();
    if (trimmed.isEmpty) return null;

    String? suffix;
    if (trimmed.endsWith('am')) {
      suffix = 'am';
    } else if (trimmed.endsWith('pm')) {
      suffix = 'pm';
    }

    if (suffix != null) {
      final timePart = trimmed
          .substring(0, trimmed.length - suffix.length)
          .trim();
      final pieces = timePart.split(':');
      final hour = int.tryParse(pieces.isEmpty ? '' : pieces[0]);
      final minute = pieces.length > 1 ? int.tryParse(pieces[1]) ?? 0 : 0;
      if (hour == null) return null;
      var normalizedHour = hour % 12;
      if (suffix == 'pm') normalizedHour += 12;
      return normalizedHour * 60 + minute;
    }

    final pieces = trimmed.split(':');
    if (pieces.length != 2) return null;
    final hour = int.tryParse(pieces[0]);
    final minute = int.tryParse(pieces[1]);
    if (hour == null || minute == null) return null;
    return hour * 60 + minute;
  }
}

class _CatalogOfferCandidate {
  const _CatalogOfferCandidate({
    required this.currentPrice,
    required this.originalPrice,
    required this.discountPercent,
    required this.currency,
  });

  final double currentPrice;
  final double originalPrice;
  final double discountPercent;
  final String currency;
}
