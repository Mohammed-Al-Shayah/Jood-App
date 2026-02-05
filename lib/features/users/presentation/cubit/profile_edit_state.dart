enum ProfileEditStatus {
  idle,
  saving,
  otpSending,
  otpSent,
  otpVerifying,
  success,
  failure,
}

class ProfileEditState {
  const ProfileEditState({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.phoneIso,
    required this.country,
    required this.city,
    required this.otpCode,
    required this.secondsLeft,
    required this.canResend,
    required this.verificationId,
    required this.resendToken,
    required this.status,
    this.errorMessage,
    this.successMessage,
  });

  final String fullName;
  final String email;
  final String phone;
  final String phoneIso;
  final String country;
  final String city;
  final String otpCode;
  final int secondsLeft;
  final bool canResend;
  final String? verificationId;
  final int? resendToken;
  final ProfileEditStatus status;
  final String? errorMessage;
  final String? successMessage;

  ProfileEditState copyWith({
    String? fullName,
    String? email,
    String? phone,
    String? phoneIso,
    String? country,
    String? city,
    String? otpCode,
    int? secondsLeft,
    bool? canResend,
    String? verificationId,
    int? resendToken,
    ProfileEditStatus? status,
    String? errorMessage,
    String? successMessage,
  }) {
    return ProfileEditState(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      phoneIso: phoneIso ?? this.phoneIso,
      country: country ?? this.country,
      city: city ?? this.city,
      otpCode: otpCode ?? this.otpCode,
      secondsLeft: secondsLeft ?? this.secondsLeft,
      canResend: canResend ?? this.canResend,
      verificationId: verificationId ?? this.verificationId,
      resendToken: resendToken ?? this.resendToken,
      status: status ?? this.status,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  static ProfileEditState initial({
    required String fullName,
    required String email,
    required String phone,
    required String country,
    required String city,
    String phoneIso = 'OM',
  }) {
    return ProfileEditState(
      fullName: fullName,
      email: email,
      phone: phone,
      phoneIso: phoneIso,
      country: country,
      city: city,
      otpCode: '',
      secondsLeft: 60,
      canResend: false,
      verificationId: null,
      resendToken: null,
      status: ProfileEditStatus.idle,
      errorMessage: null,
      successMessage: null,
    );
  }
}
