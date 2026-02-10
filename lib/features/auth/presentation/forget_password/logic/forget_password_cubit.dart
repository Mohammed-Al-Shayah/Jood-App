import 'package:firebase_auth/firebase_auth.dart';

import '../../../../../core/bloc/safe_cubit.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/errors/auth_error_mapper.dart';
import '../../../../../core/utils/auth_validators.dart';
import '../../../domain/usecases/send_password_reset_email_usecase.dart';
import '../../../domain/usecases/send_phone_otp_usecase.dart';
import '../../../../../features/users/domain/usecases/get_user_by_phone_usecase.dart';
import 'forget_password_state.dart';

class ForgetPasswordCubit extends SafeCubit<ForgetPasswordState> {
  ForgetPasswordCubit({
    required SendPhoneOtpUseCase sendPhoneOtp,
    required SendPasswordResetEmailUseCase sendPasswordResetEmail,
    required GetUserByPhoneUseCase getUserByPhone,
  }) : _sendPhoneOtp = sendPhoneOtp,
       _sendPasswordResetEmail = sendPasswordResetEmail,
       _getUserByPhone = getUserByPhone,
       super(ForgetPasswordState.initial());

  final SendPhoneOtpUseCase _sendPhoneOtp;
  final SendPasswordResetEmailUseCase _sendPasswordResetEmail;
  final GetUserByPhoneUseCase _getUserByPhone;

  void updateIdentifier(String value) {
    final input = value.trim();
    final isValid = state.method == ForgetPasswordMethod.email
        ? AuthValidators.isEmail(input)
        : AuthValidators.isPhone(input);
    emitSafe(state.copyWith(input: value, isValid: isValid));
  }

  void updateEmail(String value) => updateIdentifier(value);

  void updatePhoneIso(String value) {
    if (value.trim().isEmpty) return;
    emitSafe(state.copyWith(phoneIso: value));
  }

  void setMethod(ForgetPasswordMethod method) {
    emitSafe(
      state.copyWith(
        method: method,
        input: '',
        isValid: false,
        status: ForgetPasswordStatus.initial,
        errorMessage: null,
      ),
    );
  }

  Future<void> submit() async {
    if (!state.isValid || state.status == ForgetPasswordStatus.loading) return;
    emitSafe(
      state.copyWith(
        status: ForgetPasswordStatus.loading,
        errorMessage: null,
        verificationId: null,
        resendToken: null,
      ),
    );
    try {
      final input = state.input.trim();
      if (state.method == ForgetPasswordMethod.phone) {
        final normalizedPhone = AuthValidators.normalizePhone(input);
        final user = await _getUserByPhone(normalizedPhone);
        if (user == null) {
          emitSafe(
            state.copyWith(
              status: ForgetPasswordStatus.failure,
              errorMessage: 'No user found for this phone.',
            ),
          );
          return;
        }

        await _sendPhoneOtp(
          phoneNumber: input,
          timeout: const Duration(seconds: 60),
          verificationCompleted: (_) {},
          verificationFailed: (e) {
            emitSafe(
              state.copyWith(
                status: ForgetPasswordStatus.failure,
                errorMessage: mapFirebaseAuthException(
                  e,
                  operationNotAllowedMessage:
                      'Phone authentication is not enabled for this project.',
                  fallbackMessage: 'Request failed. Please try again.',
                ),
              ),
            );
          },
          codeSent: (verificationId, resendToken) {
            emitSafe(
              state.copyWith(
                status: ForgetPasswordStatus.phoneOtpSent,
                verificationId: verificationId,
                resendToken: resendToken,
              ),
            );
          },
          codeAutoRetrievalTimeout: (_) {},
        );
      } else {
        await _sendPasswordResetEmail(input);
        emitSafe(state.copyWith(status: ForgetPasswordStatus.success));
      }
    } on FirebaseAuthException catch (e) {
      emitSafe(
        state.copyWith(
          status: ForgetPasswordStatus.failure,
          errorMessage: mapFirebaseAuthException(
            e,
            operationNotAllowedMessage:
                'Phone authentication is not enabled for this project.',
            fallbackMessage: 'Request failed. Please try again.',
          ),
        ),
      );
    } catch (_) {
      emitSafe(
        state.copyWith(
          status: ForgetPasswordStatus.failure,
          errorMessage: AppStrings.somethingWentWrong,
        ),
      );
    }
  }
}
