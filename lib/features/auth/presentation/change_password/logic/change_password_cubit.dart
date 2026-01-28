import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/auth_validators.dart';
import 'change_password_state.dart';

class ChangePasswordCubit extends Cubit<ChangePasswordState> {
  ChangePasswordCubit() : super(ChangePasswordState.initial());

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

  ChangePasswordState _update(ChangePasswordState next) {
    final isValid = AuthValidators.isPassword(next.password) &&
        next.password == next.confirmPassword;
    return next.copyWith(isValid: isValid);
  }
}
