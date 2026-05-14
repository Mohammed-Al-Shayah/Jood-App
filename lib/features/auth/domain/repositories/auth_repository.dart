import '../entities/auth_credential_entity.dart';
import '../entities/auth_user_entity.dart';
import '../entities/otp_mode.dart';

abstract class AuthRepository {
  AuthUserEntity? getCurrentUser();

  Stream<AuthUserEntity?> authStateChanges();

  Future<AuthCredentialEntity> loginWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<String> sendPhoneOtp({
    required String phoneNumber,
    OtpMode mode = OtpMode.auth,
    String? turnstileToken,
  });

  Future<AuthCredentialEntity?> verifyPhoneOtp({
    required String phoneNumber,
    required String verificationId,
    required String smsCode,
    OtpMode mode = OtpMode.auth,
  });

  Future<void> sendPasswordResetEmail(String email);

  Future<List<String>> fetchSignInMethodsForEmail(String email);

  Future<void> sendEmailVerification(AuthUserEntity user);

  Future<void> signOut();

  Future<void> deleteAccount();

  Future<void> reloadUser(AuthUserEntity user);

  Future<void> linkEmailPassword({
    required AuthUserEntity user,
    required String email,
    required String password,
  });

  Future<void> updatePassword({
    required AuthUserEntity user,
    required String newPassword,
  });

  Future<void> verifyBeforeUpdateEmail({
    required AuthUserEntity user,
    required String newEmail,
  });
}
