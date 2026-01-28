import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/auth_validators.dart';
import 'forget_password_state.dart';

class ForgetPasswordCubit extends Cubit<ForgetPasswordState> {
  ForgetPasswordCubit() : super(ForgetPasswordState.initial());

  void updateEmail(String value) {
    final isValid = AuthValidators.isEmail(value);
    emit(state.copyWith(email: value, isValid: isValid));
  }
}
