import '../entities/otp_mode.dart';
import '../repositories/auth_repository.dart';

class SendPhoneOtpUseCase {
  SendPhoneOtpUseCase(this._repository);

  final AuthRepository _repository;

  Future<String> call({
    required String phoneNumber,
    OtpMode mode = OtpMode.auth,
    String? turnstileToken,
  }) {
    return _repository.sendPhoneOtp(
      phoneNumber: phoneNumber,
      mode: mode,
      turnstileToken: turnstileToken,
    );
  }
}
