import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  User? getCurrentUser();

  Future<UserCredential> loginWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<UserCredential> signInWithPhoneCredential(AuthCredential credential);

  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    Duration timeout = const Duration(seconds: 60),
    int? forceResendingToken,
    required PhoneVerificationCompleted verificationCompleted,
    required PhoneVerificationFailed verificationFailed,
    required PhoneCodeSent codeSent,
    required PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout,
  });

  Future<void> sendPasswordResetEmail(String email);

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
