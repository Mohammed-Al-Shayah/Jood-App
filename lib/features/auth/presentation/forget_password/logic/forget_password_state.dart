class ForgetPasswordState {
  const ForgetPasswordState({
    required this.email,
    required this.isValid,
  });

  final String email;
  final bool isValid;

  ForgetPasswordState copyWith({
    String? email,
    bool? isValid,
  }) {
    return ForgetPasswordState(
      email: email ?? this.email,
      isValid: isValid ?? this.isValid,
    );
  }

  static ForgetPasswordState initial() {
    return const ForgetPasswordState(email: '', isValid: false);
  }
}
