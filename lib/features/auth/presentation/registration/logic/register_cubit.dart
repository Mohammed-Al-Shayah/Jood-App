import 'package:flutter/rendering.dart';
import 'package:jood/features/auth/domain/usecases/check_email_in_use_usecase.dart';

import '../../../../../core/bloc/safe_cubit.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/errors/auth_error_mapper.dart';
import '../../../../../core/utils/auth_validators.dart';
import '../../../../../features/users/domain/usecases/get_user_by_email_usecase.dart';
import '../../../../../features/users/domain/usecases/get_user_by_phone_usecase.dart';
import '../../../domain/usecases/send_phone_otp_usecase.dart';
import 'register_state.dart';

class RegisterCubit extends SafeCubit<RegisterState> {
  RegisterCubit({
    required SendPhoneOtpUseCase sendPhoneOtp,
    required GetUserByEmailUseCase getUserByEmail,
    required GetUserByPhoneUseCase getUserByPhone,
    required CheckEmailInUseUseCase checkEmailInUse,
  }) : _sendPhoneOtp = sendPhoneOtp,
       _getUserByEmail = getUserByEmail,
       _getUserByPhone = getUserByPhone,
       _checkEmailInUse = checkEmailInUse,
       super(RegisterState.initial());

  final SendPhoneOtpUseCase _sendPhoneOtp;
  final GetUserByEmailUseCase _getUserByEmail;
  final GetUserByPhoneUseCase _getUserByPhone;
  final CheckEmailInUseUseCase _checkEmailInUse;

  void updateFullName(String value) {
    emitSafe(_update(state.copyWith(fullName: value, fullNameTouched: true)));
  }

  void updateEmail(String value) {
    emitSafe(_update(state.copyWith(email: value, emailTouched: true)));
  }

  void updatePassword(String value) {
    emitSafe(_update(state.copyWith(password: value, passwordTouched: true)));
  }

  void updateConfirmPassword(String value) {
    emitSafe(
      _update(
        state.copyWith(confirmPassword: value, confirmPasswordTouched: true),
      ),
    );
  }

  void updatePhone(String value) {
    emitSafe(_update(state.copyWith(phone: value, phoneTouched: true)));
  }

  void updatePhoneIso(String value) {
    emitSafe(state.copyWith(phoneIso: value));
  }

  void updateCountry(String value) {
    emitSafe(_update(state.copyWith(country: value, countryTouched: true)));
  }

  void updateCity(String value) {
    emitSafe(_update(state.copyWith(city: value, cityTouched: true)));
  }

  void toggleTerms() {
    emitSafe(
      _update(
        state.copyWith(termsAccepted: !state.termsAccepted, termsTouched: true),
      ),
    );
  }

  void togglePasswordVisibility() {
    emitSafe(state.copyWith(showPassword: !state.showPassword));
  }

  void toggleConfirmPasswordVisibility() {
    emitSafe(state.copyWith(showConfirmPassword: !state.showConfirmPassword));
  }

