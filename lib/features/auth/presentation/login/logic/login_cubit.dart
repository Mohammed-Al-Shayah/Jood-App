import 'package:firebase_auth/firebase_auth.dart';

import '../../../../../core/bloc/safe_cubit.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/errors/auth_error_mapper.dart';
import '../../../../../core/utils/auth_validators.dart';
import '../../../../../features/users/domain/usecases/get_user_by_phone_usecase.dart';
import '../../../../../features/users/domain/usecases/sync_auth_user_usecase.dart';
import 'login_state.dart';

class LoginCubit extends SafeCubit<LoginState> {
  LoginCubit({
    required FirebaseAuth auth,
    required GetUserByPhoneUseCase getUserByPhone,
    required SyncAuthUserUseCase syncAuthUser,
  }) : _auth = auth,
       _getUserByPhone = getUserByPhone,
       _syncAuthUser = syncAuthUser,
       super(LoginState.initial());

  final FirebaseAuth _auth;
  final GetUserByPhoneUseCase _getUserByPhone;
  final SyncAuthUserUseCase _syncAuthUser;

  void updateIdentifier(String value) {
    emitSafe(_update(state.copyWith(identifier: value)));
  }

  void updatePassword(String value) {
    emitSafe(_update(state.copyWith(password: value)));
  }

  void toggleRemember() {
    emitSafe(state.copyWith(rememberMe: !state.rememberMe));
  }

  void togglePasswordVisibility() {
    emitSafe(state.copyWith(showPassword: !state.showPassword));
  }

  void switchToPhoneLogin() {
    emitSafe(
      _update(
        state.copyWith(
          identifier: '',
          password: '',
          status: LoginStatus.initial,
          errorMessage: null,
          unverifiedEmail: null,
        ),
      ),
    );
  }

  Future<void> resendActivationLink() async {
    final email = state.unverifiedEmail?.trim() ?? '';
    if (email.isEmpty || state.password.trim().isEmpty) {
      emitSafe(
        state.copyWith(
          status: LoginStatus.failure,
          errorMessage: 'Enter your password, then resend the activation link.',
        ),
      );
      return;
    }

    emitSafe(state.copyWith(status: LoginStatus.loading, errorMessage: null));
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: state.password,
      );
      await result.user?.sendEmailVerification();
      await _auth.signOut();
      emitSafe(
        state.copyWith(
          status: LoginStatus.verificationLinkSent,
          errorMessage: 'Activation link resent. Please check your inbox.',
        ),
      );
    } on FirebaseAuthException catch (e) {
      emitSafe(
        state.copyWith(
          status: LoginStatus.failure,
          errorMessage: mapFirebaseAuthException(
            e,
            userNotFoundMessage: 'No user found for this email.',
            operationNotAllowedMessage:
                'Email/password accounts are not enabled.',
            fallbackMessage: 'Login failed. Please try again.',
          ),
        ),
      );
    } catch (_) {
      emitSafe(
        state.copyWith(
          status: LoginStatus.failure,
          errorMessage: AppStrings.somethingWentWrong,
        ),
      );
    }
  }

  Future<void> submit() async {
    if (!state.isValid || state.status == LoginStatus.loading) return;

    emitSafe(state.copyWith(status: LoginStatus.loading, errorMessage: null));
    try {
      final input = state.identifier.trim();
      UserCredential credential;

      if (AuthValidators.isPhone(input)) {
        credential = await _signInWithPhoneAndPassword(
          AuthValidators.normalizePhone(input),
          state.password,
        );
      } else {
        credential = await _auth.signInWithEmailAndPassword(
          email: input,
          password: state.password,
        );
      }

      final user = credential.user;
      if (user == null) {
        emitSafe(
          state.copyWith(
            status: LoginStatus.failure,
            errorMessage: 'Unable to sign in. Please try again.',
          ),
        );
        return;
      }

      await user.reload();
      final refreshed = _auth.currentUser;
      if (refreshed == null) {
        emitSafe(
          state.copyWith(
            status: LoginStatus.failure,
            errorMessage: 'Unable to sign in. Please try again.',
          ),
        );
        return;
      }

      if (AuthValidators.isEmail(input) && !refreshed.emailVerified) {
        try {
          await refreshed.sendEmailVerification();
        } on FirebaseAuthException catch (_) {}
        await _auth.signOut();
        emitSafe(
          state.copyWith(
            status: LoginStatus.emailNotVerified,
            unverifiedEmail: input,
            errorMessage:
                'Please verify your email first. We sent you a verification link.',
          ),
        );
        return;
      }

      await _syncAuthUser(refreshed);
      emitSafe(state.copyWith(status: LoginStatus.success));
    } on FirebaseAuthException catch (e) {
      final input = state.identifier.trim();
      emitSafe(
        state.copyWith(
          status: LoginStatus.failure,
          errorMessage: mapFirebaseAuthException(
            e,
            userNotFoundMessage: AuthValidators.isEmail(input)
                ? 'No user found for this email.'
                : 'No user found for this phone.',
            operationNotAllowedMessage:
                'Email/password accounts are not enabled.',
            fallbackMessage: 'Login failed. Please try again.',
          ),
        ),
      );
    } catch (_) {
      emitSafe(
        state.copyWith(
          status: LoginStatus.failure,
          errorMessage: AppStrings.somethingWentWrong,
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
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'No user found for this phone.',
      );
    }
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  LoginState _update(LoginState next) {
    final input = next.identifier.trim();
    final isIdentifierValid =
        AuthValidators.isPhone(input) || AuthValidators.isEmail(input);
    final valid = isIdentifierValid && AuthValidators.isPassword(next.password);
    return next.copyWith(isValid: valid);
  }
}
