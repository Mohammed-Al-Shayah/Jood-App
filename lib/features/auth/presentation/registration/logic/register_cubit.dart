import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../features/users/domain/entities/user_entity.dart';
import '../../../../../features/users/domain/usecases/create_user_usecase.dart';
import '../../../../../core/utils/auth_validators.dart';
import 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit({
    required FirebaseAuth auth,
    required CreateUserUseCase createUser,
  })  : _auth = auth,
        _createUser = createUser,
        super(RegisterState.initial());

  final FirebaseAuth _auth;
  final CreateUserUseCase _createUser;

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

  Future<void> submit() async {
    if (!state.isValid || state.status == RegisterStatus.loading) return;
    emit(state.copyWith(status: RegisterStatus.loading, errorMessage: null));
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: state.email.trim(),
        password: state.password,
      );
      final user = credential.user;
      if (user == null) {
        emit(
          state.copyWith(
            status: RegisterStatus.failure,
            errorMessage: 'Unable to create account. Please try again.',
          ),
        );
        return;
      }
      await user.updateDisplayName(state.fullName.trim());
      await user.sendEmailVerification();
      await _createUser(
        UserEntity(
          id: user.uid,
          fullName: state.fullName.trim(),
          email: state.email.trim(),
          phone: state.phone.trim(),
          country: state.country.trim(),
          city: state.city.trim(),
          role: 'customer',
        ),
      );
      await _auth.signOut();
      emit(state.copyWith(status: RegisterStatus.success));
    } on FirebaseAuthException catch (e) {
      emit(
        state.copyWith(
          status: RegisterStatus.failure,
          errorMessage: _mapAuthError(e),
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: RegisterStatus.failure,
          errorMessage: 'Something went wrong. Please try again.',
        ),
      );
    }
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

  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Invalid email address.';
      case 'email-already-in-use':
        return 'Email already in use.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      default:
        return e.message ?? 'Sign up failed. Please try again.';
    }
  }
}
