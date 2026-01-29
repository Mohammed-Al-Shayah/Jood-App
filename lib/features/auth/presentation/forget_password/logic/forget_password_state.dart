enum ForgetPasswordStatus { initial, loading, success, failure }

class ForgetPasswordState {
  const ForgetPasswordState({
    required this.email,
    required this.isValid,
    required this.status,
    this.errorMessage,
  });

  final String email;
  final bool isValid;
  final ForgetPasswordStatus status;
  final String? errorMessage;

  ForgetPasswordState copyWith({
    String? email,
    bool? isValid,
    ForgetPasswordStatus? status,
    String? errorMessage,
  }) {
    return ForgetPasswordState(
      email: email ?? this.email,
      isValid: isValid ?? this.isValid,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  static ForgetPasswordState initial() {
    return const ForgetPasswordState(
      email: '',
      isValid: false,
      status: ForgetPasswordStatus.initial,
      errorMessage: null,
    );
  }
}
