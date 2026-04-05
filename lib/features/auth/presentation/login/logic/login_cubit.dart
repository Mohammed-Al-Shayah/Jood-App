import 'package:firebase_auth/firebase_auth.dart';

import '../../../../../core/bloc/safe_cubit.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/errors/auth_error.dart';
import '../../../../../core/errors/auth_error_mapper.dart';
import '../../../../../core/utils/auth_validators.dart';
import '../../../../../features/users/domain/usecases/get_user_by_phone_usecase.dart';
import '../../../../../features/users/domain/usecases/sync_auth_user_usecase.dart';
import '../../../domain/usecases/get_current_user_usecase.dart';
import '../../../domain/usecases/login_with_email_usecase.dart';
import '../../../domain/usecases/reload_user_usecase.dart';
import '../../../domain/usecases/send_email_verification_usecase.dart';
import '../../../domain/usecases/sign_out_usecase.dart';
import 'login_state.dart';

class LoginCubit extends SafeCubit<LoginState> {
  LoginCubit({
    required LoginWithEmailUseCase loginWithEmail,
    required SendEmailVerificationUseCase sendEmailVerification,
    required SignOutUseCase signOut,
    required GetCurrentUserUseCase getCurrentUser,
    required ReloadUserUseCase reloadUser,
    required GetUserByPhoneUseCase getUserByPhone,
    required SyncAuthUserUseCase syncAuthUser,
  }) : _loginWithEmail = loginWithEmail,
       _sendEmailVerification = sendEmailVerification,
       _signOut = signOut,
       _getCurrentUser = getCurrentUser,
       _reloadUser = reloadUser,
       _getUserByPhone = getUserByPhone,
       _syncAuthUser = syncAuthUser,
       super(LoginState.initial());

  final LoginWithEmailUseCase _loginWithEmail;
  final SendEmailVerificationUseCase _sendEmailVerification;
  final SignOutUseCase _signOut;
  final GetCurrentUserUseCase _getCurrentUser;
  final ReloadUserUseCase _reloadUser;
  final GetUserByPhoneUseCase _getUserByPhone;
  final SyncAuthUserUseCase _syncAuthUser;

  void updateIdentifier(String value) {
    emitSafe(_update(state.copyWith(identifier: value)));
  }

  void updatePhoneIso(String value) {
    if (value.trim().isEmpty) return;
    emitSafe(state.copyWith(phoneIso: value));
  }

  void updatePassword(String value) {
    emitSafe(_update(state.copyWith(password: value)));
  }

  void setLoginMethod(LoginMethod method) {
    emitSafe(
      _update(
        state.copyWith(
          loginMethod: method,
          identifier: '',
          status: LoginStatus.initial,
          errorMessage: null,
          unverifiedEmail: null,
        ),
      ),
    );
  }

  void toggleRemember() {
    emitSafe(state.copyWith(rememberMe: !state.rememberMe));
  }

  void togglePasswordVisibility() {
    emitSafe(state.copyWith(showPassword: !state.showPassword));
  }

  void switchToPhoneLogin() {
    setLoginMethod(LoginMethod.phone);
  }

  Future<void> resendActivationLink() async {
    final email = state.unverifiedEmail?.trim() ?? '';
    if (email.isEmpty || state.password.trim().isEmpty) {
      emitSafe(
        state.copyWith(
          status: LoginStatus.failure,
          errorMessage: AppStrings.enterPasswordThenResendActivationLink,
        ),
      );
      return;
    }

    emitSafe(state.copyWith(status: LoginStatus.loading, errorMessage: null));
    try {
      final result = await _loginWithEmail(
        email: email,
        password: state.password,
      );
      final user = result.user;
      if (user != null) {
        await _sendEmailVerification(user);
      }
      await _signOut();
      emitSafe(
        state.copyWith(
          status: LoginStatus.verificationLinkSent,
          errorMessage: AppStrings.activationLinkResentCheckInbox,
        ),
      );
    } catch (error) {
      emitSafe(
        state.copyWith(
          status: LoginStatus.failure,
          errorMessage: isAuthError(error)
              ? mapAuthError(
                  error,
                  userNotFoundMessage: AppStrings.noUserFoundForEmail,
                  operationNotAllowedMessage:
                      AppStrings.emailPasswordAccountsNotEnabled,
                  fallbackMessage: AppStrings.loginFailedPleaseTryAgain,
                )
              : AppStrings.somethingWentWrong,
        ),
      );
    }
  }

  Future<void> submit() async {
    if (!state.isValid || state.status == LoginStatus.loading) return;

    emitSafe(state.copyWith(status: LoginStatus.loading, errorMessage: null));
    try {
      final input = state.identifier.trim();
      final credential = state.loginMethod == LoginMethod.phone
          ? await _signInWithPhoneAndPassword(
              AuthValidators.normalizePhone(input),
              state.password,
            )
          : await _loginWithEmail(email: input, password: state.password);

      final user = credential.user;
      if (user == null) {
        emitSafe(
          state.copyWith(
            status: LoginStatus.failure,
            errorMessage: AppStrings.unableToSignInPleaseTryAgain,
          ),
        );
        return;
      }

      await _reloadUser(user);
      final refreshed = _getCurrentUser();
      if (refreshed == null) {
        emitSafe(
          state.copyWith(
            status: LoginStatus.failure,
            errorMessage: AppStrings.unableToSignInPleaseTryAgain,
          ),
        );
        return;
      }

      if (AuthValidators.isEmail(input) && !refreshed.emailVerified) {
        try {
          await _sendEmailVerification(refreshed);
        } catch (_) {}
        await _signOut();
        emitSafe(
          state.copyWith(
            status: LoginStatus.emailNotVerified,
            unverifiedEmail: input,
            errorMessage: AppStrings.pleaseVerifyYourEmailFirst,
          ),
        );
        return;
      }

      await _syncAuthUser(refreshed);
      emitSafe(state.copyWith(status: LoginStatus.success));
    } catch (error) {
      final isEmailLogin = state.loginMethod == LoginMethod.email;
      emitSafe(
        state.copyWith(
          status: LoginStatus.failure,
          errorMessage: isAuthError(error)
              ? mapAuthError(
                  error,
                  userNotFoundMessage: isEmailLogin
                      ? AppStrings.noUserFoundForEmail
                      : AppStrings.noUserFoundForPhone,
                  operationNotAllowedMessage:
                      AppStrings.emailPasswordAccountsNotEnabled,
                  fallbackMessage: AppStrings.loginFailedPleaseTryAgain,
                )
              : AppStrings.somethingWentWrong,
        ),
      );
    }
  }

  Future<UserCredential> _signInWithPhoneAndPassword(
    String normalizedPhone,
    String password,
  ) async {
    final user = await _getUserByPhone(normalizedPhone);
    final email = user?.email.trim() ?? '';
    if (email.isEmpty) {
      throw AppAuthException(
        code: 'user-not-found',
        message: AppStrings.noUserFoundForPhone,
      );
    }
    return _loginWithEmail(email: email, password: password);
  }

  LoginState _update(LoginState next) {
    final input = next.identifier.trim();
    final isIdentifierValid = next.loginMethod == LoginMethod.phone
        ? AuthValidators.isPhone(input)
        : AuthValidators.isEmail(input);
    final valid = isIdentifierValid && AuthValidators.isPassword(next.password);
    return next.copyWith(isValid: valid);
  }
}
