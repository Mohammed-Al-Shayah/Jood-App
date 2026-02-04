enum ChangePasswordStatus { initial, loading, success, failure }

class ChangePasswordState {
  const ChangePasswordState({
    required this.password,
    required this.confirmPassword,
    required this.showPassword,
    required this.showConfirmPassword,
    required this.isValid,
    required this.status,
    this.errorMessage,
  });

  final String password;
  final String confirmPassword;
  final bool showPassword;
  final bool showConfirmPassword;
  final bool isValid;
  final ChangePasswordStatus status;
  final String? errorMessage;

  ChangePasswordState copyWith({
    String? password,
    String? confirmPassword,
    bool? showPassword,
    bool? showConfirmPassword,
    bool? isValid,
    ChangePasswordStatus? status,
    String? errorMessage,
  }) {
    return ChangePasswordState(
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      showPassword: showPassword ?? this.showPassword,
      showConfirmPassword: showConfirmPassword ?? this.showConfirmPassword,
      isValid: isValid ?? this.isValid,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  static ChangePasswordState initial() {
    return const ChangePasswordState(
      password: '',
      confirmPassword: '',
      showPassword: false,
      showConfirmPassword: false,
      isValid: false,
      status: ChangePasswordStatus.initial,
      errorMessage: null,
    );
  }
}
