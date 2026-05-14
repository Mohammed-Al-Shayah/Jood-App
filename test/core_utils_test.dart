import 'package:flutter_test/flutter_test.dart';
import 'package:jood/core/utils/guest_pricing_utils.dart';
import 'package:jood/core/utils/payment_amount_utils.dart';

void main() {
  group('guest pricing utils', () {
    test('normalizes known pricing aliases', () {
      expect(normalizeGuestPricingMode('per-person'), guestPricingModePerson);
      expect(normalizeGuestPricingMode('coupon offer'), guestPricingModeCoupon);
      expect(
        normalizeGuestPricingMode('adult_child'),
        guestPricingModeAdultsChildren,
      );
    });

    test('defaults set menu, combo, and attraction to unified counts', () {
      expect(usesUnifiedGuestCount(bookingCategory: 'set_menu'), isTrue);
      expect(usesUnifiedGuestCount(bookingCategory: 'combo'), isTrue);
      expect(usesUnifiedGuestCount(bookableType: 'attraction'), isTrue);
      expect(usesUnifiedGuestCount(bookingCategory: 'buffet'), isFalse);
    });
  });

  group('payment amount utils', () {
    test('parses common formatted prices', () {
      expect(parsePrice(r'$1,234.5'), 1234.5);
      expect(parsePrice('12,5'), 12.5);
      expect(parsePrice('no price'), 0);
    });

    test('normalizes Omani Rial labels and formats currency', () {
      expect(isOmaniRialCurrency('OMR'), isTrue);
      expect(isOmaniRialCurrency('OMN'), isTrue);
      expect(displayCurrencyLabel('OMR'), 'ر.ع');
      expect(formatCurrency('OMR', 12), 'ر.ع 12.0');
      expect(formatCurrency('USD', 12), 'USD 12.0');
      expect(currencyFromFormattedLabel('ر.ع 12.0'), 'OMR');
    });
  });
}
