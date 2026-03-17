import 'package:firebase_auth/firebase_auth.dart';

import '../entities/otp_mode.dart';

abstract class AuthRepository {
  User? getCurrentUser();

  Future<UserCredential> loginWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<String> sendPhoneOtp({
    required String phoneNumber,
    OtpMode mode = OtpMode.auth,
  });

  Future<UserCredential?> verifyPhoneOtp({
    required String phoneNumber,
    required String verificationId,
    required String smsCode,
    OtpMode mode = OtpMode.auth,
  });

  Future<void> sendPasswordResetEmail(String email);

  Future<List<String>> fetchSignInMethodsForEmail(String email);

  Future<void> sendEmailVerification(User user);

  Future<void> signOut();

  Future<void> reloadUser(User user);

  Future<void> linkEmailPassword({
    required User user,
    required String email,
    required String password,
  });

  Future<void> updatePassword({
    required User user,
    required String newPassword,
  });

  Future<void> verifyBeforeUpdateEmail({
    required User user,
    required String newEmail,
  });
}
