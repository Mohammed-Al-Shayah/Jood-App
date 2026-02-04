enum RegisterStatus { initial, loading, phoneOtpSent, phoneVerified, failure }

class RegisterState {
  const RegisterState({
    required this.fullName,
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.phone,
    required this.phoneIso,
    required this.country,
    required this.city,
    required this.termsAccepted,
    required this.showPassword,
    required this.showConfirmPassword,
    required this.isValid,
    required this.status,
    required this.fullNameTouched,
    required this.emailTouched,
    required this.passwordTouched,
    required this.confirmPasswordTouched,
    required this.phoneTouched,
    required this.countryTouched,
    required this.cityTouched,
    required this.termsTouched,
    required this.submitAttempted,
    required this.fullNameError,
    required this.emailError,
    required this.passwordError,
    required this.confirmPasswordError,
    required this.phoneError,
    required this.countryError,
    required this.cityError,
    required this.termsError,
    required this.verificationId,
    required this.resendToken,
    this.errorMessage,
  });

  final String fullName;
  final String email;
  final String password;
  final String confirmPassword;
  final String phone;
  final String phoneIso;
  final String country;
  final String city;
  final bool termsAccepted;
  final bool showPassword;
  final bool showConfirmPassword;
  final bool isValid;
  final RegisterStatus status;
  final bool fullNameTouched;
  final bool emailTouched;
  final bool passwordTouched;
  final bool confirmPasswordTouched;
  final bool phoneTouched;
  final bool countryTouched;
  final bool cityTouched;
  final bool termsTouched;
  final bool submitAttempted;
  final String? fullNameError;
  final String? emailError;
  final String? passwordError;
  final String? confirmPasswordError;
  final String? phoneError;
  final String? countryError;
  final String? cityError;
  final String? termsError;
  final String? verificationId;
  final int? resendToken;
  final String? errorMessage;

  RegisterState copyWith({
    String? fullName,
    String? email,
    String? password,
    String? confirmPassword,
    String? phone,
    String? phoneIso,
    String? country,
    String? city,
    bool? termsAccepted,
    bool? showPassword,
    bool? showConfirmPassword,
    bool? isValid,
    RegisterStatus? status,
    bool? fullNameTouched,
    bool? emailTouched,
    bool? passwordTouched,
    bool? confirmPasswordTouched,
    bool? phoneTouched,
    bool? countryTouched,
    bool? cityTouched,
    bool? termsTouched,
    bool? submitAttempted,
    String? fullNameError,
    String? emailError,
    String? passwordError,
    String? confirmPasswordError,
    String? phoneError,
    String? countryError,
    String? cityError,
    String? termsError,
    String? verificationId,
    int? resendToken,
    String? errorMessage,
  }) {
    return RegisterState(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      phone: phone ?? this.phone,
      phoneIso: phoneIso ?? this.phoneIso,
      country: country ?? this.country,
      city: city ?? this.city,
      termsAccepted: termsAccepted ?? this.termsAccepted,
      showPassword: showPassword ?? this.showPassword,
      showConfirmPassword: showConfirmPassword ?? this.showConfirmPassword,
      isValid: isValid ?? this.isValid,
      status: status ?? this.status,
      fullNameTouched: fullNameTouched ?? this.fullNameTouched,
      emailTouched: emailTouched ?? this.emailTouched,
      passwordTouched: passwordTouched ?? this.passwordTouched,
      confirmPasswordTouched:
          confirmPasswordTouched ?? this.confirmPasswordTouched,
      phoneTouched: phoneTouched ?? this.phoneTouched,
      countryTouched: countryTouched ?? this.countryTouched,
      cityTouched: cityTouched ?? this.cityTouched,
      termsTouched: termsTouched ?? this.termsTouched,
      submitAttempted: submitAttempted ?? this.submitAttempted,
      fullNameError: fullNameError,
      emailError: emailError,
      passwordError: passwordError,
      confirmPasswordError: confirmPasswordError,
      phoneError: phoneError,
      countryError: countryError,
      cityError: cityError,
      termsError: termsError,
      verificationId: verificationId ?? this.verificationId,
      resendToken: resendToken ?? this.resendToken,
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
      phoneIso: 'AE',
      country: '',
      city: '',
      termsAccepted: false,
      showPassword: false,
      showConfirmPassword: false,
      isValid: false,
      status: RegisterStatus.initial,
      fullNameTouched: false,
      emailTouched: false,
      passwordTouched: false,
      confirmPasswordTouched: false,
      phoneTouched: false,
      countryTouched: false,
      cityTouched: false,
      termsTouched: false,
      submitAttempted: false,
      fullNameError: null,
      emailError: null,
      passwordError: null,
      confirmPasswordError: null,
      phoneError: null,
      countryError: null,
      cityError: null,
      termsError: null,
      verificationId: null,
      resendToken: null,
      errorMessage: null,
    );
  }
}
