import 'app_strings.dart';

const String guestPricingModePerson = 'person';
const String guestPricingModeAdultsChildren = 'adults_children';
const String guestPricingModeCoupon = 'coupon';

bool isComboBookingCategory(String bookingCategory) {
  final normalizedCategory = bookingCategory.trim().toLowerCase().replaceAll(
    ' ',
    '_',
  );
  return normalizedCategory == 'combo';
}

String normalizeGuestPricingMode(
  String? rawMode, {
  String bookingCategory = '',
  String bookableType = '',
}) {
  final normalized = (rawMode ?? '')
      .trim()
      .toLowerCase()
      .replaceAll('+', '_')
      .replaceAll('-', '_')
      .replaceAll(' ', '_');

  switch (normalized) {
    case 'person':
    case 'per_person':
    case 'persons':
      return guestPricingModePerson;
    case 'coupon':
    case 'coupons':
    case 'per_coupon':
    case 'coupon_offer':
    case 'couponoffer':
      return guestPricingModeCoupon;
    case 'adults_children':
    case 'adults_child':
    case 'adult_child':
    case 'adultschildren':
    case 'adultschild':
      return guestPricingModeAdultsChildren;
  }

  final normalizedCategory = bookingCategory.trim().toLowerCase().replaceAll(
    ' ',
    '_',
  );
  if (normalizedCategory == 'combo') {
    return guestPricingModePerson;
  }
  if (normalizedCategory == 'set_menu' || normalizedCategory == 'setmenu') {
    return guestPricingModePerson;
  }
  if (bookableType.trim().toLowerCase() == 'attraction') {
    return guestPricingModePerson;
  }
  return guestPricingModeAdultsChildren;
}

bool usesUnifiedGuestCount({
  String? guestPricingMode,
  String bookingCategory = '',
  String bookableType = '',
}) {
  final normalizedMode = normalizeGuestPricingMode(
    guestPricingMode,
    bookingCategory: bookingCategory,
    bookableType: bookableType,
  );
  return normalizedMode == guestPricingModePerson ||
      normalizedMode == guestPricingModeCoupon;
}

bool isCouponGuestPricingMode({
  String? guestPricingMode,
  String bookingCategory = '',
  String bookableType = '',
}) {
  return normalizeGuestPricingMode(
        guestPricingMode,
        bookingCategory: bookingCategory,
        bookableType: bookableType,
      ) ==
      guestPricingModeCoupon;
}

String buildGuestsLabel(
  int adultsCount,
  int childrenCount, {
  String guestPricingMode = '',
  String bookingCategory = '',
  String bookableType = '',
}) {
  if (usesUnifiedGuestCount(
    guestPricingMode: guestPricingMode,
    bookingCategory: bookingCategory,
    bookableType: bookableType,
  )) {
    if (isComboBookingCategory(bookingCategory)) {
      return AppStrings.combosCountLabel(adultsCount + childrenCount);
    }
    if (isCouponGuestPricingMode(
      guestPricingMode: guestPricingMode,
      bookingCategory: bookingCategory,
      bookableType: bookableType,
    )) {
      return AppStrings.couponsCountLabel(adultsCount + childrenCount);
    }
    return AppStrings.guestsCountLabel(adultsCount + childrenCount);
  }
  if (childrenCount > 0) {
    return '${AppStrings.adultsCountLabel(adultsCount)} | ${AppStrings.childrenCountLabel(childrenCount)}';
  }
  return AppStrings.adultsCountLabel(adultsCount);
}

String selectionCountTitle({
  String bookingCategory = '',
  String guestPricingMode = '',
  String bookableType = '',
}) {
  final usesUnified = usesUnifiedGuestCount(
    guestPricingMode: guestPricingMode,
    bookingCategory: bookingCategory,
    bookableType: bookableType,
  );
  if (usesUnified && isComboBookingCategory(bookingCategory)) {
    return AppStrings.quantity;
  }
  if (isCouponGuestPricingMode(
    guestPricingMode: guestPricingMode,
    bookingCategory: bookingCategory,
    bookableType: bookableType,
  )) {
    return AppStrings.coupons;
  }
  return AppStrings.guests;
}
