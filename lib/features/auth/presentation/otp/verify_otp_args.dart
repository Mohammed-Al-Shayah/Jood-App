class VerifyOtpArgs {
  const VerifyOtpArgs({
    required this.verificationId,
    required this.fullName,
    required this.password,
    required this.phone,
    required this.country,
    required this.city,
    this.email,
    this.resendToken,
  });

  final String verificationId;
  final String fullName;
  final String password;
  final String phone;
  final String country;
  final String city;
  final String? email;
  final int? resendToken;
}
