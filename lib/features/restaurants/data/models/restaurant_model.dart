import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/utils/localized_value_utils.dart';
import '../../../../core/utils/number_utils.dart';
import '../../domain/entities/restaurant_entity.dart';

class RestaurantModel extends RestaurantEntity {
  const RestaurantModel({
    required super.id,
    required super.name,
    required super.cityId,
    required super.area,
    required super.rating,
    required super.reviewsCount,
    required super.coverImageUrl,
    required super.about,
    required super.phone,
    required super.address,
    required super.geoLat,
    required super.geoLng,
    required super.openFrom,
    required super.openTo,
    required super.highlights,
    required super.inclusions,
    required super.exclusions,
    required super.cancellationPolicy,
    required super.knowBeforeYouGo,
    required super.isActive,
    required super.createdAt,
    super.badge,
    super.priceFrom,
    super.discount,
    super.slotsLeft,
    super.priceFromValue,
    super.discountValue,
    super.supportsBuffet,
    super.supportsSetMenu,
    super.nameEn,
    super.nameAr,
    super.cityIdEn,
    super.cityIdAr,
    super.areaEn,
    super.areaAr,
    super.aboutEn,
    super.aboutAr,
    super.addressEn,
    super.addressAr,
    super.highlightsEn,
    super.highlightsAr,
    super.inclusionsEn,
    super.inclusionsAr,
    super.exclusionsEn,
    super.exclusionsAr,
    super.cancellationPolicyEn,
    super.cancellationPolicyAr,
    super.knowBeforeYouGoEn,
    super.knowBeforeYouGoAr,
    super.buffetDescription,
    super.buffetHighlights,
    super.buffetIncluded,
    super.buffetExcluded,
    super.buffetTermsAndConditions,
    super.buffetCancellationPolicy,
    super.buffetAvailableOptions,
    super.buffetLocation,
    super.buffetDescriptionEn,
    super.buffetDescriptionAr,
    super.buffetHighlightsEn,
    super.buffetHighlightsAr,
    super.buffetIncludedEn,
    super.buffetIncludedAr,
    super.buffetExcludedEn,
    super.buffetExcludedAr,
    super.buffetTermsAndConditionsEn,
    super.buffetTermsAndConditionsAr,
    super.buffetCancellationPolicyEn,
    super.buffetCancellationPolicyAr,
    super.buffetAvailableOptionsEn,
    super.buffetAvailableOptionsAr,
    super.buffetLocationEn,
    super.buffetLocationAr,
    super.setMenuDescription,
    super.setMenuHighlights,
    super.setMenuIncluded,
    super.setMenuTermsAndConditions,
    super.setMenuCancellationPolicy,
    super.setMenuAvailableOptions,
    super.setMenuLocation,
    super.setMenuDescriptionEn,
    super.setMenuDescriptionAr,
    super.setMenuHighlightsEn,
    super.setMenuHighlightsAr,
    super.setMenuIncludedEn,
    super.setMenuIncludedAr,
    super.setMenuTermsAndConditionsEn,
    super.setMenuTermsAndConditionsAr,
    super.setMenuCancellationPolicyEn,
    super.setMenuCancellationPolicyAr,
    super.setMenuAvailableOptionsEn,
    super.setMenuAvailableOptionsAr,
    super.setMenuLocationEn,
    super.setMenuLocationAr,
    super.comboDescription,
    super.comboHighlights,
    super.comboIncluded,
    super.comboTermsAndConditions,
    super.comboCancellationPolicy,
    super.comboAvailableOptions,
    super.comboLocation,
    super.comboDescriptionEn,
    super.comboDescriptionAr,
    super.comboHighlightsEn,
    super.comboHighlightsAr,
    super.comboIncludedEn,
    super.comboIncludedAr,
    super.comboTermsAndConditionsEn,
    super.comboTermsAndConditionsAr,
    super.comboCancellationPolicyEn,
    super.comboCancellationPolicyAr,
    super.comboAvailableOptionsEn,
    super.comboAvailableOptionsAr,
    super.comboLocationEn,
    super.comboLocationAr,
  });

