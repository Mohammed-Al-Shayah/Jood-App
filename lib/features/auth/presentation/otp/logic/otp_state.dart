class OtpState {
  const OtpState({
    required this.code,
    required this.secondsLeft,
    required this.canResend,
  });

  final String code;
  final int secondsLeft;
  final bool canResend;

  bool get isValid => code.length == 4;

  OtpState copyWith({
    String? code,
    int? secondsLeft,
    bool? canResend,
  }) {
    return OtpState(
      code: code ?? this.code,
      secondsLeft: secondsLeft ?? this.secondsLeft,
      canResend: canResend ?? this.canResend,
    );
  }

  static OtpState initial() {
    return const OtpState(code: '', secondsLeft: 60, canResend: false);
  }
}
