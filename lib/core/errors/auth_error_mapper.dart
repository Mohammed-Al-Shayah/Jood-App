import 'package:firebase_auth/firebase_auth.dart';
import '../constants/app_strings.dart';

String mapFirebaseAuthException(
  FirebaseAuthException e, {
  String? userNotFoundMessage,
  String? operationNotAllowedMessage,
  String? requiresRecentLoginMessage,
  String? fallbackMessage,
}) {
  switch (e.code) {
    case 'invalid-phone-number':
      return 'Invalid phone number.';
    case 'invalid-email':
      return 'Invalid email address.';
    case 'user-disabled':
      return 'This account has been disabled.';
    case 'user-not-found':
      return userNotFoundMessage ?? 'No user found.';
    case 'wrong-password':
      return 'Incorrect password.';
    case 'invalid-credential':
      return 'Invalid credentials.';
    case 'weak-password':
      return 'Password is too weak.';
    case 'email-already-in-use':
    case 'credential-already-in-use':
      return 'Email already in use.';
    case 'invalid-verification-code':
      return 'Invalid OTP code.';
    case 'session-expired':
      return 'OTP session expired. Please resend the code.';
    case 'quota-exceeded':
      return 'SMS quota exceeded. Please try again later.';
    case 'too-many-requests':
      return AppStrings.tooManyAttempts;
    case 'operation-not-allowed':
      return operationNotAllowedMessage ??
          'This operation is not allowed for this project.';
    case 'requires-recent-login':
      return requiresRecentLoginMessage ??
          'For security, please sign in again and retry.';
    default:
      return e.message ??
          fallbackMessage ??
          'Request failed. Please try again.';
  }
}

String mapFirebaseException(FirebaseException e, {String? fallbackMessage}) {
  return e.message ?? fallbackMessage ?? 'Request failed. Please try again.';
}
