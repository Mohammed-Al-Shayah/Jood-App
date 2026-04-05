import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/errors/auth_error.dart';
import '../../../../core/utils/auth_validators.dart';
import '../../../../core/utils/device_identity.dart';
import '../../domain/entities/otp_mode.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._auth, this._functions);

  final FirebaseAuth _auth;
  final FirebaseFunctions _functions;

  @override
  User? getCurrentUser() => _auth.currentUser;

  @override
  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }

  @override
  Future<UserCredential> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  @override
  Future<String> sendPhoneOtp({
    required String phoneNumber,
    OtpMode mode = OtpMode.auth,
  }) {
    return _sendPhoneOtp(phoneNumber: phoneNumber, mode: mode);
  }

  @override
  Future<UserCredential?> verifyPhoneOtp({
    required String phoneNumber,
    required String verificationId,
    required String smsCode,
    OtpMode mode = OtpMode.auth,
  }) {
    return _verifyPhoneOtp(
      phoneNumber: phoneNumber,
      verificationId: verificationId,
      smsCode: smsCode,
      mode: mode,
    );
  }

  @override
  Future<void> sendPasswordResetEmail(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<List<String>> fetchSignInMethodsForEmail(String email) {
    return _auth.fetchSignInMethodsForEmail(email);
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
  Future<void> deleteAccount() async {
    await _functions.httpsCallable('deleteAccount').call();
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

  Future<String> _sendPhoneOtp({
    required String phoneNumber,
    required OtpMode mode,
  }) async {
    final normalizedPhone = AuthValidators.normalizePhone(phoneNumber);
    final deviceId = await DeviceIdentity.getOrCreateId();

    try {
      final result = await _functions.httpsCallable('sendSmsOtp').call({
        'phoneNumber': normalizedPhone,
        'mode': mode.apiValue,
        'deviceId': deviceId,
      });
      final data = _asMap(result.data);
      final verificationId = (data['verificationId']?.toString() ?? '').trim();
      if (verificationId.isEmpty) {
        throw FirebaseAuthException(
          code: 'session-expired',
          message: AppStrings.unableToStartPhoneVerification,
        );
      }
      return verificationId;
    } on FirebaseFunctionsException catch (e) {
      throw _mapFunctionsException(e);
    }
  }

  Future<UserCredential?> _verifyPhoneOtp({
    required String phoneNumber,
    required String verificationId,
    required String smsCode,
    required OtpMode mode,
  }) async {
    final normalizedPhone = AuthValidators.normalizePhone(phoneNumber);

    try {
      final result = await _functions.httpsCallable('verifySmsOtp').call({
        'phoneNumber': normalizedPhone,
        'verificationId': verificationId,
        'code': smsCode.trim(),
        'mode': mode.apiValue,
      });

      if (mode == OtpMode.updatePhone) {
        await _auth.currentUser?.reload();
        return null;
      }

      final data = _asMap(result.data);
      final customToken = (data['customToken']?.toString() ?? '').trim();
      if (customToken.isEmpty) {
        throw FirebaseAuthException(
          code: 'invalid-credential',
          message: AppStrings.unableToVerifyPhonePleaseTryAgain,
        );
      }

      final credential = await _auth.signInWithCustomToken(customToken);
      await credential.user?.reload();
      return credential;
    } on FirebaseFunctionsException catch (e) {
      throw _mapFunctionsException(e);
    }
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<Object?, Object?>) {
      return data.map((key, value) => MapEntry(key.toString(), value));
    }
    return <String, dynamic>{};
  }

  Exception _mapFunctionsException(FirebaseFunctionsException e) {
    final details = _asMap(e.details);
    switch (e.code) {
      case 'invalid-argument':
        return FirebaseAuthException(
          code: 'invalid-phone-number',
          message: e.message,
        );
      case 'permission-denied':
        return FirebaseAuthException(
          code: 'invalid-verification-code',
          message: e.message,
        );
      case 'deadline-exceeded':
      case 'not-found':
        return FirebaseAuthException(
          code: 'session-expired',
          message: e.message,
        );
      case 'resource-exhausted':
      case 'failed-precondition':
      case 'unauthenticated':
      default:
        return AppAuthException(
          code: e.code,
          message: e.message,
          details: details.isEmpty ? null : details,
        );
    }
  }
}
