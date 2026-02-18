import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/rendering.dart';
import 'package:jood/features/auth/domain/usecases/check_email_in_use_usecase.dart';

import '../../../../../core/bloc/safe_cubit.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/errors/auth_error_mapper.dart';
import '../../../../../core/utils/auth_validators.dart';
import '../../../domain/usecases/link_email_password_usecase.dart';
import '../../../domain/usecases/send_email_verification_usecase.dart';
import '../../../domain/usecases/send_phone_otp_usecase.dart';
import '../../../domain/usecases/sign_in_with_phone_credential_usecase.dart';
import '../../../../../features/users/domain/entities/user_entity.dart';
import '../../../../../features/users/domain/usecases/create_user_usecase.dart';
import '../../../../../features/users/domain/usecases/get_user_by_email_usecase.dart';
import '../../../../../features/users/domain/usecases/get_user_by_phone_usecase.dart';
import '../../../../../features/users/domain/usecases/sync_auth_user_usecase.dart';
import 'register_state.dart';

class RegisterCubit extends SafeCubit<RegisterState> {
  RegisterCubit({
    required SendPhoneOtpUseCase sendPhoneOtp,
    required SignInWithPhoneCredentialUseCase signInWithPhoneCredential,
    required LinkEmailPasswordUseCase linkEmailPassword,
    required SendEmailVerificationUseCase sendEmailVerification,
    required CreateUserUseCase createUser,
    required GetUserByEmailUseCase getUserByEmail,
    required GetUserByPhoneUseCase getUserByPhone,
    required SyncAuthUserUseCase syncAuthUser,
    required CheckEmailInUseUseCase checkEmailInUse,
  }) : _sendPhoneOtp = sendPhoneOtp,
       _signInWithPhoneCredential = signInWithPhoneCredential,
       _linkEmailPassword = linkEmailPassword,
       _sendEmailVerification = sendEmailVerification,
       _createUser = createUser,
       _getUserByEmail = getUserByEmail,
       _getUserByPhone = getUserByPhone,
       _syncAuthUser = syncAuthUser,
       _checkEmailInUse = checkEmailInUse,
       super(RegisterState.initial());

