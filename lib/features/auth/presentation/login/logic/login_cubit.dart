import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/auth_validators.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginState.initial());

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

  LoginState _update(LoginState next) {
    final valid = AuthValidators.isEmail(next.email) &&
        AuthValidators.isPassword(next.password);
    return next.copyWith(isValid: valid);
  }
}
