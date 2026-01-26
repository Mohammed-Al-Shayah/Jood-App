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
    return RestaurantModel(
      id: id,
      name: data['name'] as String? ?? '',
      badge: data['badge'] as String? ?? '',
      priceFrom: data['priceFrom'] as String? ?? '',
      discount: data['discount'] as String? ?? '',
      meta: data['meta'] as String? ?? '',
      slotsLeft: data['slotsLeft'] as String? ?? '',
      rating: data['rating'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
    );
  }
}
