class LoginState {
  const LoginState({
    required this.email,
    required this.password,
    required this.rememberMe,
    required this.showPassword,
    required this.isValid,
  });

  final String email;
  final String password;
  final bool rememberMe;
  final bool showPassword;
  final bool isValid;

  LoginState copyWith({
    String? email,
    String? password,
    bool? rememberMe,
    bool? showPassword,
    bool? isValid,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      rememberMe: rememberMe ?? this.rememberMe,
      showPassword: showPassword ?? this.showPassword,
      isValid: isValid ?? this.isValid,
    );
  }

  static LoginState initial() {
    return const LoginState(
      email: '',
      password: '',
      rememberMe: false,
      showPassword: false,
      isValid: false,
    );
  }
}
