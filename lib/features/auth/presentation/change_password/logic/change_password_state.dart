class ChangePasswordState {
  const ChangePasswordState({
    required this.password,
    required this.confirmPassword,
    required this.showPassword,
    required this.showConfirmPassword,
    required this.isValid,
  });

  final String password;
  final String confirmPassword;
  final bool showPassword;
  final bool showConfirmPassword;
  final bool isValid;

  ChangePasswordState copyWith({
    String? password,
    String? confirmPassword,
    bool? showPassword,
    bool? showConfirmPassword,
    bool? isValid,
  }) {
    return ChangePasswordState(
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      showPassword: showPassword ?? this.showPassword,
      showConfirmPassword: showConfirmPassword ?? this.showConfirmPassword,
      isValid: isValid ?? this.isValid,
    );
  }

  static ChangePasswordState initial() {
    return const ChangePasswordState(
      password: '',
      confirmPassword: '',
      showPassword: false,
      showConfirmPassword: false,
      isValid: false,
    );
  }
}
