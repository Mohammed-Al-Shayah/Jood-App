import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/app_strings.dart';
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
      throw BookingException(AppStrings.onlyRestaurantStaffCanRedeemOrders);
    }
    if (restaurantId.trim().isEmpty) {
      throw BookingException(AppStrings.staffAccountMissingRestaurantId);
    }
  }

  static void validateBookingForStaff({
    required String bookingRestaurantId,
    required String staffRestaurantId,
    required String status,
  }) {
    if (bookingRestaurantId.trim() != staffRestaurantId.trim()) {
      throw BookingException(AppStrings.orderBelongsToAnotherRestaurant);
    }
    if (BookingOrderPolicy.isCompletedStatus(status)) {
      throw BookingException(AppStrings.orderAlreadyCompleted);
    }
    if (!BookingOrderPolicy.canShowQr(status)) {
      throw BookingException(AppStrings.orderIsNotPaid);
    }
  }
}
