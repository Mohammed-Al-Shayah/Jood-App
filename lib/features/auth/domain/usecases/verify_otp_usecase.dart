import '../entities/auth_credential_entity.dart';
import '../entities/otp_mode.dart';
import '../repositories/auth_repository.dart';

class VerifyOtpUseCase {
  VerifyOtpUseCase(this._repository);

  final AuthRepository _repository;

  Future<AuthCredentialEntity?> call({
    required String phoneNumber,
    required String verificationId,
    required String smsCode,
    OtpMode mode = OtpMode.auth,
  }) {
    return _repository.verifyPhoneOtp(
      phoneNumber: phoneNumber,
      verificationId: verificationId,
      smsCode: smsCode,
      mode: mode,
    );
  }
}
