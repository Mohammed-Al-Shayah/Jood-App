import 'package:equatable/equatable.dart';

import 'catalog_category_type.dart';

class CatalogItemEntity extends Equatable {
  const CatalogItemEntity({
    required this.id,
    required this.category,
    required this.bookingMode,
    required this.sourceCollection,
    required this.name,
    this.nameEn = '',
    this.nameAr = '',
    required this.cityId,
    this.cityIdEn = '',
    this.cityIdAr = '',
    required this.area,
    this.areaEn = '',
    this.areaAr = '',
    required this.address,
    this.addressEn = '',
    this.addressAr = '',
    required this.rating,
    required this.reviewsCount,
    required this.coverImageUrl,
    required this.description,
    this.descriptionEn = '',
    this.descriptionAr = '',
    required this.highlights,
    required this.inclusions,
    this.exclusions = const [],
    this.termsAndConditions = const [],
    this.cancellationPolicy = const [],
    required this.availableMeals,
    required this.packageOverview,
    required this.bookingNotes,
    this.location = '',
    this.locationEn = '',
    this.locationAr = '',
    this.geoLat = 0,
    this.geoLng = 0,
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
  final String nameEn;
  final String nameAr;
  final String cityId;
  final String cityIdEn;
  final String cityIdAr;
  final String area;
  final String areaEn;
  final String areaAr;
  final String address;
  final String addressEn;
  final String addressAr;
  final double rating;
  final int reviewsCount;
  final String coverImageUrl;
  final String description;
  final String descriptionEn;
  final String descriptionAr;
  final List<String> highlights;
  final List<String> inclusions;
  final List<String> exclusions;
  final List<String> termsAndConditions;
  final List<String> cancellationPolicy;
  final List<String> availableMeals;
  final List<String> packageOverview;
  final List<String> bookingNotes;
  final String location;
  final String locationEn;
  final String locationAr;
  final double geoLat;
  final double geoLng;
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
    nameEn,
    nameAr,
    cityId,
    cityIdEn,
    cityIdAr,
    area,
    areaEn,
    areaAr,
    address,
    addressEn,
    addressAr,
    rating,
    reviewsCount,
    coverImageUrl,
    description,
    descriptionEn,
    descriptionAr,
    highlights,
    inclusions,
    exclusions,
    termsAndConditions,
    cancellationPolicy,
    availableMeals,
    packageOverview,
    bookingNotes,
    location,
    locationEn,
    locationAr,
    geoLat,
    geoLng,
    requiresMenuItemSelection,
    badge,
    priceFrom,
    discount,
    slotsLeft,
    isActive,
  ];
}
