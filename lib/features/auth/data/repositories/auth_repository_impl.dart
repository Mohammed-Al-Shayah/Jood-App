import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._auth);

  final FirebaseAuth _auth;

  @override
  User? getCurrentUser() => _auth.currentUser;

  @override
  Future<UserCredential> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  @override
  Future<UserCredential> signInWithPhoneCredential(AuthCredential credential) {
    return _auth.signInWithCredential(credential);
  }

  @override
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    Duration timeout = const Duration(seconds: 60),
    int? forceResendingToken,
    required PhoneVerificationCompleted verificationCompleted,
    required PhoneVerificationFailed verificationFailed,
    required PhoneCodeSent codeSent,
    required PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout,
  }) {
    return _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: timeout,
      forceResendingToken: forceResendingToken,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }

  @override
  Future<void> sendPasswordResetEmail(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<void> sendEmailVerification(User user) {
    return user.sendEmailVerification();
  }

  @override
  Future<void> signOut() {
    return _auth.signOut();
  }

  @override
  Future<void> reloadUser(User user) {
    return user.reload();
  }

  @override
  Future<void> linkEmailPassword({
    required User user,
    required String email,
    required String password,
  }) {
    final credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );
    return user.linkWithCredential(credential);
  }

  @override
  Future<void> updatePassword({
    required User user,
    required String newPassword,
  }) {
    return user.updatePassword(newPassword);
  }

  @override
  Future<void> verifyBeforeUpdateEmail({
    required User user,
    required String newEmail,
  }) {
    return user.verifyBeforeUpdateEmail(newEmail);
  }
}
