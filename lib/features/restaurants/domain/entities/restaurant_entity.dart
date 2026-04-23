import 'package:equatable/equatable.dart';

class RestaurantEntity extends Equatable {
  const RestaurantEntity({
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
    required this.geoLat,
    required this.geoLng,
    required this.openFrom,
    required this.openTo,
    required this.highlights,
    required this.inclusions,
    required this.exclusions,
    required this.cancellationPolicy,
    required this.knowBeforeYouGo,
    required this.isActive,
    required this.createdAt,
    this.badge = '',
    this.priceFrom = '',
    this.discount = '',
    this.slotsLeft = '',
    this.priceFromValue = 0,
    this.discountValue = 0,
    this.supportsBuffet = true,
    this.supportsSetMenu = false,
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
    this.exclusionsEn = const [],
    this.exclusionsAr = const [],
    this.cancellationPolicyEn = const [],
    this.cancellationPolicyAr = const [],
    this.knowBeforeYouGoEn = const [],
    this.knowBeforeYouGoAr = const [],
    this.buffetDescription = '',
    this.buffetHighlights = const [],
    this.buffetIncluded = const [],
    this.buffetExcluded = const [],
    this.buffetTermsAndConditions = const [],
    this.buffetCancellationPolicy = const [],
    this.buffetAvailableOptions = const [],
    this.buffetLocation = '',
    this.buffetDescriptionEn = '',
    this.buffetDescriptionAr = '',
    this.buffetHighlightsEn = const [],
    this.buffetHighlightsAr = const [],
    this.buffetIncludedEn = const [],
    this.buffetIncludedAr = const [],
    this.buffetExcludedEn = const [],
    this.buffetExcludedAr = const [],
    this.buffetTermsAndConditionsEn = const [],
    this.buffetTermsAndConditionsAr = const [],
    this.buffetCancellationPolicyEn = const [],
    this.buffetCancellationPolicyAr = const [],
    this.buffetAvailableOptionsEn = const [],
    this.buffetAvailableOptionsAr = const [],
    this.buffetLocationEn = '',
    this.buffetLocationAr = '',
    this.setMenuDescription = '',
    this.setMenuHighlights = const [],
    this.setMenuIncluded = const [],
    this.setMenuTermsAndConditions = const [],
    this.setMenuCancellationPolicy = const [],
    this.setMenuAvailableOptions = const [],
    this.setMenuLocation = '',
    this.setMenuDescriptionEn = '',
    this.setMenuDescriptionAr = '',
    this.setMenuHighlightsEn = const [],
    this.setMenuHighlightsAr = const [],
    this.setMenuIncludedEn = const [],
    this.setMenuIncludedAr = const [],
    this.setMenuTermsAndConditionsEn = const [],
    this.setMenuTermsAndConditionsAr = const [],
    this.setMenuCancellationPolicyEn = const [],
    this.setMenuCancellationPolicyAr = const [],
    this.setMenuAvailableOptionsEn = const [],
    this.setMenuAvailableOptionsAr = const [],
    this.setMenuLocationEn = '',
    this.setMenuLocationAr = '',
    this.comboDescription = '',
    this.comboHighlights = const [],
    this.comboIncluded = const [],
    this.comboTermsAndConditions = const [],
    this.comboCancellationPolicy = const [],
    this.comboAvailableOptions = const [],
    this.comboLocation = '',
    this.comboDescriptionEn = '',
    this.comboDescriptionAr = '',
    this.comboHighlightsEn = const [],
    this.comboHighlightsAr = const [],
    this.comboIncludedEn = const [],
    this.comboIncludedAr = const [],
    this.comboTermsAndConditionsEn = const [],
    this.comboTermsAndConditionsAr = const [],
    this.comboCancellationPolicyEn = const [],
    this.comboCancellationPolicyAr = const [],
    this.comboAvailableOptionsEn = const [],
    this.comboAvailableOptionsAr = const [],
    this.comboLocationEn = '',
    this.comboLocationAr = '',
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
  final String openFrom;
  final String openTo;
  final List<String> highlights;
  final List<String> inclusions;
  final List<String> exclusions;
  final List<String> cancellationPolicy;
  final List<String> knowBeforeYouGo;
  final bool isActive;
  final DateTime createdAt;
  final String badge;
  final String priceFrom;
  final String discount;
  final String slotsLeft;
  final double priceFromValue;
  final double discountValue;
  final bool supportsBuffet;
  final bool supportsSetMenu;
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
  final List<String> exclusionsEn;
  final List<String> exclusionsAr;
  final List<String> cancellationPolicyEn;
  final List<String> cancellationPolicyAr;
  final List<String> knowBeforeYouGoEn;
  final List<String> knowBeforeYouGoAr;
  final String buffetDescription;
  final List<String> buffetHighlights;
  final List<String> buffetIncluded;
  final List<String> buffetExcluded;
  final List<String> buffetTermsAndConditions;
  final List<String> buffetCancellationPolicy;
  final List<String> buffetAvailableOptions;
  final String buffetLocation;
  final String buffetDescriptionEn;
  final String buffetDescriptionAr;
  final List<String> buffetHighlightsEn;
  final List<String> buffetHighlightsAr;
  final List<String> buffetIncludedEn;
  final List<String> buffetIncludedAr;
  final List<String> buffetExcludedEn;
  final List<String> buffetExcludedAr;
  final List<String> buffetTermsAndConditionsEn;
  final List<String> buffetTermsAndConditionsAr;
  final List<String> buffetCancellationPolicyEn;
  final List<String> buffetCancellationPolicyAr;
  final List<String> buffetAvailableOptionsEn;
  final List<String> buffetAvailableOptionsAr;
  final String buffetLocationEn;
  final String buffetLocationAr;
  final String setMenuDescription;
  final List<String> setMenuHighlights;
  final List<String> setMenuIncluded;
  final List<String> setMenuTermsAndConditions;
  final List<String> setMenuCancellationPolicy;
  final List<String> setMenuAvailableOptions;
  final String setMenuLocation;
  final String setMenuDescriptionEn;
  final String setMenuDescriptionAr;
  final List<String> setMenuHighlightsEn;
  final List<String> setMenuHighlightsAr;
  final List<String> setMenuIncludedEn;
  final List<String> setMenuIncludedAr;
  final List<String> setMenuTermsAndConditionsEn;
  final List<String> setMenuTermsAndConditionsAr;
  final List<String> setMenuCancellationPolicyEn;
  final List<String> setMenuCancellationPolicyAr;
  final List<String> setMenuAvailableOptionsEn;
  final List<String> setMenuAvailableOptionsAr;
  final String setMenuLocationEn;
  final String setMenuLocationAr;
  final String comboDescription;
  final List<String> comboHighlights;
  final List<String> comboIncluded;
  final List<String> comboTermsAndConditions;
  final List<String> comboCancellationPolicy;
  final List<String> comboAvailableOptions;
  final String comboLocation;
  final String comboDescriptionEn;
  final String comboDescriptionAr;
  final List<String> comboHighlightsEn;
  final List<String> comboHighlightsAr;
  final List<String> comboIncludedEn;
  final List<String> comboIncludedAr;
  final List<String> comboTermsAndConditionsEn;
  final List<String> comboTermsAndConditionsAr;
  final List<String> comboCancellationPolicyEn;
  final List<String> comboCancellationPolicyAr;
  final List<String> comboAvailableOptionsEn;
  final List<String> comboAvailableOptionsAr;
  final String comboLocationEn;
  final String comboLocationAr;

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
    openFrom,
    openTo,
    highlights,
    inclusions,
    exclusions,
    cancellationPolicy,
    knowBeforeYouGo,
    isActive,
    createdAt,
    badge,
    priceFrom,
    discount,
    slotsLeft,
    priceFromValue,
    discountValue,
    supportsBuffet,
    supportsSetMenu,
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
    exclusionsEn,
    exclusionsAr,
    cancellationPolicyEn,
    cancellationPolicyAr,
    knowBeforeYouGoEn,
    knowBeforeYouGoAr,
    buffetDescription,
    buffetHighlights,
    buffetIncluded,
    buffetExcluded,
    buffetTermsAndConditions,
    buffetCancellationPolicy,
    buffetAvailableOptions,
    buffetLocation,
    buffetDescriptionEn,
    buffetDescriptionAr,
    buffetHighlightsEn,
    buffetHighlightsAr,
    buffetIncludedEn,
    buffetIncludedAr,
    buffetExcludedEn,
    buffetExcludedAr,
    buffetTermsAndConditionsEn,
    buffetTermsAndConditionsAr,
    buffetCancellationPolicyEn,
    buffetCancellationPolicyAr,
    buffetAvailableOptionsEn,
    buffetAvailableOptionsAr,
    buffetLocationEn,
    buffetLocationAr,
    setMenuDescription,
    setMenuHighlights,
    setMenuIncluded,
    setMenuTermsAndConditions,
    setMenuCancellationPolicy,
    setMenuAvailableOptions,
    setMenuLocation,
    setMenuDescriptionEn,
    setMenuDescriptionAr,
    setMenuHighlightsEn,
    setMenuHighlightsAr,
    setMenuIncludedEn,
    setMenuIncludedAr,
    setMenuTermsAndConditionsEn,
    setMenuTermsAndConditionsAr,
    setMenuCancellationPolicyEn,
    setMenuCancellationPolicyAr,
    setMenuAvailableOptionsEn,
    setMenuAvailableOptionsAr,
    setMenuLocationEn,
    setMenuLocationAr,
    comboDescription,
    comboHighlights,
    comboIncluded,
    comboTermsAndConditions,
    comboCancellationPolicy,
    comboAvailableOptions,
    comboLocation,
    comboDescriptionEn,
    comboDescriptionAr,
    comboHighlightsEn,
    comboHighlightsAr,
    comboIncludedEn,
    comboIncludedAr,
    comboTermsAndConditionsEn,
    comboTermsAndConditionsAr,
    comboCancellationPolicyEn,
    comboCancellationPolicyAr,
    comboAvailableOptionsEn,
    comboAvailableOptionsAr,
    comboLocationEn,
    comboLocationAr,
  ];
}
