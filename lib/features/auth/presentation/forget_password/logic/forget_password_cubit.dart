import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/auth_validators.dart';
import 'forget_password_state.dart';

class ForgetPasswordCubit extends Cubit<ForgetPasswordState> {
  ForgetPasswordCubit({required FirebaseAuth auth})
      : _auth = auth,
        super(ForgetPasswordState.initial());

  final FirebaseAuth _auth;

  void updateEmail(String value) {
    final isValid = AuthValidators.isEmail(value);
    emit(state.copyWith(email: value, isValid: isValid));
  }

  Future<void> submit() async {
    if (!state.isValid || state.status == ForgetPasswordStatus.loading) return;
    emit(state.copyWith(status: ForgetPasswordStatus.loading, errorMessage: null));
    try {
      await _auth.sendPasswordResetEmail(email: state.email.trim());
      emit(state.copyWith(status: ForgetPasswordStatus.success));
    } on FirebaseAuthException catch (e) {
      emit(
        state.copyWith(
          status: ForgetPasswordStatus.failure,
          errorMessage: _mapAuthError(e),
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: ForgetPasswordStatus.failure,
          errorMessage: 'Something went wrong. Please try again.',
        ),
      );
    }
  }

  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-not-found':
        return 'No user found for this email.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      default:
        return e.message ?? 'Request failed. Please try again.';
    }
  }
}
