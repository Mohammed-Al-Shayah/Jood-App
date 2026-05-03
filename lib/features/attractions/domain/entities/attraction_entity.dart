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
    this.geoLat = 23.588,
    this.geoLng = 58.3829,
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
    this.nameEn = '',
    this.nameAr = '',
    this.cityIdEn = '',
    this.cityIdAr = '',
    this.areaEn = '',
    this.areaAr = '',
    this.aboutEn = '',
    this.aboutAr = '',
    this.addressEn = '',
    this.addressAr = '',
    this.highlightsEn = const [],
    this.highlightsAr = const [],
    this.inclusionsEn = const [],
    this.inclusionsAr = const [],
    this.catalogDescriptionEn = '',
    this.catalogDescriptionAr = '',
    this.catalogHighlightsEn = const [],
    this.catalogHighlightsAr = const [],
    this.catalogIncludedEn = const [],
    this.catalogIncludedAr = const [],
    this.packageOverviewEn = const [],
    this.packageOverviewAr = const [],
    this.bookingNotesEn = const [],
    this.bookingNotesAr = const [],
    this.catalogExcluded = const [],
    this.catalogTermsAndConditions = const [],
    this.catalogCancellationPolicy = const [],
    this.catalogAvailableOptions = const [],
    this.catalogLocation = '',
    this.catalogExcludedEn = const [],
    this.catalogExcludedAr = const [],
    this.catalogTermsAndConditionsEn = const [],
    this.catalogTermsAndConditionsAr = const [],
    this.catalogCancellationPolicyEn = const [],
    this.catalogCancellationPolicyAr = const [],
    this.catalogAvailableOptionsEn = const [],
    this.catalogAvailableOptionsAr = const [],
    this.catalogLocationEn = '',
    this.catalogLocationAr = '',
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
  final double geoLat;
  final double geoLng;
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
  final String nameEn;
  final String nameAr;
  final String cityIdEn;
  final String cityIdAr;
  final String areaEn;
  final String areaAr;
  final String aboutEn;
  final String aboutAr;
  final String addressEn;
  final String addressAr;
  final List<String> highlightsEn;
  final List<String> highlightsAr;
  final List<String> inclusionsEn;
  final List<String> inclusionsAr;
  final String catalogDescriptionEn;
  final String catalogDescriptionAr;
  final List<String> catalogHighlightsEn;
  final List<String> catalogHighlightsAr;
  final List<String> catalogIncludedEn;
  final List<String> catalogIncludedAr;
  final List<String> packageOverviewEn;
  final List<String> packageOverviewAr;
  final List<String> bookingNotesEn;
  final List<String> bookingNotesAr;
  final List<String> catalogExcluded;
  final List<String> catalogTermsAndConditions;
  final List<String> catalogCancellationPolicy;
  final List<String> catalogAvailableOptions;
  final String catalogLocation;
  final List<String> catalogExcludedEn;
  final List<String> catalogExcludedAr;
  final List<String> catalogTermsAndConditionsEn;
  final List<String> catalogTermsAndConditionsAr;
  final List<String> catalogCancellationPolicyEn;
  final List<String> catalogCancellationPolicyAr;
  final List<String> catalogAvailableOptionsEn;
  final List<String> catalogAvailableOptionsAr;
  final String catalogLocationEn;
  final String catalogLocationAr;

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
    geoLat,
    geoLng,
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
    nameEn,
    nameAr,
    cityIdEn,
    cityIdAr,
    areaEn,
    areaAr,
    aboutEn,
    aboutAr,
    addressEn,
    addressAr,
    highlightsEn,
    highlightsAr,
    inclusionsEn,
    inclusionsAr,
    catalogDescriptionEn,
    catalogDescriptionAr,
    catalogHighlightsEn,
    catalogHighlightsAr,
    catalogIncludedEn,
    catalogIncludedAr,
    packageOverviewEn,
    packageOverviewAr,
    bookingNotesEn,
    bookingNotesAr,
    catalogExcluded,
    catalogTermsAndConditions,
    catalogCancellationPolicy,
    catalogAvailableOptions,
    catalogLocation,
    catalogExcludedEn,
    catalogExcludedAr,
    catalogTermsAndConditionsEn,
    catalogTermsAndConditionsAr,
    catalogCancellationPolicyEn,
    catalogCancellationPolicyAr,
    catalogAvailableOptionsEn,
    catalogAvailableOptionsAr,
    catalogLocationEn,
    catalogLocationAr,
  ];
}
