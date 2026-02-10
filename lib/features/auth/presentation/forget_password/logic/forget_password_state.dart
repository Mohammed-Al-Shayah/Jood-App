enum ForgetPasswordStatus { initial, loading, success, phoneOtpSent, failure }
enum ForgetPasswordMethod { email, phone }

class ForgetPasswordState {
  const ForgetPasswordState({
    required this.input,
    required this.isValid,
    required this.status,
    required this.method,
    required this.phoneIso,
    this.verificationId,
    this.resendToken,
    this.errorMessage,
  });

  final String input;
  final bool isValid;
  final ForgetPasswordStatus status;
  final ForgetPasswordMethod method;
  final String phoneIso;
  final String? verificationId;
  final int? resendToken;
  final String? errorMessage;

  ForgetPasswordState copyWith({
    String? input,
    bool? isValid,
    ForgetPasswordStatus? status,
    ForgetPasswordMethod? method,
    String? phoneIso,
    String? verificationId,
    int? resendToken,
    String? errorMessage,
  }) {
    return ForgetPasswordState(
      input: input ?? this.input,
      isValid: isValid ?? this.isValid,
      status: status ?? this.status,
      method: method ?? this.method,
      phoneIso: phoneIso ?? this.phoneIso,
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
      method: ForgetPasswordMethod.email,
      phoneIso: 'OM',
      verificationId: null,
      resendToken: null,
      errorMessage: null,
    );
  }
}
