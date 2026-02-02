import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../features/users/domain/entities/user_entity.dart';
import '../../../../../features/users/domain/usecases/create_user_usecase.dart';
import '../../../../../features/users/domain/usecases/get_user_by_phone_usecase.dart';
import '../../../../../core/utils/auth_validators.dart';
import 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit({
    required FirebaseAuth auth,
    required CreateUserUseCase createUser,
    required GetUserByPhoneUseCase getUserByPhone,
  }) : _auth = auth,
       _createUser = createUser,
       _getUserByPhone = getUserByPhone,
       super(RegisterState.initial());

  final FirebaseAuth _auth;
  final CreateUserUseCase _createUser;
  final GetUserByPhoneUseCase _getUserByPhone;

  void updateFullName(String value) {
    emit(_update(state.copyWith(fullName: value, fullNameTouched: true)));
  }

  void updateEmail(String value) {
    emit(_update(state.copyWith(email: value, emailTouched: true)));
  }

  void updatePassword(String value) {
    emit(_update(state.copyWith(password: value, passwordTouched: true)));
  }

  void updateConfirmPassword(String value) {
    emit(
      _update(
        state.copyWith(confirmPassword: value, confirmPasswordTouched: true),
      ),
    );
  }

  void updatePhone(String value) {
    emit(_update(state.copyWith(phone: value, phoneTouched: true)));
  }

  void updatePhoneIso(String value) {
    emit(state.copyWith(phoneIso: value));
  }

  void updateCountry(String value) {
    emit(_update(state.copyWith(country: value, countryTouched: true)));
  }

  void updateCity(String value) {
    emit(_update(state.copyWith(city: value, cityTouched: true)));
  }

  void setMethod(RegisterMethod method) {
    emit(_update(state.copyWith(method: method)));
  }

  void toggleTerms() {
    emit(
      _update(
        state.copyWith(termsAccepted: !state.termsAccepted, termsTouched: true),
      ),
    );
  }

  void togglePasswordVisibility() {
    emit(state.copyWith(showPassword: !state.showPassword));
  }

  void toggleConfirmPasswordVisibility() {
    emit(state.copyWith(showConfirmPassword: !state.showConfirmPassword));
  }

  Future<void> submit() async {
    if (state.status == RegisterStatus.loading) return;
    if (!state.isValid) {
      emit(_update(state.copyWith(submitAttempted: true)));
      return;
    }
    emit(state.copyWith(status: RegisterStatus.loading, errorMessage: null));
    try {
      final existing = await _getUserByPhone(state.phone.trim());
      if (existing != null) {
        emit(
          state.copyWith(
            status: RegisterStatus.failure,
            errorMessage: 'Phone number already in use.',
          ),
        );
        return;
      }
      await _auth.verifyPhoneNumber(
        phoneNumber: state.phone.trim(),
        timeout: const Duration(seconds: 60),
        forceResendingToken: state.resendToken,
        verificationCompleted: (credential) async {
          try {
            final result = await _auth.signInWithCredential(credential);
            final user = result.user;
            if (user == null) {
              emit(
                state.copyWith(
                  status: RegisterStatus.failure,
                  errorMessage: 'Unable to verify phone. Please try again.',
                ),
              );
              return;
            }
            final linked = await _linkPasswordCredential(
              user,
              state.phone.trim(),
              state.password.trim(),
            );
            if (!linked) return;
            await user.updateDisplayName(state.fullName.trim());
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
            emit(state.copyWith(status: RegisterStatus.phoneVerified));
          } catch (_) {
            emit(
              state.copyWith(
                status: RegisterStatus.failure,
                errorMessage: 'Something went wrong. Please try again.',
              ),
            );
          }
        },
        verificationFailed: (e) {
          emit(
            state.copyWith(
              status: RegisterStatus.failure,
              errorMessage: _mapPhoneError(e),
            ),
          );
        },
        codeSent: (verificationId, resendToken) {
          emit(
            state.copyWith(
              status: RegisterStatus.phoneOtpSent,
              verificationId: verificationId,
              resendToken: resendToken,
            ),
          );
        },
        codeAutoRetrievalTimeout: (verificationId) {
          emit(state.copyWith(verificationId: verificationId));
        },
      );
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
    final isValid =
        next.fullName.trim().isNotEmpty &&
        _isEmailValid(next) &&
        _isPasswordValid(next) &&
        _isConfirmPasswordValid(next) &&
        _isPhoneValid(next) &&
        next.country.trim().isNotEmpty &&
        next.city.trim().isNotEmpty &&
        next.termsAccepted;
    final showAll = next.submitAttempted;
    return next.copyWith(
      isValid: isValid,
      fullNameError: _maybeError(
        next.fullNameTouched || showAll,
        _fullNameError(next.fullName),
      ),
      emailError: _maybeError(
        (next.emailTouched || showAll) && _shouldValidateEmail(next),
        _emailError(next.email),
      ),
      passwordError: _maybeError(
        (next.passwordTouched || showAll) && _shouldValidatePassword(next),
        _passwordError(next.password),
      ),
      confirmPasswordError: _maybeError(
        (next.confirmPasswordTouched || showAll) &&
            _shouldValidatePassword(next),
        _confirmPasswordError(next.password, next.confirmPassword),
      ),
      phoneError: _maybeError(
        (next.phoneTouched || showAll) && _shouldValidatePhone(next),
        _phoneError(next.phone),
      ),
      countryError: _maybeError(
        next.countryTouched || showAll,
        _countryError(next.country),
      ),
      cityError: _maybeError(
        next.cityTouched || showAll,
        _cityError(next.city),
      ),
      termsError: _maybeError(
        next.termsTouched || showAll,
        next.termsAccepted ? null : 'Please accept the terms.',
      ),
    );
  }

  String? _maybeError(bool visible, String? message) {
    return visible ? message : null;
  }

  String? _fullNameError(String value) {
    if (value.trim().isEmpty) return 'Full name is required.';
    return null;
  }

  String? _emailError(String value) {
    if (value.trim().isEmpty) return null;
    if (!AuthValidators.isEmail(value)) {
      return 'Enter a valid email (example@domain.com).';
    }
    return null;
  }

  String? _passwordError(String value) {
    if (value.trim().isEmpty) return 'Password is required.';
    if (!AuthValidators.isPassword(value)) {
      return 'Password must be at least 6 characters.';
    }
    return null;
  }

  String? _confirmPasswordError(String password, String confirm) {
    if (confirm.trim().isEmpty) return 'Please confirm your password.';
    if (password != confirm) return 'Passwords do not match.';
    return null;
  }

  String? _phoneError(String value) {
    if (value.trim().isEmpty) return 'Phone number is required.';
    if (!AuthValidators.isPhone(value)) return 'Enter a valid phone number.';
    return null;
  }

  String? _countryError(String value) {
    if (value.trim().isEmpty) return 'Country is required.';
    return null;
  }

  String? _cityError(String value) {
    if (value.trim().isEmpty) return 'City is required.';
    return null;
  }

  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Invalid email address.';
      case 'email-already-in-use':
        return 'Email already in use.';
      case 'credential-already-in-use':
        return 'Phone number already in use.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      default:
        return e.message ?? 'Sign up failed. Please try again.';
    }
  }

  String _mapPhoneError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-phone-number':
        return 'Invalid phone number.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      case 'quota-exceeded':
        return 'SMS quota exceeded. Please try again later.';
      case 'operation-not-allowed':
        return 'Phone auth is not enabled.';
      default:
        return e.message ?? 'Phone verification failed. Please try again.';
    }
  }

  bool _isEmailValid(RegisterState next) {
    if (!_shouldValidateEmail(next)) return true;
    return AuthValidators.isEmail(next.email);
  }

  bool _isPasswordValid(RegisterState next) {
    if (!_shouldValidatePassword(next)) return true;
    return AuthValidators.isPassword(next.password);
  }

  bool _isConfirmPasswordValid(RegisterState next) {
    if (!_shouldValidatePassword(next)) return true;
    return next.password == next.confirmPassword;
  }

  bool _isPhoneValid(RegisterState next) {
    if (!_shouldValidatePhone(next)) return true;
    return AuthValidators.isPhone(next.phone);
  }

  bool _shouldValidateEmail(RegisterState next) {
    return next.email.trim().isNotEmpty;
  }

  bool _shouldValidatePassword(RegisterState next) {
    return true;
  }

  bool _shouldValidatePhone(RegisterState next) {
    return next.method == RegisterMethod.phone || next.phone.trim().isNotEmpty;
  }

  Future<bool> _linkPasswordCredential(
    User user,
    String phone,
    String password,
  ) async {
    try {
      final email = AuthValidators.phoneToEmail(phone);
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      await user.linkWithCredential(credential);
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'provider-already-linked') {
        return true;
      }
      emit(
        state.copyWith(
          status: RegisterStatus.failure,
          errorMessage: _mapAuthError(e),
        ),
      );
      return false;
    } catch (_) {
      emit(
        state.copyWith(
          status: RegisterStatus.failure,
          errorMessage: 'Something went wrong. Please try again.',
        ),
      );
      return false;
    }
  }
}
