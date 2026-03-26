import 'package:equatable/equatable.dart';

import 'catalog_category_type.dart';

class CatalogItemEntity extends Equatable {
  const CatalogItemEntity({
    required this.id,
    required this.category,
    required this.bookingMode,
    required this.sourceCollection,
    required this.name,
    required this.cityId,
    required this.area,
    required this.address,
    required this.rating,
    required this.reviewsCount,
    required this.coverImageUrl,
    required this.description,
    required this.highlights,
    required this.inclusions,
    required this.availableMeals,
    required this.packageOverview,
    required this.bookingNotes,
    required this.requiresMenuItemSelection,
    required this.badge,
    required this.priceFrom,
    required this.discount,
    required this.slotsLeft,
    required this.isActive,
  });

  final String id;
  final CatalogCategoryType category;
  final CatalogBookingMode bookingMode;
  final String sourceCollection;
  final String name;
  final String cityId;
  final String area;
  final String address;
  final double rating;
  final int reviewsCount;
  final String coverImageUrl;
  final String description;
  final List<String> highlights;
  final List<String> inclusions;
  final List<String> availableMeals;
  final List<String> packageOverview;
  final List<String> bookingNotes;
  final bool requiresMenuItemSelection;
  final String badge;
  final String priceFrom;
  final String discount;
  final String slotsLeft;
  final bool isActive;

  String get metaLabel {
    final parts = <String>[];
    if (area.trim().isNotEmpty) parts.add(area.trim());
    if (cityId.trim().isNotEmpty) parts.add(cityId.trim());
    if (parts.isNotEmpty) {
      return parts.join(' | ');
    }
    return address.trim();
  }

  String get ratingLabel {
    if (rating <= 0) return '0.0';
    return rating.toStringAsFixed(1);
  }

  @override
  List<Object?> get props => [
    id,
    category,
    bookingMode,
    sourceCollection,
    name,
    cityId,
    area,
    address,
    rating,
    reviewsCount,
    coverImageUrl,
    description,
    highlights,
    inclusions,
    availableMeals,
    packageOverview,
    bookingNotes,
    requiresMenuItemSelection,
    badge,
    priceFrom,
    discount,
    slotsLeft,
    isActive,
  ];
}
