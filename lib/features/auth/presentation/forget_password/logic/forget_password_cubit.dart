import '../../../../../core/bloc/safe_cubit.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/errors/auth_error_mapper.dart';
import '../../../../../core/utils/auth_validators.dart';
import '../../../../../features/users/domain/usecases/get_user_by_phone_usecase.dart';
import '../../../domain/usecases/send_password_reset_email_usecase.dart';
import '../../../domain/usecases/send_phone_otp_usecase.dart';
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

        final verificationId = await _sendPhoneOtp(phoneNumber: normalizedPhone);
        emitSafe(
          state.copyWith(
            status: ForgetPasswordStatus.phoneOtpSent,
            verificationId: verificationId,
            resendToken: null,
          ),
        );
      } else {
        await _sendPasswordResetEmail(input);
        emitSafe(state.copyWith(status: ForgetPasswordStatus.success));
      }
    } catch (error) {
      emitSafe(
        state.copyWith(
          status: ForgetPasswordStatus.failure,
          errorMessage: isAuthError(error)
              ? mapAuthError(
                  error,
                  operationNotAllowedMessage:
                      'Phone authentication is not enabled for this project.',
                  fallbackMessage: 'Request failed. Please try again.',
                )
              : AppStrings.somethingWentWrong,
        ),
      );
    }
  }
}