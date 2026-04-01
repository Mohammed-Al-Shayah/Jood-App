import '../../../../core/utils/payment_amount_utils.dart';
import '../../../offers/domain/entities/offer_entity.dart';
import '../../domain/entities/catalog_category_type.dart';
import '../../domain/entities/catalog_item_entity.dart';
import 'catalog_booking_option.dart';

List<CatalogBookingOption> buildMealOptions(
  CatalogItemEntity item,
  List<OfferEntity> offers,
) {
  final grouped = <String, List<MapEntry<int, OfferEntity>>>{};
  for (final entry in offers.asMap().entries) {
    final key = mealOptionLabel(entry.value, item.category);
    grouped.putIfAbsent(key, () => []).add(entry);
  }

  final order = item.availableMeals.map((item) => item.toLowerCase()).toList();
  final options = grouped.entries.map((entry) {
    final sortedEntries = List<MapEntry<int, OfferEntity>>.from(entry.value)
      ..sort((a, b) {
        final availabilityCompare = availabilityRank(
          a.value,
        ).compareTo(availabilityRank(b.value));
        if (availabilityCompare != 0) return availabilityCompare;
        final priceCompare = a.value.priceAdult.compareTo(b.value.priceAdult);
        if (priceCompare != 0) return priceCompare;
        return a.value.startTime.compareTo(b.value.startTime);
      });
    final selectedEntry = sortedEntries.first;
    final offer = selectedEntry.value;
    final enabled = !isOfferUnavailable(offer);
    return CatalogBookingOption(
      key: entry.key,
      label: entry.key,
      subtitle: offer.startTime.trim().isEmpty
          ? ''
          : '${offer.startTime}${offer.endTime.trim().isEmpty ? '' : ' - ${offer.endTime}'}',
      primaryPriceLabel: formatCurrency(offer.currency, offer.priceAdult),
      secondaryPriceLabel:
          'Child ${formatCurrency(offer.currency, offer.priceChild)}',
      statusLabel: offerStatusLabel(offer),
      offerIndex: selectedEntry.key,
      isEnabled: enabled,
      details: buildOptionDetails(offer),
    );
  }).toList();

  options.sort((a, b) {
    final leftIndex = order.indexOf(a.label.toLowerCase());
    final rightIndex = order.indexOf(b.label.toLowerCase());
    if (leftIndex >= 0 && rightIndex >= 0) {
      return leftIndex.compareTo(rightIndex);
    }
    if (leftIndex >= 0) return -1;
    if (rightIndex >= 0) return 1;
    return a.label.compareTo(b.label);
  });
  return options;
}

List<CatalogBookingOption> buildTimeSlotOptions(List<OfferEntity> offers) {
  final grouped = <String, List<MapEntry<int, OfferEntity>>>{};
  for (final entry in offers.asMap().entries) {
    final key = timeSlotKey(entry.value);
    grouped.putIfAbsent(key, () => []).add(entry);
  }

  final result = grouped.entries.map((entry) {
    final availableOffers = entry.value
        .where((offer) => !isOfferUnavailable(offer.value))
        .toList();
    final reference = availableOffers.isNotEmpty
        ? availableOffers.first.value
        : entry.value.first.value;
    final minAdult = availableOffers.isEmpty
        ? reference.priceAdult
        : availableOffers
              .map((offer) => offer.value.priceAdult)
              .reduce((left, right) => left < right ? left : right);
    return CatalogBookingOption(
      key: entry.key,
      label: timeSlotLabel(reference),
      subtitle: availableOffers.isEmpty
          ? 'All packages are currently unavailable.'
          : 'From ${formatCurrency(reference.currency, minAdult)}',
      primaryPriceLabel: availableOffers.isEmpty
          ? 'Unavailable'
          : 'Packages ${availableOffers.length}',
      secondaryPriceLabel: '',
      statusLabel: availableOffers.isEmpty
          ? 'Sold out'
          : '${availableOffers.length} available',
      offerIndex: availableOffers.isEmpty
          ? entry.value.first.key
          : availableOffers.first.key,
      isEnabled: availableOffers.isNotEmpty,
      details: buildTimeSlotDetails(
        availableOffers.isNotEmpty ? availableOffers : entry.value,
      ),
    );
  }).toList();

  result.sort((a, b) => a.label.compareTo(b.label));
  return result;
}

