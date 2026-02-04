import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/errors/auth_error_mapper.dart';
import '../../../../../core/utils/auth_validators.dart';
import 'change_password_state.dart';

class ChangePasswordCubit extends Cubit<ChangePasswordState> {
  ChangePasswordCubit({required FirebaseAuth auth})
    : _auth = auth,
      super(ChangePasswordState.initial());

  final FirebaseAuth _auth;

  void updatePassword(String value) {
    emit(_update(state.copyWith(password: value)));
  }

  void updateConfirmPassword(String value) {
    emit(_update(state.copyWith(confirmPassword: value)));
  }

  void togglePasswordVisibility() {
    emit(state.copyWith(showPassword: !state.showPassword));
  }

  void toggleConfirmPasswordVisibility() {
    emit(state.copyWith(showConfirmPassword: !state.showConfirmPassword));
  }

  Future<void> submit() async {
    if (!state.isValid || state.status == ChangePasswordStatus.loading) return;
    emit(
      state.copyWith(status: ChangePasswordStatus.loading, errorMessage: null),
    );
    try {
      final user = _auth.currentUser;
      if (user == null) {
        emit(
          state.copyWith(
            status: ChangePasswordStatus.failure,
            errorMessage: 'Session expired. Please verify your phone again.',
          ),
        );
        return;
      }
      await user.updatePassword(state.password.trim());
      await _auth.signOut();
      emit(state.copyWith(status: ChangePasswordStatus.success));
    } on FirebaseAuthException catch (e) {
      emit(
        state.copyWith(
          status: ChangePasswordStatus.failure,
          errorMessage: mapFirebaseAuthException(
            e,
            requiresRecentLoginMessage:
                'Session expired. Please verify your phone again.',
            fallbackMessage: 'Unable to change password. Please try again.',
          ),
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: ChangePasswordStatus.failure,
          errorMessage: AppStrings.somethingWentWrong,
        ),
      );
    }
  }

  ChangePasswordState _update(ChangePasswordState next) {
    final isValid =
        AuthValidators.isPassword(next.password) &&
        next.password == next.confirmPassword;
    return next.copyWith(isValid: isValid);
  }
}
