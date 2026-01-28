import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/auth_validators.dart';
import 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit() : super(RegisterState.initial());

  void updateFullName(String value) {
    emit(_update(state.copyWith(fullName: value)));
  }

  void updateEmail(String value) {
    emit(_update(state.copyWith(email: value)));
  }

  void updatePassword(String value) {
    emit(_update(state.copyWith(password: value)));
  }

  void updateConfirmPassword(String value) {
    emit(_update(state.copyWith(confirmPassword: value)));
  }

  void updatePhone(String value) {
    emit(_update(state.copyWith(phone: value)));
  }

  void updateCountry(String value) {
    emit(_update(state.copyWith(country: value)));
  }

  void updateCity(String value) {
    emit(_update(state.copyWith(city: value)));
  }

  void toggleTerms() {
    emit(_update(state.copyWith(termsAccepted: !state.termsAccepted)));
  }

  void togglePasswordVisibility() {
    emit(state.copyWith(showPassword: !state.showPassword));
  }

  void toggleConfirmPasswordVisibility() {
    emit(state.copyWith(showConfirmPassword: !state.showConfirmPassword));
  }

  RegisterState _update(RegisterState next) {
    final isValid = next.fullName.trim().isNotEmpty &&
        AuthValidators.isEmail(next.email) &&
        AuthValidators.isPassword(next.password) &&
        next.password == next.confirmPassword &&
        next.phone.trim().isNotEmpty &&
        next.country.trim().isNotEmpty &&
        next.city.trim().isNotEmpty &&
        next.termsAccepted;
    return next.copyWith(isValid: isValid);
  }
}
