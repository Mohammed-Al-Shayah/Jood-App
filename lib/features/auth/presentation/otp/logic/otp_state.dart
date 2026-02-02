enum OtpStatus { initial, verifying, success, failure }

class OtpState {
  const OtpState({
    required this.code,
    required this.secondsLeft,
    required this.canResend,
    required this.status,
    required this.errorMessage,
  });

  final String code;
  final int secondsLeft;
  final bool canResend;
  final OtpStatus status;
  final String? errorMessage;

  bool get isValid => code.length >= 6;

  OtpState copyWith({
    String? code,
    int? secondsLeft,
    bool? canResend,
    OtpStatus? status,
    String? errorMessage,
  }) {
    return OtpState(
      code: code ?? this.code,
      secondsLeft: secondsLeft ?? this.secondsLeft,
      canResend: canResend ?? this.canResend,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  static OtpState initial() {
    return const OtpState(
      code: '',
      secondsLeft: 60,
      canResend: false,
      status: OtpStatus.initial,
      errorMessage: null,
    );
  }
}