List<CatalogBookingOption> buildPackageOptions(
  List<OfferEntity> offers, {
  required String timeSlot,
}) {
  final grouped = <String, List<MapEntry<int, OfferEntity>>>{};
  for (final entry in offers.asMap().entries) {
    if (timeSlotKey(entry.value) != timeSlot) continue;
    final key = packageLabel(entry.value);
    grouped.putIfAbsent(key, () => []).add(entry);
  }

  final result = grouped.entries.map((entry) {
    final sortedEntries = List<MapEntry<int, OfferEntity>>.from(entry.value)
      ..sort((a, b) {
        final availabilityCompare = availabilityRank(
          a.value,
        ).compareTo(availabilityRank(b.value));
        if (availabilityCompare != 0) return availabilityCompare;
        return a.value.priceAdult.compareTo(b.value.priceAdult);
      });
    final selectedEntry = sortedEntries.first;
    final offer = selectedEntry.value;
    return CatalogBookingOption(
      key: entry.key,
      label: entry.key,
      subtitle: offer.packageDescription,
      primaryPriceLabel: formatCurrency(offer.currency, offer.priceAdult),
      secondaryPriceLabel:
          'Child ${formatCurrency(offer.currency, offer.priceChild)}',
      statusLabel: offerStatusLabel(offer),
      offerIndex: selectedEntry.key,
      isEnabled: !isOfferUnavailable(offer),
      details: buildOptionDetails(
        offer,
        leadingDescription: offer.packageDescription,
      ),
    );
  }).toList();

  result.sort((a, b) => a.label.compareTo(b.label));
  return result;
}

List<String> buildOptionDetails(
  OfferEntity offer, {
  String? leadingDescription,
}) {
  final details = <String>[];
  final description = leadingDescription?.trim() ?? '';
  if (description.isNotEmpty) {
    details.add(description);
  }
  for (final condition in offer.entryConditions) {
    final value = condition.trim();
    if (value.isEmpty || details.contains(value)) continue;
    details.add(value);
  }
  return details;
}

List<String> buildTimeSlotDetails(List<MapEntry<int, OfferEntity>> offers) {
  final details = <String>[];
  for (final entry in offers) {
    final package = packageLabel(entry.value).trim();
    if (package.isEmpty || package == 'Package' || details.contains(package)) {
      continue;
    }
    details.add(package);
  }
  return details;
}

String mealOptionLabel(OfferEntity offer, CatalogCategoryType category) {
  final mealType = offer.mealType.trim();
  final title = offer.title.trim();
  String label;
  if (mealType.isNotEmpty) {
    label = titleize(mealType);
  } else if (title.isNotEmpty) {
    label = title;
  } else if (offer.startTime.trim().isNotEmpty) {
    label = timeSlotLabel(offer);
  } else {
    label = category == CatalogCategoryType.setMenu ? 'Set Menu' : 'Meal';
  }

  if (category == CatalogCategoryType.setMenu &&
      !label.toLowerCase().contains('set menu')) {
    return '$label Set Menu';
  }
  return label;
}

String packageLabel(OfferEntity offer) {
  final packageName = offer.packageName.trim();
  if (packageName.isNotEmpty) return packageName;
  final title = offer.title.trim();
  if (title.isNotEmpty) return title;
  return 'Package';
}

String timeSlotKey(OfferEntity offer) {
  return '${offer.startTime.trim()}|${offer.endTime.trim()}';
}

String timeSlotLabel(OfferEntity offer) {
  final start = offer.startTime.trim();
  final end = offer.endTime.trim();
  if (start.isEmpty && end.isEmpty) return 'Time';
  if (start.isEmpty) return end;
  if (end.isEmpty) return start;
  return '$start - $end';
}

String selectionLabel({
  required CatalogItemEntity item,
  required OfferEntity? selectedOffer,
  required String? selectedTimeSlotKey,
  required String? selectedPackageKey,
}) {
  if (selectedOffer == null) return '';
  if (item.bookingMode == CatalogBookingMode.timeSlotBased) {
    final slot = selectedTimeSlotKey ?? timeSlotLabel(selectedOffer);
    final package = selectedPackageKey ?? packageLabel(selectedOffer);
    if (slot.isEmpty) return package;
    if (package.isEmpty) return slot;
    return '$slot • $package';
  }
  return mealOptionLabel(selectedOffer, item.category);
}