  Future<void> submit() async {
    debugPrint('[RegisterCubit] submit() called');

    if (state.status == RegisterStatus.loading) {
      debugPrint('[RegisterCubit] Already loading, returning early');
      return;
    }

    if (!state.isValid) {
      debugPrint('[RegisterCubit] Form validation failed');
      emitSafe(_update(state.copyWith(submitAttempted: true)));
      return;
    }

    debugPrint('[RegisterCubit] Form is valid, starting registration process');
    emitSafe(
      state.copyWith(status: RegisterStatus.loading, errorMessage: null),
    );

    try {
      final providedEmail = state.email.trim();
      debugPrint('[RegisterCubit] Step 1: Checking email - $providedEmail');

      final emailExistsInAuth = await _checkEmailInUse(providedEmail);
      debugPrint(
        '[RegisterCubit] Step 2: Email exists in Auth - $emailExistsInAuth',
      );

      final emailExistsInDb = (await _getUserByEmail(providedEmail)) != null;
      debugPrint(
        '[RegisterCubit] Step 3: Email exists in DB - $emailExistsInDb',
      );

      if (emailExistsInAuth || emailExistsInDb) {
        debugPrint('[RegisterCubit] ERROR: Email already registered');
        final errorMessage = AppStrings.emailAlreadyRegisteredLong;
        emitSafe(
          state.copyWith(
            status: RegisterStatus.failure,
            errorMessage: errorMessage,
            emailError: errorMessage,
          ),
        );
        return;
      }

      final normalizedPhone = AuthValidators.normalizePhone(state.phone);
      debugPrint('[RegisterCubit] Step 4: Phone normalized - $normalizedPhone');

      final existing = await _getUserByPhone(normalizedPhone);
      debugPrint(
        '[RegisterCubit] Step 5: Phone already exists - ${existing != null}',
      );

      if (existing != null) {
        debugPrint('[RegisterCubit] ERROR: Phone number already in use');
        emitSafe(
          state.copyWith(
            status: RegisterStatus.failure,
            errorMessage: AppStrings.phoneNumberAlreadyInUse,
            phoneError: AppStrings.thisPhoneNumberIsAlreadyRegistered,
          ),
        );
        return;
      }

      debugPrint(
        '[RegisterCubit] Step 6: Sending OTP to phone - ${state.phone.trim()}',
      );
      final verificationId = await _sendPhoneOtp(phoneNumber: normalizedPhone);
      debugPrint('[RegisterCubit] Step 7: OTP code sent successfully');
      emitSafe(
        state.copyWith(
          status: RegisterStatus.phoneOtpSent,
          verificationId: verificationId,
          resendToken: null,
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('[RegisterCubit] ERROR: Exception - $e');
      debugPrint('[RegisterCubit] ERROR STACK TRACE: $stackTrace');
      debugPrint('[RegisterCubit] ERROR TYPE: ${e.runtimeType}');
      emitSafe(
        state.copyWith(
          status: RegisterStatus.failure,
          errorMessage: isAuthError(e)
              ? mapAuthError(
                  e,
                  operationNotAllowedMessage: AppStrings.phoneAuthNotEnabled,
                  fallbackMessage: AppStrings.signUpFailedPleaseTryAgain,
                )
              : AppStrings.somethingWentWrong,
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
        next.phoneTouched || showAll,
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
        next.termsAccepted ? null : AppStrings.pleaseAcceptTheTerms,
      ),
    );
  }

  String? _maybeError(bool visible, String? message) {
    return visible ? message : null;
  }

  String? _fullNameError(String value) {
    if (value.trim().isEmpty) return AppStrings.fullNameIsRequired;
    return null;
  }

  String? _emailError(String value) {
    if (value.trim().isEmpty) return AppStrings.emailIsRequired;
    if (!AuthValidators.isEmail(value)) {
      return AppStrings.enterValidEmailExample;
    }
    return null;
  }

  String? _passwordError(String value) {
    if (value.trim().isEmpty) return AppStrings.passwordIsRequired;
    if (!AuthValidators.isPassword(value)) {
      return AppStrings.passwordMustBeAtLeast6Characters;
    }
    return null;
  }

  String? _confirmPasswordError(String password, String confirm) {
    if (confirm.trim().isEmpty) return AppStrings.pleaseConfirmYourPassword;
    if (password != confirm) return AppStrings.passwordsDoNotMatch;
    return null;
  }

  String? _phoneError(String value) {
    if (value.trim().isEmpty) return AppStrings.phoneNumberIsRequired;
    if (!AuthValidators.isPhone(value)) return AppStrings.enterValidPhoneNumber;
    return null;
  }

  String? _countryError(String value) {
    if (value.trim().isEmpty) return AppStrings.countryIsRequired;
    return null;
  }

  String? _cityError(String value) {
    if (value.trim().isEmpty) return AppStrings.cityIsRequired;
    return null;
  }

  bool _isEmailValid(RegisterState next) {
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
    return AuthValidators.isPhone(next.phone);
  }

  bool _shouldValidateEmail(RegisterState next) {
    return true;
  }

  bool _shouldValidatePassword(RegisterState next) {
    return true;
  }
}
