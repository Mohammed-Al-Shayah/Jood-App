enum LoginStatus { initial, loading, success, failure }

class LoginState {
  const LoginState({
    required this.email,
    required this.password,
    required this.rememberMe,
    required this.showPassword,
    required this.isValid,
    required this.status,
    this.errorMessage,
  });

  final String email;
  final String password;
  final bool rememberMe;
  final bool showPassword;
  final bool isValid;
  final LoginStatus status;
  final String? errorMessage;

  LoginState copyWith({
    String? email,
    String? password,
    bool? rememberMe,
    bool? showPassword,
    bool? isValid,
    LoginStatus? status,
    String? errorMessage,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      rememberMe: rememberMe ?? this.rememberMe,
      showPassword: showPassword ?? this.showPassword,
      isValid: isValid ?? this.isValid,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  static LoginState initial() {
    return const LoginState(
      email: '',
      password: '',
      rememberMe: false,
      showPassword: false,
      isValid: false,
      status: LoginStatus.initial,
      errorMessage: null,
    );
  }
}
