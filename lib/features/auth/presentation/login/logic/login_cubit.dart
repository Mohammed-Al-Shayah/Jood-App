import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/auth_validators.dart';
import '../../../../../features/users/domain/usecases/get_user_by_phone_usecase.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit({
    required FirebaseAuth auth,
    required GetUserByPhoneUseCase getUserByPhone,
  })  : _auth = auth,
        _getUserByPhone = getUserByPhone,
        super(LoginState.initial());

  final FirebaseAuth _auth;
  final GetUserByPhoneUseCase _getUserByPhone;

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
      final input = state.email.trim();
      UserCredential credential;
      if (AuthValidators.isEmail(input)) {
        credential = await _auth.signInWithEmailAndPassword(
          email: input,
          password: state.password,
        );
      } else {
        final phoneEmail = AuthValidators.phoneToEmail(input);
        credential = await _signInWithPhoneOrLookup(
          phoneEmail,
          input,
          state.password,
        );
      }
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
      if (AuthValidators.isEmail(input)) {
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
      }
      emit(state.copyWith(status: LoginStatus.success));
    } on FirebaseAuthException catch (e) {
      final input = state.email.trim();
      emit(
        state.copyWith(
          status: LoginStatus.failure,
          errorMessage: _mapAuthError(e, input),
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
    final valid = (AuthValidators.isEmail(next.email) ||
            AuthValidators.isPhone(next.email)) &&
        AuthValidators.isPassword(next.password);
    return next.copyWith(isValid: valid);
  }

  String _mapAuthError(FirebaseAuthException e, String input) {
    switch (e.code) {
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return AuthValidators.isEmail(input)
            ? 'No user found for this email.'
            : 'No user found for this phone.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      case 'invalid-phone-number':
        return 'Invalid phone number.';
      default:
        return e.message ?? 'Login failed. Please try again.';
    }
  }

  Future<UserCredential> _signInWithPhoneOrLookup(
    String phoneEmail,
    String phone,
    String password,
  ) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: phoneEmail,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code != 'user-not-found' && e.code != 'invalid-email') {
        rethrow;
      }
      final user = await _getUserByPhone(phone);
      final email = user?.email.trim() ?? '';
      if (email.isEmpty) {
        rethrow;
      }
      return _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    }
  }

}
