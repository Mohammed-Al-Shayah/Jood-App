class PaymentScreenState {
  static const _unset = Object();

  const PaymentScreenState({
    this.isSubmitting = false,
    this.guestRedirectHandled = false,
    this.paymentSuccessHandled = false,
    this.sessionId,
  });

  final bool isSubmitting;
  final bool guestRedirectHandled;
  final bool paymentSuccessHandled;
  final String? sessionId;

  PaymentScreenState copyWith({
    bool? isSubmitting,
    bool? guestRedirectHandled,
    bool? paymentSuccessHandled,
    Object? sessionId = _unset,
  }) {
    return PaymentScreenState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      guestRedirectHandled: guestRedirectHandled ?? this.guestRedirectHandled,
      paymentSuccessHandled:
          paymentSuccessHandled ?? this.paymentSuccessHandled,
      sessionId: sessionId == _unset ? this.sessionId : sessionId as String?,
    );
  }

  static PaymentScreenState initial() => const PaymentScreenState();
}

class PreparedPaymentLaunch {
  const PreparedPaymentLaunch({
    required this.offerId,
    required this.offerTitle,
    required this.userId,
    required this.adultCount,
    required this.childCount,
    required this.totalPayable,
    required this.totalAmountInBaisa,
  });

  final String offerId;
  final String offerTitle;
  final String userId;
  final int adultCount;
  final int childCount;
  final double totalPayable;
  final int totalAmountInBaisa;
}