  factory RestaurantModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return RestaurantModel.fromMap(id: doc.id, data: data);
  }

  factory RestaurantModel.fromMap({
    required String id,
    required Map<String, dynamic> data,
  }) {
    final geo = (data['geo'] as Map?) ?? {};
    final openHours = (data['openHours'] as Map?) ?? {};
    final bookingCatalog = _asMap(data['bookingCatalog']);
    final buffetConfig = _asMap(bookingCatalog['buffet']);
    final setMenuConfig = _asMap(bookingCatalog['setMenu']);
    final comboConfig = _asMap(bookingCatalog['combo']);

    final nameEn = _stringValue(data['name']);
    final nameAr = _stringValue(data['nameAr']);
    final cityIdEn = _stringValue(data['cityId']);
    final cityIdAr = _stringValue(data['cityIdAr']);
    final areaEn = _stringValue(data['area']);
    final areaAr = _stringValue(data['areaAr']);
    final aboutEn = _stringValue(data['about']);
    final aboutAr = _stringValue(data['aboutAr']);
    final addressEn = _stringValue(data['address']);
    final addressAr = _stringValue(data['addressAr']);
    final highlightsEn = _stringList(data['highlights']);
    final highlightsAr = _stringList(data['highlightsAr']);
    final inclusionsEn = _stringList(data['inclusions']);
    final inclusionsAr = _stringList(data['inclusionsAr']);
    final exclusionsEn = _stringList(data['exclusions']);
    final exclusionsAr = _stringList(data['exclusionsAr']);
    final cancellationPolicyEn = _stringList(data['cancellationPolicy']);
    final cancellationPolicyAr = _stringList(data['cancellationPolicyAr']);
    final knowBeforeYouGoEn = _stringList(data['knowBeforeYouGo']);
    final knowBeforeYouGoAr = _stringList(data['knowBeforeYouGoAr']);
    final buffetDescriptionEn = _firstNonEmptyString(
      _stringValue(buffetConfig['description']),
      aboutEn,
    );
    final buffetDescriptionAr = _firstNonEmptyString(
      _stringValue(buffetConfig['descriptionAr']),
      aboutAr,
    );
    final buffetHighlightsEn = _firstNonEmptyList(
      _stringList(buffetConfig['highlights']),
      highlightsEn,
    );
    final buffetHighlightsAr = _firstNonEmptyList(
      _stringList(buffetConfig['highlightsAr']),
      highlightsAr,
    );
    final buffetIncludedEn = _firstNonEmptyList(
      _stringList(buffetConfig['included']),
      inclusionsEn,
    );
    final buffetIncludedAr = _firstNonEmptyList(
      _stringList(buffetConfig['includedAr']),
      inclusionsAr,
    );
    final buffetExcludedEn = _firstNonEmptyList(
      _stringList(buffetConfig['excluded']),
      exclusionsEn,
    );
    final buffetExcludedAr = _firstNonEmptyList(
      _stringList(buffetConfig['excludedAr']),
      exclusionsAr,
    );
    final buffetTermsAndConditionsEn = _firstNonEmptyList(
      _stringList(buffetConfig['terms']),
      _stringList(buffetConfig['notes']),
    );
    final buffetTermsAndConditionsAr = _firstNonEmptyList(
      _stringList(buffetConfig['termsAr']),
      _stringList(buffetConfig['notesAr']),
    );
    final buffetCancellationPolicyEn = _firstNonEmptyList(
      _stringList(buffetConfig['cancellationPolicy']),
      cancellationPolicyEn,
    );
    final buffetCancellationPolicyAr = _firstNonEmptyList(
      _stringList(buffetConfig['cancellationPolicyAr']),
      cancellationPolicyAr,
    );
    final buffetAvailableOptionsEn = _stringList(buffetConfig['availableMeals']);
    final buffetAvailableOptionsAr = _stringList(
      buffetConfig['availableMealsAr'],
    );
    final buffetLocationEn = _firstNonEmptyString(
      _stringValue(buffetConfig['location']),
      addressEn,
    );
    final buffetLocationAr = _firstNonEmptyString(
      _stringValue(buffetConfig['locationAr']),
      addressAr,
    );
    final setMenuDescriptionEn = _firstNonEmptyString(
      _stringValue(setMenuConfig['description']),
      aboutEn,
    );
    final setMenuDescriptionAr = _firstNonEmptyString(
      _stringValue(setMenuConfig['descriptionAr']),
      aboutAr,
    );
    final setMenuHighlightsEn = _firstNonEmptyList(
      _stringList(setMenuConfig['highlights']),
      highlightsEn,
    );
    final setMenuHighlightsAr = _firstNonEmptyList(
      _stringList(setMenuConfig['highlightsAr']),
      highlightsAr,
    );
    final setMenuIncludedEn = _firstNonEmptyList(
      _stringList(setMenuConfig['included']),
      inclusionsEn,
    );
    final setMenuIncludedAr = _firstNonEmptyList(
      _stringList(setMenuConfig['includedAr']),
      inclusionsAr,
    );
    final setMenuTermsAndConditionsEn = _firstNonEmptyList(
      _stringList(setMenuConfig['terms']),
      _stringList(setMenuConfig['notes']),
    );
    final setMenuTermsAndConditionsAr = _firstNonEmptyList(
      _stringList(setMenuConfig['termsAr']),
      _stringList(setMenuConfig['notesAr']),
    );
    final setMenuCancellationPolicyEn = _firstNonEmptyList(
      _stringList(setMenuConfig['cancellationPolicy']),
      cancellationPolicyEn,
    );
    final setMenuCancellationPolicyAr = _firstNonEmptyList(
      _stringList(setMenuConfig['cancellationPolicyAr']),
      cancellationPolicyAr,
    );
    final setMenuAvailableOptionsEn = _stringList(
      setMenuConfig['availableMeals'],
    );
    final setMenuAvailableOptionsAr = _stringList(
      setMenuConfig['availableMealsAr'],
    );
    final setMenuLocationEn = _firstNonEmptyString(
      _stringValue(setMenuConfig['location']),
      addressEn,
    );
    final setMenuLocationAr = _firstNonEmptyString(
      _stringValue(setMenuConfig['locationAr']),
      addressAr,
    );
    final comboDescriptionEn = _firstNonEmptyString(
      _stringValue(comboConfig['description']),
      aboutEn,
    );
    final comboDescriptionAr = _firstNonEmptyString(
      _stringValue(comboConfig['descriptionAr']),
      aboutAr,
    );
    final comboHighlightsEn = _firstNonEmptyList(
      _stringList(comboConfig['highlights']),
      highlightsEn,
    );
    final comboHighlightsAr = _firstNonEmptyList(
      _stringList(comboConfig['highlightsAr']),
      highlightsAr,
    );
    final comboIncludedEn = _firstNonEmptyList(
      _stringList(comboConfig['included']),
      inclusionsEn,
    );
    final comboIncludedAr = _firstNonEmptyList(
      _stringList(comboConfig['includedAr']),
      inclusionsAr,
    );
    final comboTermsAndConditionsEn = _firstNonEmptyList(
      _stringList(comboConfig['terms']),
      _stringList(comboConfig['notes']),
    );
    final comboTermsAndConditionsAr = _firstNonEmptyList(
      _stringList(comboConfig['termsAr']),
      _stringList(comboConfig['notesAr']),
    );
    final comboCancellationPolicyEn = _firstNonEmptyList(
      _stringList(comboConfig['cancellationPolicy']),
      cancellationPolicyEn,
    );
    final comboCancellationPolicyAr = _firstNonEmptyList(
      _stringList(comboConfig['cancellationPolicyAr']),
      cancellationPolicyAr,
    );
    final comboAvailableOptionsEn = _stringList(
      comboConfig['availableCombos'],
    );
    final comboAvailableOptionsAr = _stringList(
      comboConfig['availableCombosAr'],
    );
    final comboLocationEn = _firstNonEmptyString(
      _stringValue(comboConfig['location']),
      addressEn,
    );
    final comboLocationAr = _firstNonEmptyString(
      _stringValue(comboConfig['locationAr']),
      addressAr,
    );

    return RestaurantModel(
      id: id,
      name: resolveLocalizedText(english: nameEn, arabic: nameAr),
      cityId: resolveLocalizedText(english: cityIdEn, arabic: cityIdAr),
      area: resolveLocalizedText(english: areaEn, arabic: areaAr),
      rating: NumberUtils.toDouble(data['rating']),
      reviewsCount: (data['reviewsCount'] as num?)?.toInt() ?? 0,
      coverImageUrl: _stringValue(data['coverImageUrl']),
      about: resolveLocalizedText(english: aboutEn, arabic: aboutAr),
      phone: _stringValue(data['phone']),
      address: resolveLocalizedText(english: addressEn, arabic: addressAr),
      geoLat: NumberUtils.toDouble(geo['lat']),
      geoLng: NumberUtils.toDouble(geo['lng']),
      openFrom: openHours['from'] as String? ?? '',
      openTo: openHours['to'] as String? ?? '',
      highlights: resolveLocalizedList(
        english: highlightsEn,
        arabic: highlightsAr,
      ),
      inclusions: resolveLocalizedList(
        english: inclusionsEn,
        arabic: inclusionsAr,
      ),
      exclusions: resolveLocalizedList(
        english: exclusionsEn,
        arabic: exclusionsAr,
      ),
      cancellationPolicy: resolveLocalizedList(
        english: cancellationPolicyEn,
        arabic: cancellationPolicyAr,
      ),
      knowBeforeYouGo: resolveLocalizedList(
        english: knowBeforeYouGoEn,
        arabic: knowBeforeYouGoAr,
      ),
      isActive: data['isActive'] as bool? ?? true,
      createdAt: _toDateTime(data['createdAt']),
      badge: _stringValue(data['badge']),
      priceFrom: _stringValue(data['priceFrom']),
      discount: _stringValue(data['discount']),
      slotsLeft: _stringValue(data['slotsLeft']),
      priceFromValue: NumberUtils.toDouble(data['priceFromValue']),
      discountValue: NumberUtils.toDouble(data['discountValue']),
      supportsBuffet: _supportsCategory(bookingCatalog, 'buffet'),
      supportsSetMenu: _supportsCategory(bookingCatalog, 'set_menu'),
      nameEn: nameEn,
      nameAr: nameAr,
      cityIdEn: cityIdEn,
      cityIdAr: cityIdAr,
      areaEn: areaEn,
      areaAr: areaAr,
      aboutEn: aboutEn,
      aboutAr: aboutAr,
      addressEn: addressEn,
      addressAr: addressAr,
      highlightsEn: highlightsEn,
      highlightsAr: highlightsAr,
      inclusionsEn: inclusionsEn,
      inclusionsAr: inclusionsAr,
      exclusionsEn: exclusionsEn,
      exclusionsAr: exclusionsAr,
      cancellationPolicyEn: cancellationPolicyEn,
      cancellationPolicyAr: cancellationPolicyAr,
      knowBeforeYouGoEn: knowBeforeYouGoEn,
      knowBeforeYouGoAr: knowBeforeYouGoAr,
      buffetDescription: resolveLocalizedText(
        english: buffetDescriptionEn,
        arabic: buffetDescriptionAr,
      ),
      buffetHighlights: resolveLocalizedList(
        english: buffetHighlightsEn,
        arabic: buffetHighlightsAr,
      ),
      buffetIncluded: resolveLocalizedList(
        english: buffetIncludedEn,
        arabic: buffetIncludedAr,
      ),
      buffetExcluded: resolveLocalizedList(
        english: buffetExcludedEn,
        arabic: buffetExcludedAr,
      ),
      buffetTermsAndConditions: resolveLocalizedList(
        english: buffetTermsAndConditionsEn,
        arabic: buffetTermsAndConditionsAr,
      ),
      buffetCancellationPolicy: resolveLocalizedList(
        english: buffetCancellationPolicyEn,
        arabic: buffetCancellationPolicyAr,
      ),
      buffetAvailableOptions: resolveLocalizedList(
        english: buffetAvailableOptionsEn,
        arabic: buffetAvailableOptionsAr,
      ),
      buffetLocation: resolveLocalizedText(
        english: buffetLocationEn,
        arabic: buffetLocationAr,
      ),
      buffetDescriptionEn: buffetDescriptionEn,
      buffetDescriptionAr: buffetDescriptionAr,
      buffetHighlightsEn: buffetHighlightsEn,
      buffetHighlightsAr: buffetHighlightsAr,
      buffetIncludedEn: buffetIncludedEn,
      buffetIncludedAr: buffetIncludedAr,
      buffetExcludedEn: buffetExcludedEn,
      buffetExcludedAr: buffetExcludedAr,
      buffetTermsAndConditionsEn: buffetTermsAndConditionsEn,
      buffetTermsAndConditionsAr: buffetTermsAndConditionsAr,
      buffetCancellationPolicyEn: buffetCancellationPolicyEn,
      buffetCancellationPolicyAr: buffetCancellationPolicyAr,
      buffetAvailableOptionsEn: buffetAvailableOptionsEn,
      buffetAvailableOptionsAr: buffetAvailableOptionsAr,
      buffetLocationEn: buffetLocationEn,
      buffetLocationAr: buffetLocationAr,
      setMenuDescription: resolveLocalizedText(
        english: setMenuDescriptionEn,
        arabic: setMenuDescriptionAr,
      ),
      setMenuHighlights: resolveLocalizedList(
        english: setMenuHighlightsEn,
        arabic: setMenuHighlightsAr,
      ),
      setMenuIncluded: resolveLocalizedList(
        english: setMenuIncludedEn,
        arabic: setMenuIncludedAr,
      ),
      setMenuTermsAndConditions: resolveLocalizedList(
        english: setMenuTermsAndConditionsEn,
        arabic: setMenuTermsAndConditionsAr,
      ),
      setMenuCancellationPolicy: resolveLocalizedList(
        english: setMenuCancellationPolicyEn,
        arabic: setMenuCancellationPolicyAr,
      ),
      setMenuAvailableOptions: resolveLocalizedList(
        english: setMenuAvailableOptionsEn,
        arabic: setMenuAvailableOptionsAr,
      ),
      setMenuLocation: resolveLocalizedText(
        english: setMenuLocationEn,
        arabic: setMenuLocationAr,
      ),
      setMenuDescriptionEn: setMenuDescriptionEn,
      setMenuDescriptionAr: setMenuDescriptionAr,
      setMenuHighlightsEn: setMenuHighlightsEn,
      setMenuHighlightsAr: setMenuHighlightsAr,
      setMenuIncludedEn: setMenuIncludedEn,
      setMenuIncludedAr: setMenuIncludedAr,
      setMenuTermsAndConditionsEn: setMenuTermsAndConditionsEn,
      setMenuTermsAndConditionsAr: setMenuTermsAndConditionsAr,
      setMenuCancellationPolicyEn: setMenuCancellationPolicyEn,
      setMenuCancellationPolicyAr: setMenuCancellationPolicyAr,
      setMenuAvailableOptionsEn: setMenuAvailableOptionsEn,
      setMenuAvailableOptionsAr: setMenuAvailableOptionsAr,
      setMenuLocationEn: setMenuLocationEn,
      setMenuLocationAr: setMenuLocationAr,
      comboDescription: resolveLocalizedText(
        english: comboDescriptionEn,
        arabic: comboDescriptionAr,
      ),
      comboHighlights: resolveLocalizedList(
        english: comboHighlightsEn,
        arabic: comboHighlightsAr,
      ),
      comboIncluded: resolveLocalizedList(
        english: comboIncludedEn,
        arabic: comboIncludedAr,
      ),
      comboTermsAndConditions: resolveLocalizedList(
        english: comboTermsAndConditionsEn,
        arabic: comboTermsAndConditionsAr,
      ),
      comboCancellationPolicy: resolveLocalizedList(
        english: comboCancellationPolicyEn,
        arabic: comboCancellationPolicyAr,
      ),
      comboAvailableOptions: resolveLocalizedList(
        english: comboAvailableOptionsEn,
        arabic: comboAvailableOptionsAr,
      ),
      comboLocation: resolveLocalizedText(
        english: comboLocationEn,
        arabic: comboLocationAr,
      ),
      comboDescriptionEn: comboDescriptionEn,
      comboDescriptionAr: comboDescriptionAr,
      comboHighlightsEn: comboHighlightsEn,
      comboHighlightsAr: comboHighlightsAr,
      comboIncludedEn: comboIncludedEn,
      comboIncludedAr: comboIncludedAr,
      comboTermsAndConditionsEn: comboTermsAndConditionsEn,
      comboTermsAndConditionsAr: comboTermsAndConditionsAr,
      comboCancellationPolicyEn: comboCancellationPolicyEn,
      comboCancellationPolicyAr: comboCancellationPolicyAr,
      comboAvailableOptionsEn: comboAvailableOptionsEn,
      comboAvailableOptionsAr: comboAvailableOptionsAr,
      comboLocationEn: comboLocationEn,
      comboLocationAr: comboLocationAr,
    );
  }

  Map<String, dynamic> toMap() {
    final buffetCatalog = _buildCategoryCatalogContent(
      descriptionEn: buffetDescriptionEn,
      description: buffetDescription,
      descriptionAr: buffetDescriptionAr,
      highlightsEn: buffetHighlightsEn,
      highlights: buffetHighlights,
      highlightsAr: buffetHighlightsAr,
      includedEn: buffetIncludedEn,
      included: buffetIncluded,
      includedAr: buffetIncludedAr,
      termsEn: buffetTermsAndConditionsEn,
      terms: buffetTermsAndConditions,
      termsAr: buffetTermsAndConditionsAr,
      cancellationEn: buffetCancellationPolicyEn,
      cancellation: buffetCancellationPolicy,
      cancellationAr: buffetCancellationPolicyAr,
      locationEn: buffetLocationEn,
      location: buffetLocation,
      locationAr: buffetLocationAr,
      optionValuesEn: buffetAvailableOptionsEn,
      optionValues: buffetAvailableOptions,
      optionValuesAr: buffetAvailableOptionsAr,
      optionKey: 'availableMeals',
      excludedEn: buffetExcludedEn,
      excluded: buffetExcluded,
      excludedAr: buffetExcludedAr,
    );
    final setMenuCatalog = _buildCategoryCatalogContent(
      descriptionEn: setMenuDescriptionEn,
      description: setMenuDescription,
      descriptionAr: setMenuDescriptionAr,
      highlightsEn: setMenuHighlightsEn,
      highlights: setMenuHighlights,
      highlightsAr: setMenuHighlightsAr,
      includedEn: setMenuIncludedEn,
      included: setMenuIncluded,
      includedAr: setMenuIncludedAr,
      termsEn: setMenuTermsAndConditionsEn,
      terms: setMenuTermsAndConditions,
      termsAr: setMenuTermsAndConditionsAr,
      cancellationEn: setMenuCancellationPolicyEn,
      cancellation: setMenuCancellationPolicy,
      cancellationAr: setMenuCancellationPolicyAr,
      locationEn: setMenuLocationEn,
      location: setMenuLocation,
      locationAr: setMenuLocationAr,
      optionValuesEn: setMenuAvailableOptionsEn,
      optionValues: setMenuAvailableOptions,
      optionValuesAr: setMenuAvailableOptionsAr,
      optionKey: 'availableMeals',
    );
    final comboCatalog = _buildCategoryCatalogContent(
      descriptionEn: comboDescriptionEn,
      description: comboDescription,
      descriptionAr: comboDescriptionAr,
      highlightsEn: comboHighlightsEn,
      highlights: comboHighlights,
      highlightsAr: comboHighlightsAr,
      includedEn: comboIncludedEn,
      included: comboIncluded,
      includedAr: comboIncludedAr,
      termsEn: comboTermsAndConditionsEn,
      terms: comboTermsAndConditions,
      termsAr: comboTermsAndConditionsAr,
      cancellationEn: comboCancellationPolicyEn,
      cancellation: comboCancellationPolicy,
      cancellationAr: comboCancellationPolicyAr,
      locationEn: comboLocationEn,
      location: comboLocation,
      locationAr: comboLocationAr,
      optionValuesEn: comboAvailableOptionsEn,
      optionValues: comboAvailableOptions,
      optionValuesAr: comboAvailableOptionsAr,
      optionKey: 'availableCombos',
    );

    return {
      'name': _baseText(nameEn, name),
      'nameAr': nameAr.trim(),
      'cityId': _baseText(cityIdEn, cityId),
      'cityIdAr': cityIdAr.trim(),
      'area': _baseText(areaEn, area),
      'areaAr': areaAr.trim(),
      'rating': rating,
      'reviewsCount': reviewsCount,
      'coverImageUrl': coverImageUrl,
      'about': _baseText(aboutEn, about),
      'aboutAr': aboutAr.trim(),
      'phone': phone,
      'address': _baseText(addressEn, address),
      'addressAr': addressAr.trim(),
      'geo': {'lat': geoLat, 'lng': geoLng},
      'openHours': {'from': openFrom, 'to': openTo},
      'highlights': _baseList(highlightsEn, highlights),
      'highlightsAr': _cleanList(highlightsAr),
      'inclusions': _baseList(inclusionsEn, inclusions),
      'inclusionsAr': _cleanList(inclusionsAr),
      'exclusions': _baseList(exclusionsEn, exclusions),
      'exclusionsAr': _cleanList(exclusionsAr),
      'cancellationPolicy': _baseList(cancellationPolicyEn, cancellationPolicy),
      'cancellationPolicyAr': _cleanList(cancellationPolicyAr),
      'knowBeforeYouGo': _baseList(knowBeforeYouGoEn, knowBeforeYouGo),
      'knowBeforeYouGoAr': _cleanList(knowBeforeYouGoAr),
      'isActive': isActive,
      'badge': badge,
      'priceFrom': priceFrom,
      'discount': discount,
      'slotsLeft': slotsLeft,
      'priceFromValue': priceFromValue,
      'discountValue': discountValue,
      'bookingCatalog': {
        if (buffetCatalog != null) 'buffet': buffetCatalog,
        if (setMenuCatalog != null) 'setMenu': setMenuCatalog,
        if (comboCatalog != null) 'combo': comboCatalog,
      },
    };
  }

  static List<String> _stringList(dynamic value) {
    if (value is List) {
      return value
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList(growable: false);
    }
    if (value is String && value.trim().isNotEmpty) {
      return [value.trim()];
    }
    return const [];
  }

  static String _stringValue(dynamic value) {
    if (value == null) return '';
    return value.toString().trim();
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, item) => MapEntry(key.toString(), item));
    }
    return const <String, dynamic>{};
  }

  static bool _supportsCategory(
    Map<String, dynamic> bookingCatalog,
    String category,
  ) {
    if (category == 'set_menu') {
      return true;
    }

    final supported = _normalizedStringList(
      bookingCatalog['supportedCategories'],
    );

    if (category == 'buffet') {
      if (supported.isEmpty) return true;
      return supported.contains('buffet');
    }

    return true;
  }

  static List<String> _normalizedStringList(dynamic value) {
    if (value is! List) return const [];
    return value
        .map(
          (item) => item.toString().trim().toLowerCase().replaceAll(' ', '_'),
        )
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }

  static DateTime _toDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.now();
  }

  static String _baseText(String rawEnglish, String fallback) {
    final english = rawEnglish.trim();
    if (english.isNotEmpty) return english;
    return fallback.trim();
  }

  static List<String> _baseList(
    List<String> rawEnglish,
    List<String> fallback,
  ) {
    final english = _cleanList(rawEnglish);
    if (english.isNotEmpty) return english;
    return _cleanList(fallback);
  }

  static List<String> _cleanList(List<String> values) {
    return values
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
  }

  static String _firstNonEmptyString(String primary, String fallback) {
    if (primary.trim().isNotEmpty) return primary.trim();
    return fallback.trim();
  }

  static List<String> _firstNonEmptyList(
    List<String> primary,
    List<String> fallback,
  ) {
    final normalizedPrimary = _cleanList(primary);
    if (normalizedPrimary.isNotEmpty) return normalizedPrimary;
    return _cleanList(fallback);
  }

  static Map<String, dynamic>? _buildCategoryCatalogContent({
    required String descriptionEn,
    required String description,
    required String descriptionAr,
    required List<String> highlightsEn,
    required List<String> highlights,
    required List<String> highlightsAr,
    required List<String> includedEn,
    required List<String> included,
    required List<String> includedAr,
    required List<String> termsEn,
    required List<String> terms,
    required List<String> termsAr,
    required List<String> cancellationEn,
    required List<String> cancellation,
    required List<String> cancellationAr,
    required String locationEn,
    required String location,
    required String locationAr,
    required List<String> optionValuesEn,
    required List<String> optionValues,
    required List<String> optionValuesAr,
    required String optionKey,
    List<String> excludedEn = const [],
    List<String> excluded = const [],
    List<String> excludedAr = const [],
  }) {
    final content = <String, dynamic>{};

    final resolvedDescription = _baseText(descriptionEn, description);
    if (resolvedDescription.isNotEmpty) {
      content['description'] = resolvedDescription;
    }
    if (descriptionAr.trim().isNotEmpty) {
      content['descriptionAr'] = descriptionAr.trim();
    }

    final resolvedHighlights = _baseList(highlightsEn, highlights);
    if (resolvedHighlights.isNotEmpty) {
      content['highlights'] = resolvedHighlights;
    }
    final resolvedHighlightsAr = _cleanList(highlightsAr);
    if (resolvedHighlightsAr.isNotEmpty) {
      content['highlightsAr'] = resolvedHighlightsAr;
    }

    final resolvedIncluded = _baseList(includedEn, included);
    if (resolvedIncluded.isNotEmpty) {
      content['included'] = resolvedIncluded;
    }
    final resolvedIncludedAr = _cleanList(includedAr);
    if (resolvedIncludedAr.isNotEmpty) {
      content['includedAr'] = resolvedIncludedAr;
    }

    final resolvedExcluded = _baseList(excludedEn, excluded);
    if (resolvedExcluded.isNotEmpty) {
      content['excluded'] = resolvedExcluded;
    }
    final resolvedExcludedAr = _cleanList(excludedAr);
    if (resolvedExcludedAr.isNotEmpty) {
      content['excludedAr'] = resolvedExcludedAr;
    }

    final resolvedTerms = _baseList(termsEn, terms);
    if (resolvedTerms.isNotEmpty) {
      content['terms'] = resolvedTerms;
    }
    final resolvedTermsAr = _cleanList(termsAr);
    if (resolvedTermsAr.isNotEmpty) {
      content['termsAr'] = resolvedTermsAr;
    }

    final resolvedCancellation = _baseList(cancellationEn, cancellation);
    if (resolvedCancellation.isNotEmpty) {
      content['cancellationPolicy'] = resolvedCancellation;
    }
    final resolvedCancellationAr = _cleanList(cancellationAr);
    if (resolvedCancellationAr.isNotEmpty) {
      content['cancellationPolicyAr'] = resolvedCancellationAr;
    }

    final resolvedLocation = _baseText(locationEn, location);
    if (resolvedLocation.isNotEmpty) {
      content['location'] = resolvedLocation;
    }
    if (locationAr.trim().isNotEmpty) {
      content['locationAr'] = locationAr.trim();
    }

    final resolvedOptions = _baseList(optionValuesEn, optionValues);
    if (resolvedOptions.isNotEmpty) {
      content[optionKey] = resolvedOptions;
    }
    final resolvedOptionsAr = _cleanList(optionValuesAr);
    if (resolvedOptionsAr.isNotEmpty) {
      content['${optionKey}Ar'] = resolvedOptionsAr;
    }

    return content.isEmpty ? null : content;
  }
}
