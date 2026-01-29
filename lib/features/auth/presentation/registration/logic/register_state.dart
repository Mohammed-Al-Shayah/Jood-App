enum RegisterStatus { initial, loading, success, failure }

class RegisterState {
  const RegisterState({
    required this.fullName,
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.phone,
    required this.country,
    required this.city,
    required this.termsAccepted,
    required this.showPassword,
    required this.showConfirmPassword,
    required this.isValid,
    required this.status,
    this.errorMessage,
  });

  final String fullName;
  final String email;
  final String password;
  final String confirmPassword;
  final String phone;
  final String country;
  final String city;
  final bool termsAccepted;
  final bool showPassword;
  final bool showConfirmPassword;
  final bool isValid;
  final RegisterStatus status;
  final String? errorMessage;

  RegisterState copyWith({
    String? fullName,
    String? email,
    String? password,
    String? confirmPassword,
    String? phone,
    String? country,
    String? city,
    bool? termsAccepted,
    bool? showPassword,
    bool? showConfirmPassword,
    bool? isValid,
    RegisterStatus? status,
    String? errorMessage,
  }) {
    return RegisterState(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      phone: phone ?? this.phone,
      country: country ?? this.country,
      city: city ?? this.city,
      termsAccepted: termsAccepted ?? this.termsAccepted,
      showPassword: showPassword ?? this.showPassword,
      showConfirmPassword: showConfirmPassword ?? this.showConfirmPassword,
      isValid: isValid ?? this.isValid,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  static RegisterState initial() {
    return const RegisterState(
      fullName: '',
      email: '',
      password: '',
      confirmPassword: '',
      phone: '',
      country: '',
      city: '',
      termsAccepted: false,
      showPassword: false,
      showConfirmPassword: false,
      isValid: false,
      status: RegisterStatus.initial,
      errorMessage: null,
    );
  }
}
