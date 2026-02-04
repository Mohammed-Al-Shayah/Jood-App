import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:jood/core/errors/auth_error_mapper.dart';
import 'package:jood/core/utils/auth_validators.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/get_user_by_phone_usecase.dart';
import '../../domain/usecases/update_user_usecase.dart';
import 'profile_edit_state.dart';

class ProfileEditCubit extends Cubit<ProfileEditState> {
  ProfileEditCubit({
    required UpdateUserUseCase updateUser,
    required GetUserByPhoneUseCase getUserByPhone,
    required FirebaseAuth auth,
    required UserEntity user,
  }) : _updateUser = updateUser,
       _getUserByPhone = getUserByPhone,
       _auth = auth,
       _user = user,
       super(
         ProfileEditState.initial(
           fullName: user.fullName,
           email: user.email,
           phone: user.phone,
           country: user.country,
           city: user.city,
         ),
       ) {
    _initPhoneIso(user.phone);
  }

  final UpdateUserUseCase _updateUser;
  final GetUserByPhoneUseCase _getUserByPhone;
  final FirebaseAuth _auth;
  final UserEntity _user;
  Timer? _timer;

  void updateFullName(String value) {
    emit(state.copyWith(fullName: value));
  }

  void updateEmail(String value) {
    emit(state.copyWith(email: value));
  }

  void updatePhone(String value) {
    emit(state.copyWith(phone: value));
  }

  void updatePhoneIso(String value) {
    emit(state.copyWith(phoneIso: value));
  }

  void updateCountry(String value) {
    emit(state.copyWith(country: value));
  }

  void updateCity(String value) {
    emit(state.copyWith(city: value));
  }

  void updateOtpCode(String value) {
    emit(state.copyWith(otpCode: value));
  }

