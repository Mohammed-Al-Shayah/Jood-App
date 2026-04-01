import 'package:firebase_auth/firebase_auth.dart';

import '../constants/app_strings.dart';
import 'auth_error.dart';

String mapFirebaseAuthException(
  FirebaseAuthException e, {
  String? userNotFoundMessage,
  String? operationNotAllowedMessage,
  String? requiresRecentLoginMessage,
  String? fallbackMessage,
}) {
  return _mapAuthCode(
    code: e.code,
    message: e.message,
    userNotFoundMessage: userNotFoundMessage,
    operationNotAllowedMessage: operationNotAllowedMessage,
    requiresRecentLoginMessage: requiresRecentLoginMessage,
    fallbackMessage: fallbackMessage,
  );
}

String mapAuthError(
  Object error, {
  String? userNotFoundMessage,
  String? operationNotAllowedMessage,
  String? requiresRecentLoginMessage,
  String? fallbackMessage,
}) {
  if (error is FirebaseAuthException) {
    return mapFirebaseAuthException(
      error,
      userNotFoundMessage: userNotFoundMessage,
      operationNotAllowedMessage: operationNotAllowedMessage,
      requiresRecentLoginMessage: requiresRecentLoginMessage,
      fallbackMessage: fallbackMessage,
    );
  }
  if (error is AppAuthException) {
    return _mapAuthCode(
      code: error.code,
      message: error.message,
      userNotFoundMessage: userNotFoundMessage,
      operationNotAllowedMessage: operationNotAllowedMessage,
      requiresRecentLoginMessage: requiresRecentLoginMessage,
      fallbackMessage: fallbackMessage,
    );
  }
  if (error is FirebaseException) {
    return mapFirebaseException(error, fallbackMessage: fallbackMessage);
  }
  return fallbackMessage ?? 'Request failed. Please try again.';
}

bool isAuthError(Object error) {
  return error is FirebaseException || error is AppAuthException;
}

String? authErrorCode(Object error) {
  if (error is FirebaseAuthException) return error.code;
  if (error is AppAuthException) return error.code;
  if (error is FirebaseException) return error.code;
  return null;
}

String? authErrorMessage(Object error) {
  if (error is FirebaseAuthException) return error.message;
  if (error is AppAuthException) return error.message;
  if (error is FirebaseException) return error.message;
  return null;
}

bool isReauthRequiredError(Object error) {
  final code = (authErrorCode(error) ?? '').toLowerCase();
  final message = (authErrorMessage(error) ?? '').toLowerCase();
  return code == 'requires-recent-login' ||
      code == 'unauthenticated' ||
      code == 'failed-precondition' ||
      code == 'permission-denied' ||
      message.contains('recent') ||
      message.contains('reauth');
}

String mapFirebaseException(FirebaseException e, {String? fallbackMessage}) {
  return e.message ?? fallbackMessage ?? 'Request failed. Please try again.';
}

String _mapAuthCode({
  required String code,
  String? message,
  String? userNotFoundMessage,
  String? operationNotAllowedMessage,
  String? requiresRecentLoginMessage,
  String? fallbackMessage,
}) {
  switch (code) {
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
      return message ?? 'Email already in use.';
    case 'invalid-verification-code':
      return 'Invalid OTP code.';
    case 'session-expired':
      return 'OTP session expired. Please resend the code.';
    case 'quota-exceeded':
      return 'SMS quota exceeded. Please try again later.';
    case 'resource-exhausted':
      return message ?? AppStrings.tooManyAttempts;
    case 'too-many-requests':
      return AppStrings.tooManyAttempts;
    case 'operation-not-allowed':
      return operationNotAllowedMessage ??
          'This operation is not allowed for this project.';
    case 'requires-recent-login':
      return requiresRecentLoginMessage ??
          'For security, please sign in again and retry.';
    default:
      return message ?? fallbackMessage ?? 'Request failed. Please try again.';
  }
}