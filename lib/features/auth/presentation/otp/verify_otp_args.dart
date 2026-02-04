enum OtpFlow { register, login, resetPassword }

class VerifyOtpArgs {
  const VerifyOtpArgs._({
    required this.verificationId,
    required this.phone,
    required this.flow,
    this.email,
    this.fullName,
    this.password,
    this.country,
    this.city,
    this.resendToken,
  });

  factory VerifyOtpArgs.registration({
    required String verificationId,
    required String phone,
    required String fullName,
    required String password,
    required String country,
    required String city,
    String? email,
    int? resendToken,
  }) {
    return VerifyOtpArgs._(
      verificationId: verificationId,
      phone: phone,
      flow: OtpFlow.register,
      fullName: fullName,
      password: password,
      country: country,
      city: city,
      email: email,
      resendToken: resendToken,
    );
  }

  factory VerifyOtpArgs.login({
    required String verificationId,
    required String phone,
    int? resendToken,
  }) {
    return VerifyOtpArgs._(
      verificationId: verificationId,
      phone: phone,
      flow: OtpFlow.login,
      resendToken: resendToken,
    );
  }

  factory VerifyOtpArgs.resetPassword({
    required String verificationId,
    required String phone,
    int? resendToken,
  }) {
    return VerifyOtpArgs._(
      verificationId: verificationId,
      phone: phone,
      flow: OtpFlow.resetPassword,
      resendToken: resendToken,
    );
  }

  final String verificationId;
  final String phone;
  final OtpFlow flow;
  final String? fullName;
  final String? password;
  final String? country;
  final String? city;
  final String? email;
  final int? resendToken;
}
