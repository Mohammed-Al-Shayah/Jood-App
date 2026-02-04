enum ForgetPasswordStatus { initial, loading, success, phoneOtpSent, failure }

class ForgetPasswordState {
  const ForgetPasswordState({
    required this.input,
    required this.isValid,
    required this.status,
    this.verificationId,
    this.resendToken,
    this.errorMessage,
  });

  final String input;
  final bool isValid;
  final ForgetPasswordStatus status;
  final String? verificationId;
  final int? resendToken;
  final String? errorMessage;

  ForgetPasswordState copyWith({
    String? input,
    bool? isValid,
    ForgetPasswordStatus? status,
    String? verificationId,
    int? resendToken,
    String? errorMessage,
  }) {
    return ForgetPasswordState(
      input: input ?? this.input,
      isValid: isValid ?? this.isValid,
      status: status ?? this.status,
      verificationId: verificationId ?? this.verificationId,
      resendToken: resendToken ?? this.resendToken,
      errorMessage: errorMessage,
    );
  }

  static ForgetPasswordState initial() {
    return const ForgetPasswordState(
      input: '',
      isValid: false,
      status: ForgetPasswordStatus.initial,
      verificationId: null,
      resendToken: null,
      errorMessage: null,
    );
  }
}
