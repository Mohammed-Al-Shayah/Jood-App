import 'package:equatable/equatable.dart';

class Restaurant extends Equatable {
  const Restaurant({
    required this.id,
    required this.name,
    required this.badge,
    required this.priceFrom,
    required this.discount,
    required this.meta,
    required this.slotsLeft,
    required this.rating,
    required this.imageUrl,
  });

  final String id;
  final String name;
  final String badge;
  final String priceFrom;
  final String discount;
  final String meta;
  final String slotsLeft;
  final String rating;
  final String imageUrl;

  @override
  List<Object?> get props => [
        id,
        name,
        badge,
        priceFrom,
        discount,
        meta,
        slotsLeft,
        rating,
        imageUrl,
      ];
}
