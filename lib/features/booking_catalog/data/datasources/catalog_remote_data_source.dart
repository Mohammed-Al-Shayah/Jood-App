import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/number_utils.dart';
import '../../domain/entities/catalog_category_type.dart';
import '../models/catalog_item_model.dart';

class CatalogRemoteDataSource {
  CatalogRemoteDataSource(this.firestore);

  final FirebaseFirestore firestore;

  Future<List<CatalogItemModel>> getItems(CatalogCategoryType category) async {
    final offersByVenue = await _loadUpcomingOffers();
    switch (category) {
      case CatalogCategoryType.buffet:
      case CatalogCategoryType.setMenu:
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
        continue;
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

    items.sort((a, b) => a.name.compareTo(b.name));
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

    items.sort((a, b) => a.name.compareTo(b.name));
    return items;
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
    final supported = _normalizedStringList(bookingCatalog['supportedCategories']);

    if (category == CatalogCategoryType.buffet) {
      if (supported.isEmpty) return true;
      return supported.contains('buffet');
    }

    final setMenuConfig = _asMap(bookingCatalog['setMenu']);
    if (supported.contains('set_menu') || supported.contains('setmenu')) {
      return true;
    }
    if (setMenuConfig.isNotEmpty) {
      return setMenuConfig['enabled'] as bool? ?? true;
    }
    return false;
  }

  CatalogListLabels _buildLabels({
    required Map<String, dynamic> data,
    required List<Map<String, dynamic>> offers,
    required CatalogCategoryType category,
  }) {
    final matchingOffers = offers
        .where((offer) => _matchesCategory(offer, category))
        .toList();

    var minPrice = double.infinity;
    var minOriginalPrice = double.infinity;
    var remainingTotal = 0;
    var currency = '';

    for (final offer in matchingOffers) {
      final status = (offer['status'] as String? ?? 'active')
          .toLowerCase()
          .replaceAll(' ', '');
      final priceAdult = NumberUtils.toDouble(offer['priceAdult']);
      final originalAdult = NumberUtils.toDouble(offer['priceAdultOriginal']);
      if (status != 'soldout' && status != 'sold_out') {
        if (priceAdult > 0 && priceAdult < minPrice) {
          minPrice = priceAdult;
          currency = (offer['currency'] as String? ?? '').trim();
        }
        if (originalAdult > 0 && originalAdult < minOriginalPrice) {
          minOriginalPrice = originalAdult;
        }
      }
      final remainingAdult =
          NumberUtils.toInt(offer['capacityAdult']) -
          NumberUtils.toInt(offer['bookedAdult']);
      final remainingChild =
          NumberUtils.toInt(offer['capacityChild']) -
          NumberUtils.toInt(offer['bookedChild']);
      remainingTotal += (remainingAdult + remainingChild).clamp(0, 1000000);
    }

    final labelPriceFrom = NumberUtils.parseNumber(data['priceFrom']);
    final labelDiscount = NumberUtils.parseNumber(data['discount']);
    final resolvedOriginal = minOriginalPrice.isFinite
        ? minOriginalPrice
        : _max(labelPriceFrom, labelDiscount);
    final resolvedCurrent = minPrice.isFinite
        ? minPrice
        : _min(labelPriceFrom, labelDiscount);

    final currencyLabel =
        currency.isNotEmpty ? currency : _currencyFromLabel(data['priceFrom']);
    final prefix = currencyLabel == null || currencyLabel.isEmpty
        ? ''
        : '$currencyLabel ';
    final priceFrom = resolvedOriginal > 0
        ? 'From ${prefix}${resolvedOriginal.toStringAsFixed(2)}'
        : _stringValue(data['priceFrom']).trim();
    final discount = resolvedCurrent > 0 && resolvedCurrent < resolvedOriginal
        ? '$prefix${resolvedCurrent.toStringAsFixed(2)}'
        : _stringValue(data['discount']).trim();
    final badge = _resolveBadge(
      data: data,
      originalPrice: resolvedOriginal,
      currentPrice: resolvedCurrent,
    );
    final slotsLeft = remainingTotal > 0
        ? '$remainingTotal slots left'
        : _stringValue(data['slotsLeft']).trim();

    return CatalogListLabels(
      badge: badge,
      priceFrom: priceFrom,
      discount: discount,
      slotsLeft: slotsLeft,
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
    final type = (offer['bookableType'] as String? ?? '')
        .trim()
        .toLowerCase();
    return raw == 'attraction' || type == 'attraction';
  }

  String _resolveBadge({
    required Map<String, dynamic> data,
    required double originalPrice,
    required double currentPrice,
  }) {
    final existing = _stringValue(data['badge']).trim();
    if (existing.isNotEmpty) return existing;
    if (originalPrice > 0 && currentPrice > 0 && originalPrice > currentPrice) {
      final percent = ((originalPrice - currentPrice) / originalPrice) * 100;
      return '${percent.round()}% off';
    }
    final rating = NumberUtils.toDouble(data['rating']);
    if (rating >= 4.5) return 'Top rated';
    if (rating >= 4.0) return 'Popular';
    return '';
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
        .map((item) => item.toString().trim().toLowerCase().replaceAll(' ', '_'))
        .where((item) => item.isNotEmpty)
        .toList();
  }

  static String? _currencyFromLabel(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    if (text.isEmpty) return null;
    final match = RegExp(r'([A-Za-z]{2,})').firstMatch(text);
    return match?.group(1);
  }

  static String _stringValue(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  static double _min(double a, double b) {
    if (a <= 0) return b;
    if (b <= 0) return a;
    return a < b ? a : b;
  }

  static double _max(double a, double b) {
    return a > b ? a : b;
  }
}