String headerTitle(CatalogCategoryType category) {
  switch (category) {
    case CatalogCategoryType.buffet:
      return 'Book Buffet';
    case CatalogCategoryType.setMenu:
      return 'Book Set Menu';
    case CatalogCategoryType.attraction:
      return 'Book Attraction';
  }
}

int remainingTotal(OfferEntity offer) {
  final totalCapacity = offer.capacityAdult + offer.capacityChild;
  final totalBooked = offer.bookedAdult + offer.bookedChild;
  final remaining = totalCapacity - totalBooked;
  return remaining < 0 ? 0 : remaining;
}

String offerStatusLabel(OfferEntity offer) {
  final remaining = remainingTotal(offer);
  final availability = availabilityFor(offer);
  switch (availability) {
    case OfferAvailability.available:
      return '$remaining available';
    case OfferAvailability.low:
      return 'Only $remaining left';
    case OfferAvailability.soldOut:
      return 'Sold out';
    case OfferAvailability.expired:
      return 'Ended';
  }
}

bool isOfferUnavailable(OfferEntity offer) {
  final availability = availabilityFor(offer);
  return availability == OfferAvailability.soldOut ||
      availability == OfferAvailability.expired;
}

OfferAvailability availabilityFor(OfferEntity offer) {
  if (isOfferExpired(offer)) return OfferAvailability.expired;
  final status = offer.status.toLowerCase().replaceAll(' ', '');
  final remaining = remainingTotal(offer);
  if (remaining <= 0) return OfferAvailability.soldOut;
  if (status.contains('soldout') || status.contains('sold_out')) {
    return OfferAvailability.soldOut;
  }
  if (status.contains('low')) return OfferAvailability.low;
  if (remaining <= 3) return OfferAvailability.low;
  return OfferAvailability.available;
}

int availabilityRank(OfferEntity offer) {
  switch (availabilityFor(offer)) {
    case OfferAvailability.available:
      return 0;
    case OfferAvailability.low:
      return 1;
    case OfferAvailability.soldOut:
      return 2;
    case OfferAvailability.expired:
      return 3;
  }
}

enum OfferAvailability { available, low, soldOut, expired }

bool isOfferExpired(OfferEntity offer) {
  final date = DateTime.tryParse(offer.date);
  if (date == null) return false;
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final parsedDate = DateTime(date.year, date.month, date.day);
  if (parsedDate.isBefore(today)) return true;
  if (parsedDate.isAfter(today)) return false;
  final endMinutes =
      parseTimeToMinutes(offer.endTime) ?? parseTimeToMinutes(offer.startTime);
  if (endMinutes == null) return false;
  final nowMinutes = now.hour * 60 + now.minute;
  return nowMinutes >= endMinutes;
}

int? parseTimeToMinutes(String value) {
  final trimmed = value.trim().toLowerCase();
  if (trimmed.isEmpty) return null;
  final amPmMatch = RegExp(
    r'^(\d{1,2})(?::(\d{2}))?\s*([ap]m)$',
  ).firstMatch(trimmed);
  if (amPmMatch != null) {
    final hour = int.tryParse(amPmMatch.group(1) ?? '');
    final minute = int.tryParse(amPmMatch.group(2) ?? '0') ?? 0;
    final period = amPmMatch.group(3);
    if (hour == null) return null;
    var h = hour % 12;
    if (period == 'pm') h += 12;
    return h * 60 + minute;
  }
  final match24 = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(trimmed);
  if (match24 != null) {
    final hour = int.tryParse(match24.group(1) ?? '');
    final minute = int.tryParse(match24.group(2) ?? '');
    if (hour == null || minute == null) return null;
    return hour * 60 + minute;
  }
  return null;
}

String titleize(String value) {
  return value
      .split(RegExp(r'[_\s]+'))
      .where((part) => part.isNotEmpty)
      .map(
        (part) => '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}',
      )
      .join(' ');
}

T? firstWhereOrNull<T>(Iterable<T> values, bool Function(T item) test) {
  for (final value in values) {
    if (test(value)) return value;
  }
  return null;
}
