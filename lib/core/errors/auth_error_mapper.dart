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
  return fallbackMessage ?? AppStrings.requestFailedPleaseTryAgain;
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
  return e.message ?? fallbackMessage ?? AppStrings.requestFailedPleaseTryAgain;
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
      return AppStrings.invalidPhoneNumber;
    case 'invalid-email':
      return AppStrings.invalidEmailAddress;
    case 'user-disabled':
      return AppStrings.thisAccountHasBeenDisabled;
    case 'user-not-found':
      return userNotFoundMessage ?? AppStrings.noUserFound;
    case 'wrong-password':
      return AppStrings.incorrectPassword;
    case 'invalid-credential':
      return AppStrings.invalidCredentials;
    case 'weak-password':
      return AppStrings.passwordIsTooWeak;
    case 'email-already-in-use':
    case 'credential-already-in-use':
      return message ?? AppStrings.emailAlreadyInUse;
    case 'invalid-verification-code':
      return AppStrings.invalidOtpCode;
    case 'session-expired':
      return AppStrings.otpSessionExpiredResendCode;
    case 'quota-exceeded':
      return AppStrings.smsQuotaExceeded;
    case 'resource-exhausted':
      return message ?? AppStrings.tooManyAttempts;
    case 'too-many-requests':
      return AppStrings.tooManyAttempts;
    case 'operation-not-allowed':
      return operationNotAllowedMessage ??
          AppStrings.operationNotAllowedForProject;
    case 'requires-recent-login':
      return requiresRecentLoginMessage ?? AppStrings.signInAgainAndRetry;
    default:
      return message ??
          fallbackMessage ??
          AppStrings.requestFailedPleaseTryAgain;
  }
}
