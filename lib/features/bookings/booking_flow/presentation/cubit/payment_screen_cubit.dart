import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jood/core/config/thawani_config.dart';
import 'package:jood/core/errors/exceptions.dart';
import 'package:jood/core/payments/payment_completion_service.dart';
import 'package:jood/core/payments/payment_verification_service.dart';
import 'package:jood/core/utils/app_strings.dart';
import 'package:jood/features/auth/domain/usecases/get_current_user_usecase.dart';

import '../models/booking_amounts_view_model.dart';
import 'booking_flow_cubit.dart';
import 'booking_flow_state.dart';
import 'payment_screen_state.dart';

class PaymentScreenCubit extends Cubit<PaymentScreenState> {
  PaymentScreenCubit({
    required GetCurrentUserUseCase getCurrentUser,
    required PaymentCompletionService paymentCompletionService,
  }) : _getCurrentUser = getCurrentUser,
       _paymentCompletionService = paymentCompletionService,
       super(PaymentScreenState.initial());

  final GetCurrentUserUseCase _getCurrentUser;
  final PaymentCompletionService _paymentCompletionService;

  bool get hasAuthenticatedUser => _getCurrentUser() != null;

  bool markGuestRedirectHandled() {
    if (state.guestRedirectHandled) return false;
    emit(state.copyWith(guestRedirectHandled: true));
    return true;
  }

  void beginPaymentAttempt() {
    emit(
      state.copyWith(
        isSubmitting: true,
        paymentSuccessHandled: false,
        sessionId: null,
      ),
    );
  }

  void stopSubmitting() {
    if (!state.isSubmitting) return;
    emit(state.copyWith(isSubmitting: false));
  }

  void setSessionId(String? sessionId) {
    emit(state.copyWith(sessionId: sessionId));
  }

  bool markPaymentSuccessHandled() {
    if (state.paymentSuccessHandled) return false;
    emit(state.copyWith(paymentSuccessHandled: true));
    return true;
  }

  Future<PreparedPaymentLaunch> prepareCheckout({
    required BookingFlowCubit bookingFlowCubit,
  }) async {
    final previousState = bookingFlowCubit.state;
    final previousOffer = previousState.selectedOffer();
    if (previousOffer == null) {
      throw BookingException(AppStrings.pleaseSelectOfferFirst);
    }

    final previousAmounts = BookingAmountsViewModel.calculate(
      adultPrice: previousOffer.priceAdult,
      childPrice: previousOffer.priceChild,
      adultOriginalPrice: previousOffer.priceAdultOriginal,
      adultCount: previousState.adultCount,
      childCount: previousState.childCount,
    );

    final stillSelected = await bookingFlowCubit.refreshSelectedDate();
    final refreshedState = bookingFlowCubit.state;
    final offer = refreshedState.selectedOffer();
    if (!stillSelected || offer == null) {
      throw BookingException(
        AppStrings.selectedOptionNoLongerAvailableReviewBooking,
      );
    }

    final refreshedAmounts = BookingAmountsViewModel.calculate(
      adultPrice: offer.priceAdult,
      childPrice: offer.priceChild,
      adultOriginalPrice: offer.priceAdultOriginal,
      adultCount: refreshedState.adultCount,
      childCount: refreshedState.childCount,
    );
    final pricingChanged =
        previousOffer.id != offer.id ||
        previousOffer.priceAdult != offer.priceAdult ||
        previousOffer.priceChild != offer.priceChild ||
        previousOffer.priceAdultOriginal != offer.priceAdultOriginal ||
        previousAmounts.totalPayable != refreshedAmounts.totalPayable;
    if (pricingChanged) {
      throw BookingException(AppStrings.pricingWasUpdatedReviewTotal);
    }

    final user = _getCurrentUser();
    if (user == null) {
      throw BookingException(AppStrings.pleaseLoginFirst);
    }
    if (!ThawaniConfig.isConfigured) {
      throw BookingException(AppStrings.thawaniNotConfiguredAddKeys);
    }

    final amounts = BookingAmountsViewModel.calculate(
      adultPrice: offer.priceAdult,
      childPrice: offer.priceChild,
      adultOriginalPrice: offer.priceAdultOriginal,
      adultCount: refreshedState.adultCount,
      childCount: refreshedState.childCount,
    );

    return PreparedPaymentLaunch(
      offerId: offer.id,
      offerTitle: offer.title.trim().isEmpty
          ? AppStrings.restaurantBooking
          : offer.title,
      userId: user.uid,
      adultCount: refreshedState.adultCount,
      childCount: refreshedState.childCount,
      totalPayable: amounts.totalPayable,
      totalAmountInBaisa: _toBaisa(amounts.totalPayable),
    );
  }

  Future<void> savePendingPayment({
    required PreparedPaymentLaunch checkout,
    required String restaurantName,
    required String sessionId,
  }) async {
    setSessionId(sessionId);
    await PaymentVerificationService.savePending(
      PendingPayment(
        sessionId: sessionId,
        offerId: checkout.offerId,
        userId: checkout.userId,
        adults: checkout.adultCount,
        children: checkout.childCount,
        totalAmount: checkout.totalPayable,
        restaurantName: restaurantName,
      ),
    );
  }

  Future<PaymentCompletionResult> finalizePayment(
    PreparedPaymentLaunch checkout,
  ) {
    return _paymentCompletionService.completeSuccessfulPayment(
      offerId: checkout.offerId,
      userId: checkout.userId,
      adults: checkout.adultCount,
      children: checkout.childCount,
      totalAmount: checkout.totalPayable,
      paymentSessionId: state.sessionId,
    );
  }

  int _toBaisa(double amount) {
    return (amount * 1000).round();
  }
}
