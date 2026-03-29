import 'package:equatable/equatable.dart';

class AttractionEntity extends Equatable {
  const AttractionEntity({
    required this.id,
    required this.name,
    required this.cityId,
    required this.area,
    required this.rating,
    required this.reviewsCount,
    required this.coverImageUrl,
    required this.about,
    required this.phone,
    required this.address,
    required this.highlights,
    required this.inclusions,
    required this.catalogDescription,
    required this.catalogHighlights,
    required this.catalogIncluded,
    required this.packageOverview,
    required this.bookingNotes,
    required this.isActive,
    required this.createdAt,
    this.badge = '',
    this.priceFrom = '',
    this.discount = '',
    this.slotsLeft = '',
  });

  final String id;
  final String name;
  final String cityId;
  final String area;
  final double rating;
  final int reviewsCount;
  final String coverImageUrl;
  final String about;
  final String phone;
  final String address;
  final List<String> highlights;
  final List<String> inclusions;
  final String catalogDescription;
  final List<String> catalogHighlights;
  final List<String> catalogIncluded;
  final List<String> packageOverview;
  final List<String> bookingNotes;
  final bool isActive;
  final DateTime createdAt;
  final String badge;
  final String priceFrom;
  final String discount;
  final String slotsLeft;

  @override
  List<Object?> get props => [
    id,
    name,
    cityId,
    area,
    rating,
    reviewsCount,
    coverImageUrl,
    about,
    phone,
    address,
    highlights,
    inclusions,
    catalogDescription,
    catalogHighlights,
    catalogIncluded,
    packageOverview,
    bookingNotes,
    isActive,
    createdAt,
    badge,
    priceFrom,
    discount,
    slotsLeft,
  ];
}
