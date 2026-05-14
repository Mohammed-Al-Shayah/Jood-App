import 'package:flutter_test/flutter_test.dart';
import 'package:jood/core/errors/exceptions.dart';
import 'package:jood/features/bookings/domain/services/booking_order_policy.dart';
import 'package:jood/features/bookings/domain/services/booking_redemption_policy.dart';

void main() {
  group('BookingOrderPolicy', () {
    test('recognizes status groups', () {
      expect(BookingOrderPolicy.isCancelledStatus('cancelled'), isTrue);
      expect(BookingOrderPolicy.isCancelledStatus('canceled'), isTrue);
      expect(BookingOrderPolicy.isCompletedStatus('complete'), isTrue);
      expect(BookingOrderPolicy.canShowQr('paid'), isTrue);
      expect(BookingOrderPolicy.canShowQr('pending'), isFalse);
    });

    test('allows cancellation before same-day end time', () {
      expect(
        BookingOrderPolicy.isCancellationAllowed(
          date: '2026-01-10',
          startTime: '10:00',
          endTime: '12:00',
          now: DateTime(2026, 1, 10, 11),
        ),
        isTrue,
      );
      expect(
        BookingOrderPolicy.isCancellationAllowed(
          date: '2026-01-10',
          startTime: '10:00',
          endTime: '12:00',
          now: DateTime(2026, 1, 10, 13),
        ),
        isFalse,
      );
    });

    test('handles overnight ranges', () {
      expect(
        BookingOrderPolicy.isCancellationAllowed(
          date: '2026-01-10',
          startTime: '22:00',
          endTime: '01:00',
          now: DateTime(2026, 1, 11, 0, 30),
        ),
        isTrue,
      );
    });
  });

  group('BookingRedemptionPolicy', () {
    test('allows staff-like roles only', () {
      expect(BookingRedemptionPolicy.canRedeemRole('admin'), isTrue);
      expect(BookingRedemptionPolicy.canRedeemRole('restaurant_staff'), isTrue);
      expect(BookingRedemptionPolicy.canRedeemRole('customer'), isFalse);
    });

    test('rejects invalid staff and booking combinations', () {
      expect(
        () => BookingRedemptionPolicy.validateStaff(
          role: 'customer',
          restaurantId: 'r1',
        ),
        throwsA(isA<BookingException>()),
      );
      expect(
        () => BookingRedemptionPolicy.validateBookingForStaff(
          bookingRestaurantId: 'r1',
          staffRestaurantId: 'r2',
          status: 'paid',
        ),
        throwsA(isA<BookingException>()),
      );
      expect(
        () => BookingRedemptionPolicy.validateBookingForStaff(
          bookingRestaurantId: 'r1',
          staffRestaurantId: 'r1',
          status: 'completed',
        ),
        throwsA(isA<BookingException>()),
      );
    });
  });
}
