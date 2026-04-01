import '../../../../core/errors/exceptions.dart';
import 'booking_order_policy.dart';

class BookingRedemptionPolicy {
  static bool canRedeemRole(String role) {
    final normalized = role.trim().toLowerCase();
    return normalized == 'staff' ||
        normalized == 'restaurant_staff' ||
        normalized == 'admin';
  }

  static void validateStaff({
    required String role,
    required String restaurantId,
  }) {
    if (!canRedeemRole(role)) {
      throw BookingException('Only restaurant staff can redeem orders.');
    }
    if (restaurantId.trim().isEmpty) {
      throw BookingException('Staff account missing restaurant id.');
    }
  }

  static void validateBookingForStaff({
    required String bookingRestaurantId,
    required String staffRestaurantId,
    required String status,
  }) {
    if (bookingRestaurantId.trim() != staffRestaurantId.trim()) {
      throw BookingException('This order belongs to another restaurant.');
    }
    if (BookingOrderPolicy.isCompletedStatus(status)) {
      throw BookingException('Order already completed.');
    }
    if (!BookingOrderPolicy.canShowQr(status)) {
      throw BookingException('Order is not paid.');
    }
  }
}