  final SendPhoneOtpUseCase _sendPhoneOtp;
  final SignInWithPhoneCredentialUseCase _signInWithPhoneCredential;
  final LinkEmailPasswordUseCase _linkEmailPassword;
  final SendEmailVerificationUseCase _sendEmailVerification;
  final CreateUserUseCase _createUser;
  final GetUserByEmailUseCase _getUserByEmail;
  final GetUserByPhoneUseCase _getUserByPhone;
  final SyncAuthUserUseCase _syncAuthUser;
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
        const errorMessage =
            'This email address is already registered and a new account cannot be created with it.';
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
            errorMessage: 'Phone number already in use.',
            phoneError: 'This phone number is already registered.',
          ),
        );
        return;
      }

      debugPrint(
        '[RegisterCubit] Step 6: Sending OTP to phone - ${state.phone.trim()}',
      );
      await _sendPhoneOtp(
        phoneNumber: "+970561234567",
        // state.phone.trim(),
        timeout: const Duration(seconds: 60),
        forceResendingToken: state.resendToken,
        verificationCompleted: (credential) async {
          try {
            debugPrint(
              '[RegisterCubit] Step 7: Phone verification completed automatically',
            );
            final result = await _signInWithPhoneCredential(credential);
            final user = result.user;
            if (user == null) {
              debugPrint(
                '[RegisterCubit] ERROR: User is null after phone verification',
              );
              emitSafe(
                state.copyWith(
                  status: RegisterStatus.failure,
                  errorMessage: 'Unable to verify phone. Please try again.',
                ),
              );
              return;
            }
            debugPrint(
              '[RegisterCubit] Step 8: Finalizing registration for user ${user.uid}',
            );
            await _finalizeRegistration(user, normalizedPhone);

            debugPrint(
              '[RegisterCubit] SUCCESS: Registration completed successfully',
            );
            emitSafe(
              state.copyWith(
                status: RegisterStatus.phoneVerified,
                errorMessage: null,
              ),
            );
          } catch (e, stackTrace) {
            debugPrint('[RegisterCubit] ERROR in verificationCompleted: $e');
            debugPrint('[RegisterCubit] ERROR STACK TRACE: $stackTrace');
            if (e is FirebaseAuthException) {
              debugPrint(
                '[RegisterCubit] FirebaseAuthException CODE: ${e.code}',
              );
              debugPrint(
                '[RegisterCubit] FirebaseAuthException MESSAGE: ${e.message}',
              );
            }
            emitSafe(
              state.copyWith(
                status: RegisterStatus.failure,
                errorMessage: AppStrings.somethingWentWrong,
              ),
            );
          }
        },
        verificationFailed: (e) {
          debugPrint('[RegisterCubit] ===== PHONE VERIFICATION FAILED =====');
          debugPrint('[RegisterCubit] ERROR CODE: ${e.code}');
          debugPrint('[RegisterCubit] ERROR MESSAGE: ${e.message}');
          debugPrint('[RegisterCubit] ERROR FULL EXCEPTION: $e');
          debugPrint('[RegisterCubit]');
          debugPrint('[RegisterCubit] === TROUBLESHOOTING TIPS ===');
          debugPrint('[RegisterCubit] =====================================');
          emitSafe(
            state.copyWith(
              status: RegisterStatus.failure,
              errorMessage: mapFirebaseAuthException(
                e,
                operationNotAllowedMessage: 'Phone auth is not enabled.',
                fallbackMessage: 'Phone verification failed. Please try again.',
              ),
            ),
          );
        },
        codeSent: (verificationId, resendToken) {
          debugPrint('[RegisterCubit] Step 7: OTP code sent successfully');
          emitSafe(
            state.copyWith(
              status: RegisterStatus.phoneOtpSent,
              verificationId: verificationId,
              resendToken: resendToken,
            ),
          );
        },
        codeAutoRetrievalTimeout: (verificationId) {
          debugPrint('[RegisterCubit] Step 9: Auto-retrieval timeout');
          emitSafe(state.copyWith(verificationId: verificationId));
        },
      );
    } on FirebaseAuthException catch (e, stackTrace) {
      debugPrint(
        '[RegisterCubit] ERROR: FirebaseAuthException - Code: ${e.code}, Message: ${e.message}',
      );
      debugPrint('[RegisterCubit] ERROR FULL EXCEPTION: $e');
      debugPrint('[RegisterCubit] ERROR STACK TRACE: $stackTrace');
      emitSafe(
        state.copyWith(
          status: RegisterStatus.failure,
          errorMessage: mapFirebaseAuthException(
            e,
            operationNotAllowedMessage: 'Phone auth is not enabled.',
            fallbackMessage: 'Sign up failed. Please try again.',
          ),
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('[RegisterCubit] ERROR: Unexpected exception - $e');
      debugPrint('[RegisterCubit] ERROR STACK TRACE: $stackTrace');
      debugPrint('[RegisterCubit] ERROR TYPE: ${e.runtimeType}');
      emitSafe(
        state.copyWith(
          status: RegisterStatus.failure,
          errorMessage: AppStrings.somethingWentWrong,
        ),
      );
    }
  }

  Future<void> _finalizeRegistration(User user, String normalizedPhone) async {
    debugPrint(
      '[RegisterCubit] _finalizeRegistration: Started for user ${user.uid}',
    );

    try {
      final providedEmail = state.email.trim();
      if (providedEmail.isEmpty) {
        debugPrint('[RegisterCubit] ERROR: Email is empty');
        throw FirebaseAuthException(code: 'invalid-email');
      }

      debugPrint(
        '[RegisterCubit] _finalizeRegistration: Step 1 - Linking password credential',
      );
      await _linkPasswordCredential(user, providedEmail, state.password.trim());
      debugPrint(
        '[RegisterCubit] _finalizeRegistration: Step 1 SUCCESS - Password linked',
      );

      debugPrint(
        '[RegisterCubit] _finalizeRegistration: Step 2 - Updating display name to ${state.fullName.trim()}',
      );
      await user.updateDisplayName(state.fullName.trim());
      debugPrint(
        '[RegisterCubit] _finalizeRegistration: Step 2 SUCCESS - Display name updated',
      );

      debugPrint(
        '[RegisterCubit] _finalizeRegistration: Step 3 - Sending email verification',
      );
      await _sendEmailVerification(user);
      debugPrint(
        '[RegisterCubit] _finalizeRegistration: Step 3 SUCCESS - Email verification sent',
      );

      final profile = UserEntity(
        id: user.uid,
        fullName: state.fullName.trim(),
        email: providedEmail,
        emailVerified: false,
        phone: normalizedPhone,
        country: state.country.trim(),
        city: state.city.trim(),
        role: 'customer',
      );

      debugPrint(
        '[RegisterCubit] _finalizeRegistration: Step 4 - Creating user profile',
      );
      await _createUser(profile);
      debugPrint(
        '[RegisterCubit] _finalizeRegistration: Step 4 SUCCESS - User profile created',
      );

      debugPrint(
        '[RegisterCubit] _finalizeRegistration: Step 5 - Syncing auth user',
      );
      await _syncAuthUser(user, fallback: profile);
      debugPrint(
        '[RegisterCubit] _finalizeRegistration: Step 5 SUCCESS - Auth user synced',
      );

      debugPrint(
        '[RegisterCubit] _finalizeRegistration: SUCCESS - All finalization steps completed',
      );
    } on FirebaseAuthException catch (e, stackTrace) {
      debugPrint(
        '[RegisterCubit] _finalizeRegistration: ERROR - FirebaseAuthException',
      );
      debugPrint(
        '[RegisterCubit] _finalizeRegistration: ERROR CODE: ${e.code}',
      );
      debugPrint(
        '[RegisterCubit] _finalizeRegistration: ERROR MESSAGE: ${e.message}',
      );
      debugPrint(
        '[RegisterCubit] _finalizeRegistration: ERROR FULL EXCEPTION: $e',
      );
      debugPrint(
        '[RegisterCubit] _finalizeRegistration: ERROR STACK TRACE: $stackTrace',
      );
      rethrow;
    } catch (e, stackTrace) {
      debugPrint(
        '[RegisterCubit] _finalizeRegistration: ERROR - Unexpected exception',
      );
      debugPrint(
        '[RegisterCubit] _finalizeRegistration: ERROR TYPE: ${e.runtimeType}',
      );
      debugPrint('[RegisterCubit] _finalizeRegistration: ERROR MESSAGE: $e');
      debugPrint(
        '[RegisterCubit] _finalizeRegistration: ERROR STACK TRACE: $stackTrace',
      );
      rethrow;
    }
  }

  Future<void> _linkPasswordCredential(
    User user,
    String email,
    String password,
  ) async {
    debugPrint(
      '[RegisterCubit] _linkPasswordCredential: Attempting to link email/password for $email',
    );

    try {
      await _linkEmailPassword(user: user, email: email, password: password);
      debugPrint(
        '[RegisterCubit] _linkPasswordCredential: Successfully linked email/password',
      );
    } on FirebaseAuthException catch (e, stackTrace) {
      debugPrint(
        '[RegisterCubit] _linkPasswordCredential: FirebaseAuthException - Code: ${e.code}',
      );
      debugPrint(
        '[RegisterCubit] _linkPasswordCredential: ERROR MESSAGE: ${e.message}',
      );
      debugPrint(
        '[RegisterCubit] _linkPasswordCredential: ERROR FULL EXCEPTION: $e',
      );
      debugPrint(
        '[RegisterCubit] _linkPasswordCredential: ERROR STACK TRACE: $stackTrace',
      );

      if (e.code == 'provider-already-linked') {
        debugPrint(
          '[RegisterCubit] _linkPasswordCredential: Provider already linked, ignoring',
        );
        return;
      }
      if (e.code == 'email-already-in-use' ||
          e.code == 'credential-already-in-use') {
        debugPrint(
          '[RegisterCubit] _linkPasswordCredential: ERROR - Email already in use',
        );
        throw FirebaseAuthException(
          code: e.code,
          message:
              'This email is already registered. Please use a different email or log in.',
        );
      }
      debugPrint(
        '[RegisterCubit] _linkPasswordCredential: ERROR - ${mapFirebaseAuthException(e, operationNotAllowedMessage: 'Email/password accounts are not enabled.', fallbackMessage: 'Sign up failed. Please try again.')}',
      );
      throw FirebaseAuthException(
        code: e.code,
        message: mapFirebaseAuthException(
          e,
          operationNotAllowedMessage:
              'Email/password accounts are not enabled.',
          fallbackMessage: 'Sign up failed. Please try again.',
        ),
      );
    } catch (e, stackTrace) {
      debugPrint(
        '[RegisterCubit] _linkPasswordCredential: Unexpected exception - $e',
      );
      debugPrint(
        '[RegisterCubit] _linkPasswordCredential: ERROR TYPE: ${e.runtimeType}',
      );
      debugPrint(
        '[RegisterCubit] _linkPasswordCredential: ERROR STACK TRACE: $stackTrace',
      );
      rethrow;
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
    if (value.trim().isEmpty) return 'Email is required.';
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
