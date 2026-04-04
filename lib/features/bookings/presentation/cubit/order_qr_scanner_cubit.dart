import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../auth/domain/usecases/get_current_user_usecase.dart';
import '../../../offers/domain/usecases/get_offer_by_id_usecase.dart';
import '../../../restaurants/domain/usecases/get_restaurant_details_usecase.dart';
import '../../../users/domain/usecases/get_user_by_id_usecase.dart';
import '../../domain/entities/booking_entity.dart';
import '../../domain/services/booking_redemption_policy.dart';
import '../../domain/usecases/complete_booking_usecase.dart';
import '../../domain/usecases/get_booking_by_code_usecase.dart';
import '../models/booking_review_view_model.dart';
import 'order_qr_scanner_state.dart';

class OrderQrScannerCubit extends Cubit<OrderQrScannerState> {
  OrderQrScannerCubit({
    required GetCurrentUserUseCase getCurrentUser,
    required GetUserByIdUseCase getUserById,
    required GetBookingByCodeUseCase getBookingByCode,
    required CompleteBookingUseCase completeBooking,
    required GetRestaurantDetailsUseCase getRestaurantDetails,
    required GetOfferByIdUseCase getOfferById,
  }) : _getCurrentUser = getCurrentUser,
       _getUserById = getUserById,
       _getBookingByCode = getBookingByCode,
       _completeBooking = completeBooking,
       _getRestaurantDetails = getRestaurantDetails,
       _getOfferById = getOfferById,
       super(OrderQrScannerState.initial());

  final GetCurrentUserUseCase _getCurrentUser;
  final GetUserByIdUseCase _getUserById;
  final GetBookingByCodeUseCase _getBookingByCode;
  final CompleteBookingUseCase _completeBooking;
  final GetRestaurantDetailsUseCase _getRestaurantDetails;
  final GetOfferByIdUseCase _getOfferById;

  final Map<String, String> _restaurantNamesById = <String, String>{};
  final Map<String, String> _offerTitlesById = <String, String>{};

  Future<BookingReviewViewModel> loadBookingForCode(String rawCode) async {
    final code = _normalizeCode(rawCode);
    if (code.isEmpty) {
      throw BookingException(AppStrings.invalidQrCode);
    }

    emit(
      state.copyWith(
        status: OrderQrScannerStatus.verifying,
        booking: null,
        message: null,
      ),
    );

    try {
      final authUser = _getCurrentUser();
      if (authUser == null) {
        throw BookingException(AppStrings.noSignedInUser);
      }

      final staff = await _getUserById(authUser.uid);
      if (staff == null) {
        throw BookingException(AppStrings.staffAccountNotFound);
      }

      final staffRestaurantId = (staff.restaurantId ?? '').trim();
      BookingRedemptionPolicy.validateStaff(
        role: staff.role,
        restaurantId: staffRestaurantId,
      );

      final booking = await _getBookingByCode(code);
      BookingRedemptionPolicy.validateBookingForStaff(
        bookingRestaurantId: booking.restaurantId,
        staffRestaurantId: staffRestaurantId,
        status: booking.status,
      );

      final review = await _buildBookingReview(booking, fallbackCode: code);
      if (isClosed) return review;

      emit(
        state.copyWith(
          status: OrderQrScannerStatus.ready,
          booking: review,
          staffRestaurantId: staffRestaurantId,
          message: null,
        ),
      );
      return review;
    } catch (error) {
      final message = _messageFrom(error);
      if (!isClosed) {
        emit(
          state.copyWith(
            status: OrderQrScannerStatus.failure,
            booking: null,
            message: message,
          ),
        );
      }
      throw BookingException(message);
    }
  }

  Future<String> completeCurrentBooking() async {
    final booking = state.booking;
    if (booking == null) {
      throw BookingException(AppStrings.orderNotFound);
    }

    final authUser = _getCurrentUser();
    if (authUser == null) {
      throw BookingException(AppStrings.noSignedInUser);
    }

    final staffRestaurantId = (state.staffRestaurantId ?? '').trim();
    if (staffRestaurantId.isEmpty) {
      throw BookingException(AppStrings.staffAccountMissingRestaurantId);
    }

    emit(
      state.copyWith(status: OrderQrScannerStatus.completing, message: null),
    );

    try {
      await _completeBooking(
        bookingId: booking.bookingId,
        staffRestaurantId: staffRestaurantId,
        actorUserId: authUser.uid,
      );
      final message = AppStrings.orderCompletedSuccessfully;
      if (isClosed) return message;
      emit(
        state.copyWith(status: OrderQrScannerStatus.success, message: message),
      );
      return message;
    } catch (error) {
      final message = _messageFrom(error);
      if (!isClosed) {
        emit(
          state.copyWith(
            status: OrderQrScannerStatus.failure,
            booking: null,
            message: message,
          ),
        );
      }
      throw BookingException(message);
    }
  }

  Future<BookingReviewViewModel> _buildBookingReview(
    BookingEntity booking, {
    required String fallbackCode,
  }) async {
    var restaurantName = (booking.restaurantNameSnapshot ?? '').trim();
    if (restaurantName.isEmpty) {
      restaurantName = await _resolveRestaurantName(booking.restaurantId);
    }

    var offerTitle = (booking.offerTitleSnapshot ?? '').trim();
    if (offerTitle.isEmpty) {
      offerTitle = await _resolveOfferTitle(booking.offerId);
    }

    return BookingReviewViewModel.fromValues(
      bookingId: booking.id,
      bookingCode: booking.bookingCode,
      restaurantId: booking.restaurantId,
      offerId: booking.offerId,
      date: booking.date,
      startTime: booking.startTime,
      adults: booking.adults,
      children: booking.children,
      status: booking.status,
      subtotal: booking.subtotal,
      tax: booking.tax,
      total: booking.total,
      restaurantNameSnapshot: restaurantName,
      offerTitleSnapshot: offerTitle,
      fallbackCode: fallbackCode,
    );
  }

  Future<String> _resolveRestaurantName(String restaurantId) async {
    final cleaned = restaurantId.trim();
    if (cleaned.isEmpty) return restaurantId;
    final cached = _restaurantNamesById[cleaned];
    if (cached != null && cached.isNotEmpty) return cached;
    try {
      final restaurant = await _getRestaurantDetails(cleaned);
      final name = restaurant.name.trim().isEmpty ? cleaned : restaurant.name;
      _restaurantNamesById[cleaned] = name;
      return name;
    } catch (_) {
      return cleaned;
    }
  }

  Future<String> _resolveOfferTitle(String offerId) async {
    final cleaned = offerId.trim();
    if (cleaned.isEmpty) return '-';
    final cached = _offerTitlesById[cleaned];
    if (cached != null && cached.isNotEmpty) return cached;
    try {
      final offer = await _getOfferById(cleaned);
      final title = offer.title.trim();
      if (title.isNotEmpty) {
        _offerTitlesById[cleaned] = title;
        return title;
      }
    } catch (_) {
      // Keep scanner flow working even if offer lookup fails.
    }
    return cleaned.replaceAll('_', ' ');
  }

  String _normalizeCode(String rawCode) {
    final trimmed = rawCode.trim();
    if (trimmed.startsWith('BOOKING:')) {
      return trimmed.substring(8).trim();
    }
    return trimmed;
  }

  String _messageFrom(Object error) {
    if (error is BookingException) return error.message;
    final message = error.toString().replaceFirst('Exception: ', '').trim();
    return message.isEmpty ? AppStrings.somethingWentWrong : message;
  }
}
