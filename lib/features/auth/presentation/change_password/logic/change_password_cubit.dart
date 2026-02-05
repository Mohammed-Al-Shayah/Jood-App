import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/errors/auth_error_mapper.dart';
import '../../../../../core/utils/auth_validators.dart';
import '../../../domain/usecases/get_current_user_usecase.dart';
import '../../../domain/usecases/sign_out_usecase.dart';
import '../../../domain/usecases/update_password_usecase.dart';
import 'change_password_state.dart';

class ChangePasswordCubit extends Cubit<ChangePasswordState> {
  ChangePasswordCubit({
    required GetCurrentUserUseCase getCurrentUser,
    required UpdatePasswordUseCase updatePassword,
    required SignOutUseCase signOut,
  }) : _getCurrentUser = getCurrentUser,
       _updatePassword = updatePassword,
       _signOut = signOut,
       super(ChangePasswordState.initial());

  final GetCurrentUserUseCase _getCurrentUser;
  final UpdatePasswordUseCase _updatePassword;
  final SignOutUseCase _signOut;

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
      final user = _getCurrentUser();
      if (user == null) {
        emit(
          state.copyWith(
            status: ChangePasswordStatus.failure,
            errorMessage: 'Session expired. Please verify your phone again.',
          ),
        );
        return;
      }
      await _updatePassword(user: user, newPassword: state.password.trim());
      await _signOut();
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
