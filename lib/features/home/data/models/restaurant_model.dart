import '../../domain/entities/restaurant.dart';

class RestaurantModel extends Restaurant {
  const RestaurantModel({
    required super.id,
    required super.name,
    required super.badge,
    required super.priceFrom,
    required super.discount,
    required super.meta,
    required super.slotsLeft,
    required super.rating,
    required super.imageUrl,
  });

  factory RestaurantModel.fromFirestore({
    required String id,
    required Map<String, dynamic> data,
  }) {
    final imageValue = data['imageUrl'] ?? data['coverImageUrl'];
    final ratingValue = _toDouble(data['rating']);
    final area = _stringValue(data['area']);
    final cityId = _stringValue(data['cityId']);
    final metaValue = _joinMeta(area, cityId, _stringValue(data['address']));
    final badgeValue = _fallbackBadge(_stringValue(data['badge']), ratingValue);
    final openHours = data['openHours'] as Map<String, dynamic>?;
    final openFrom = _stringValue(openHours?['from']);
    final openTo = _stringValue(openHours?['to']);
    final slotsValue = _openHoursLabel(
      openFrom,
      openTo,
      _stringValue(data['slotsLeft']),
    );
    return RestaurantModel(
      id: id,
      name: _stringValue(data['name']),
      badge: badgeValue,
      priceFrom: _stringValue(data['priceFrom']),
      discount: _stringValue(data['discount']),
      meta: metaValue,
      slotsLeft: slotsValue,
      rating: _formatRating(ratingValue),
      imageUrl: _stringValue(imageValue),
    );
  }

  static String _stringValue(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  static double _toDouble(dynamic value) {
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return 0;
  }

  static String _formatRating(double rating) {
    return rating <= 0 ? '0.0' : rating.toStringAsFixed(1);
  }

  static String _joinMeta(String area, String city, String address) {
    final parts = [area, city].where((value) => value.isNotEmpty).toList();
    if (parts.isNotEmpty) {
      return parts.join(' • ');
    }
    return address;
  }

  static String _fallbackBadge(String badge, double rating) {
    if (badge.isNotEmpty) return badge;
    if (rating >= 4.5) return 'Top rated';
    if (rating >= 4.0) return 'Popular';
    return '';
  }

  static String _openHoursLabel(
    String from,
    String to,
    String fallback,
  ) {
    if (from.isNotEmpty && to.isNotEmpty) {
      return 'Open today $from - $to';
    }
    return fallback;
  }
}
