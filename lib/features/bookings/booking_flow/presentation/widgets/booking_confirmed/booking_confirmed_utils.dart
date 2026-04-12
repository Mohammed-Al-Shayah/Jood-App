import 'package:jood/core/utils/guest_pricing_utils.dart' as guest_pricing;

String buildGuestsLabel(
  int adultsCount,
  int childrenCount, {
  String guestPricingMode = '',
  String bookingCategory = '',
  String bookableType = '',
}) {
  return guest_pricing.buildGuestsLabel(
    adultsCount,
    childrenCount,
    guestPricingMode: guestPricingMode,
    bookingCategory: bookingCategory,
    bookableType: bookableType,
  );
}