  Future<void> save() async {
    if (state.status == ProfileEditStatus.saving ||
        state.status == ProfileEditStatus.otpSending ||
        state.status == ProfileEditStatus.otpVerifying) {
      return;
    }
    emit(
      state.copyWith(
        status: ProfileEditStatus.saving,
        errorMessage: null,
        successMessage: null,
      ),
    );
    try {
      final current = _auth.currentUser;
      if (current == null) {
        emit(
          state.copyWith(
            status: ProfileEditStatus.failure,
            errorMessage: 'No signed-in user found.',
          ),
        );
        return;
      }
      final newPhone = state.phone.trim();
      final phoneChanged =
          AuthValidators.normalizePhone(newPhone) !=
          AuthValidators.normalizePhone(_user.phone.trim());
      if (phoneChanged) {
        final existing = await _getUserByPhone(newPhone);
        if (existing != null && existing.id != _user.id) {
          emit(
            state.copyWith(
              status: ProfileEditStatus.failure,
              errorMessage: 'Phone number already in use.',
            ),
          );
          return;
        }
        await _sendPhoneOtp(newPhone);
        return;
      }
      final sentVerificationEmail = await _applyUpdates(current);
      emit(
        state.copyWith(
          status: ProfileEditStatus.success,
          successMessage: sentVerificationEmail
              ? 'Verification link sent to your new email. Please confirm it.'
              : null,
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        await _auth.signOut();
      }
      emit(
        state.copyWith(
          status: ProfileEditStatus.failure,
          errorMessage: mapFirebaseAuthException(
            e,
            operationNotAllowedMessage:
                'Email/Password sign-in is disabled in Firebase.',
            requiresRecentLoginMessage:
                'For security, please sign in again and retry.',
            fallbackMessage: 'Update failed. Please try again.',
          ),
          successMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: ProfileEditStatus.failure,
          errorMessage: error.toString(),
          successMessage: null,
        ),
      );
    }
  }

  Future<void> _initPhoneIso(String phone) async {
    final trimmed = phone.trim();
    if (trimmed.isEmpty) return;
    try {
      final info = await PhoneNumber.getRegionInfoFromPhoneNumber(trimmed);
      final iso = info.isoCode;
      if (iso != null && iso.isNotEmpty) {
        emit(state.copyWith(phoneIso: iso));
      }
    } catch (_) {
      // Keep default ISO when parsing fails.
    }
  }

  Future<void> verifyPhoneOtp() async {
    if (state.status == ProfileEditStatus.otpVerifying ||
        state.verificationId == null ||
        state.otpCode.trim().isEmpty) {
      return;
    }
    emit(state.copyWith(status: ProfileEditStatus.otpVerifying));
    try {
      final current = _auth.currentUser;
      if (current == null) {
        emit(
          state.copyWith(
            status: ProfileEditStatus.failure,
            errorMessage: 'No signed-in user found.',
          ),
        );
        return;
      }
      final credential = PhoneAuthProvider.credential(
        verificationId: state.verificationId!,
        smsCode: state.otpCode.trim(),
      );
      await current.updatePhoneNumber(credential);
      final sentVerificationEmail = await _applyUpdates(current);
      emit(
        state.copyWith(
          status: ProfileEditStatus.success,
          successMessage: sentVerificationEmail
              ? 'Verification link sent to your new email. Please confirm it.'
              : null,
        ),
      );
    } on FirebaseAuthException catch (e) {
      emit(
        state.copyWith(
          status: ProfileEditStatus.failure,
          errorMessage: mapFirebaseAuthException(
            e,
            fallbackMessage: 'Phone verification failed. Please try again.',
          ),
          successMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: ProfileEditStatus.failure,
          errorMessage: error.toString(),
          successMessage: null,
        ),
      );
    }
  }

  Future<void> resendOtp() async {
    if (!state.canResend) return;
    await _sendPhoneOtp(state.phone.trim(), forceResend: true);
  }

  Future<void> _sendPhoneOtp(String phone, {bool forceResend = false}) async {
    emit(
      state.copyWith(
        status: ProfileEditStatus.otpSending,
        errorMessage: null,
        secondsLeft: 60,
        canResend: false,
      ),
    );
    _startTimer();
    await _auth.verifyPhoneNumber(
      phoneNumber: phone,
      timeout: const Duration(seconds: 60),
      forceResendingToken: forceResend ? state.resendToken : null,
      verificationCompleted: (credential) async {
        try {
          final current = _auth.currentUser;
          if (current == null) {
            emit(
              state.copyWith(
                status: ProfileEditStatus.failure,
                errorMessage: 'No signed-in user found.',
              ),
            );
            return;
          }
          await current.updatePhoneNumber(credential);
          final sentVerificationEmail = await _applyUpdates(current);
          emit(
            state.copyWith(
              status: ProfileEditStatus.success,
              successMessage: sentVerificationEmail
                  ? 'Verification link sent to your new email. Please confirm it.'
                  : null,
            ),
          );
        } catch (e) {
          emit(
            state.copyWith(
              status: ProfileEditStatus.failure,
              errorMessage: e.toString(),
              successMessage: null,
            ),
          );
        }
      },
      verificationFailed: (e) {
        emit(
          state.copyWith(
            status: ProfileEditStatus.failure,
            errorMessage: mapFirebaseAuthException(
              e,
              fallbackMessage: 'Phone verification failed. Please try again.',
            ),
            successMessage: null,
          ),
        );
      },
      codeSent: (verificationId, resendToken) {
        emit(
          state.copyWith(
            status: ProfileEditStatus.otpSent,
            verificationId: verificationId,
            resendToken: resendToken,
          ),
        );
      },
      codeAutoRetrievalTimeout: (verificationId) {
        emit(state.copyWith(verificationId: verificationId));
      },
    );
  }

  Future<bool> _applyUpdates(User current) async {
    final newEmail = state.email.trim();
    final emailChanged = newEmail.isNotEmpty && newEmail != _user.email.trim();
    if (emailChanged) {
      // Require inbox confirmation before applying email change.
      await current.verifyBeforeUpdateEmail(newEmail);
    }
    final authEmail = current.email?.trim() ?? '';
    final persistedEmail = emailChanged
        ? newEmail
        : (authEmail.isNotEmpty
              ? authEmail
              : (newEmail.isNotEmpty ? newEmail : _user.email));
    final persistedEmailVerified = emailChanged
        ? false
        : (authEmail.isNotEmpty ? current.emailVerified : _user.emailVerified);
    final updated = UserEntity(
      id: _user.id,
      fullName: state.fullName.trim(),
      email: persistedEmail,
      emailVerified: persistedEmailVerified,
      phone: AuthValidators.normalizePhone(state.phone),
      country: state.country.trim(),
      city: state.city.trim(),
      role: _user.role,
      restaurantId: _user.restaurantId,
    );
    await _updateUser(updated);
    return emailChanged;
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final next = state.secondsLeft - 1;
      if (next <= 0) {
        timer.cancel();
        emit(state.copyWith(secondsLeft: 0, canResend: true));
      } else {
        emit(state.copyWith(secondsLeft: next));
      }
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
