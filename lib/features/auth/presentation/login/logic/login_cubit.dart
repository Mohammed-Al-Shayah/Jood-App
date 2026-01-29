import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/auth_validators.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit({required FirebaseAuth auth})
      : _auth = auth,
        super(LoginState.initial());

  final FirebaseAuth _auth;

  void updateEmail(String value) {
    emit(_update(state.copyWith(email: value)));
  }

  void updatePassword(String value) {
    emit(_update(state.copyWith(password: value)));
  }

  void toggleRemember() {
    emit(state.copyWith(rememberMe: !state.rememberMe));
  }

  void togglePasswordVisibility() {
    emit(state.copyWith(showPassword: !state.showPassword));
  }

  Future<void> submit() async {
    if (!state.isValid || state.status == LoginStatus.loading) return;
    emit(state.copyWith(status: LoginStatus.loading, errorMessage: null));
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: state.email.trim(),
        password: state.password,
      );
      final user = credential.user;
      if (user == null) {
        emit(
          state.copyWith(
            status: LoginStatus.failure,
            errorMessage: 'Unable to sign in. Please try again.',
          ),
        );
        return;
      }
      await user.reload();
      final refreshed = _auth.currentUser;
      if (refreshed == null || !refreshed.emailVerified) {
        await refreshed?.sendEmailVerification();
        await _auth.signOut();
        emit(
          state.copyWith(
            status: LoginStatus.failure,
            errorMessage:
                'Please verify your email. A verification link was sent.',
          ),
        );
        return;
      }
      emit(state.copyWith(status: LoginStatus.success));
    } on FirebaseAuthException catch (e) {
      emit(
        state.copyWith(
          status: LoginStatus.failure,
          errorMessage: _mapAuthError(e),
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: LoginStatus.failure,
          errorMessage: 'Something went wrong. Please try again.',
        ),
      );
    }
  }

  LoginState _update(LoginState next) {
    final valid = AuthValidators.isEmail(next.email) &&
        AuthValidators.isPassword(next.password);
    return next.copyWith(isValid: valid);
  }

  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No user found for this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      default:
        return e.message ?? 'Login failed. Please try again.';
    }
  }
}
