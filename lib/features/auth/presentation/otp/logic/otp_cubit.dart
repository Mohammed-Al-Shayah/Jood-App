import 'dart:async';

import '../../../../../core/bloc/safe_cubit.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/errors/auth_error.dart';
import '../../../../../core/errors/auth_error_mapper.dart';
import '../../../../../core/utils/auth_validators.dart';
import '../../../../users/domain/entities/user_entity.dart';
import '../../../../users/domain/usecases/create_user_usecase.dart';
import '../../../../users/domain/usecases/sync_auth_user_usecase.dart';
import '../../../domain/entities/auth_user_entity.dart';
import '../../../domain/entities/otp_mode.dart';
import '../../../domain/usecases/link_email_password_usecase.dart';
import '../../../domain/usecases/send_email_verification_usecase.dart';
import '../../../domain/usecases/send_phone_otp_usecase.dart';
import '../../../domain/usecases/verify_otp_usecase.dart';
import '../verify_otp_args.dart';
import 'otp_state.dart';

class OtpCubit extends SafeCubit<OtpState> {
  static const int _defaultResendCooldownSeconds = 60;

  OtpCubit({
    required SendPhoneOtpUseCase sendPhoneOtp,
    required VerifyOtpUseCase verifyOtp,
    required LinkEmailPasswordUseCase linkEmailPassword,
    required SendEmailVerificationUseCase sendEmailVerification,
    required CreateUserUseCase createUser,
    required SyncAuthUserUseCase syncAuthUser,
    required VerifyOtpArgs args,
  }) : _sendPhoneOtp = sendPhoneOtp,
       _verifyOtp = verifyOtp,
       _linkEmailPassword = linkEmailPassword,
       _sendEmailVerification = sendEmailVerification,
       _createUser = createUser,
       _syncAuthUser = syncAuthUser,
       _args = args,
       _verificationId = args.verificationId,
       super(OtpState.initial()) {
    _startTimer();
  }

  final SendPhoneOtpUseCase _sendPhoneOtp;
  final VerifyOtpUseCase _verifyOtp;
  final LinkEmailPasswordUseCase _linkEmailPassword;
  final SendEmailVerificationUseCase _sendEmailVerification;
  final CreateUserUseCase _createUser;
  final SyncAuthUserUseCase _syncAuthUser;
  final VerifyOtpArgs _args;

  String _verificationId;
  Timer? _timer;

  void updateCode(String value) {
    emitSafe(state.copyWith(code: value));
  }

  Future<void> resend() async {
    if (!state.canResend) return;
    emitSafe(state.copyWith(status: OtpStatus.initial, errorMessage: null));
    try {
      _verificationId = await _sendPhoneOtp(phoneNumber: _args.phone);
      _applyResendCooldown(_defaultResendCooldownSeconds);
    } catch (error) {
      final retryAfterSeconds = authRetryAfterSeconds(error);
      if (retryAfterSeconds != null) {
        _applyResendCooldown(retryAfterSeconds);
      } else {
        emitSafe(state.copyWith(secondsLeft: 0, canResend: true));
      }
      emitSafe(
        state.copyWith(
          status: OtpStatus.failure,
          errorMessage: isAuthError(error)
              ? mapAuthError(
                  error,
                  operationNotAllowedMessage: AppStrings.phoneAuthNotEnabled,
                  fallbackMessage: AppStrings.unableToVerifyPhonePleaseTryAgain,
                )
              : AppStrings.somethingWentWrong,
        ),
      );
    }
  }

  Future<void> verify() async {
    if (!state.isValid || state.status == OtpStatus.verifying) return;
    emitSafe(state.copyWith(status: OtpStatus.verifying, errorMessage: null));
    try {
      final result = await _verifyOtp(
        phoneNumber: _args.phone,
        verificationId: _verificationId,
        smsCode: state.code,
        mode: OtpMode.auth,
      );
      final user = result?.user;
      if (user == null) {
        emitSafe(
          state.copyWith(
            status: OtpStatus.failure,
            errorMessage: AppStrings.unableToVerifyPhonePleaseTryAgain,
          ),
        );
        return;
      }
      if (_args.flow == OtpFlow.register) {
        await _finishRegisterFlow(user);
      } else {
        await _syncAuthUser(user);
      }
      emitSafe(state.copyWith(status: OtpStatus.success));
    } catch (error) {
      emitSafe(
        state.copyWith(
          status: OtpStatus.failure,
          errorMessage: isAuthError(error)
              ? mapAuthError(
                  error,
                  operationNotAllowedMessage: AppStrings.phoneAuthNotEnabled,
                  fallbackMessage: AppStrings.unableToVerifyPhonePleaseTryAgain,
                )
              : AppStrings.somethingWentWrong,
        ),
      );
    }
  }

  void _applyResendCooldown(int seconds) {
    final safeSeconds = seconds <= 0 ? 0 : seconds;
    emitSafe(state.copyWith(secondsLeft: safeSeconds, canResend: false));
    if (safeSeconds == 0) {
      _timer?.cancel();
      emitSafe(state.copyWith(secondsLeft: 0, canResend: true));
      return;
    }
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final next = state.secondsLeft - 1;
      if (next <= 0) {
        timer.cancel();
        emitSafe(state.copyWith(secondsLeft: 0, canResend: true));
      } else {
        emitSafe(state.copyWith(secondsLeft: next));
      }
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }

  Future<void> _finishRegisterFlow(AuthUserEntity user) async {
    final email = (_args.email ?? '').trim();
    if (email.isEmpty) {
      throw const AppAuthException(code: 'invalid-email');
    }
    final password = (_args.password ?? '').trim();
    await _linkPasswordCredential(user, email, password);
    await _sendEmailVerification(user);
    final profile = UserEntity(
      id: user.uid,
      fullName: (_args.fullName ?? '').trim(),
      email: email,
      emailVerified: false,
      phone: AuthValidators.normalizePhone(_args.phone),
      country: (_args.country ?? '').trim(),
      city: (_args.city ?? '').trim(),
      role: 'customer',
    );
    await _createUser(profile);
    await _syncAuthUser(user, fallback: profile);
  }

  Future<void> _linkPasswordCredential(
    AuthUserEntity user,
    String email,
    String password,
  ) async {
    try {
      await _linkEmailPassword(user: user, email: email, password: password);
    } catch (error) {
      final code = authErrorCode(error);
      if (code == 'provider-already-linked') {
        return;
      }
      if (code == 'email-already-in-use' ||
          code == 'credential-already-in-use') {
        throw AppAuthException(
          code: 'email-already-in-use',
          message: AppStrings.emailAlreadyRegisteredUseDifferentOrLogin,
        );
      }
      if (isAuthError(error)) {
        throw AppAuthException(
          code: code ?? 'request-failed',
          message: mapAuthError(
            error,
            operationNotAllowedMessage:
                AppStrings.emailPasswordAccountsNotEnabled,
            fallbackMessage: AppStrings.signUpFailedPleaseTryAgain,
          ),
        );
      }
      rethrow;
    }
  }
}
