enum LoginStatus {
  initial,
  loading,
  emailNotVerified,
  verificationLinkSent,
  success,
  failure,
}

enum LoginMethod { email, phone }

class LoginState {
  const LoginState({
    required this.identifier,
    required this.loginMethod,
    required this.phoneIso,
    required this.password,
    required this.rememberMe,
    required this.showPassword,
    required this.isValid,
    required this.status,
    required this.unverifiedEmail,
    this.errorMessage,
  });

  final String identifier;
  final LoginMethod loginMethod;
  final String phoneIso;
  final String password;
  final bool rememberMe;
  final bool showPassword;
  final bool isValid;
  final LoginStatus status;
  final String? unverifiedEmail;
  final String? errorMessage;

  LoginState copyWith({
    String? identifier,
    LoginMethod? loginMethod,
    String? phoneIso,
    String? password,
    bool? rememberMe,
    bool? showPassword,
    bool? isValid,
    LoginStatus? status,
    String? unverifiedEmail,
    String? errorMessage,
  }) {
    return LoginState(
      identifier: identifier ?? this.identifier,
      loginMethod: loginMethod ?? this.loginMethod,
      phoneIso: phoneIso ?? this.phoneIso,
      password: password ?? this.password,
      rememberMe: rememberMe ?? this.rememberMe,
      showPassword: showPassword ?? this.showPassword,
      isValid: isValid ?? this.isValid,
      status: status ?? this.status,
      unverifiedEmail: unverifiedEmail ?? this.unverifiedEmail,
      errorMessage: errorMessage,
    );
  }

  static LoginState initial() {
    return const LoginState(
      identifier: '',
      loginMethod: LoginMethod.phone,
      phoneIso: 'OM',
      password: '',
      rememberMe: false,
      showPassword: false,
      isValid: false,
      status: LoginStatus.initial,
      unverifiedEmail: null,
      errorMessage: null,
    );
  }
}
