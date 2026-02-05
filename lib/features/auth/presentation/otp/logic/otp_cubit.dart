import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

import '../../../../../core/bloc/safe_cubit.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/errors/auth_error_mapper.dart';
import '../../../../../core/utils/auth_validators.dart';
import '../../../domain/usecases/link_email_password_usecase.dart';
import '../../../domain/usecases/send_email_verification_usecase.dart';
import '../../../domain/usecases/send_phone_otp_usecase.dart';
import '../../../domain/usecases/verify_otp_usecase.dart';
import '../../../../users/domain/entities/user_entity.dart';
import '../../../../users/domain/usecases/create_user_usecase.dart';
import '../../../../users/domain/usecases/sync_auth_user_usecase.dart';
import 'otp_state.dart';
import '../verify_otp_args.dart';

class OtpCubit extends SafeCubit<OtpState> {
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
       _resendToken = args.resendToken,
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
  int? _resendToken;
  Timer? _timer;

  void updateCode(String value) {
    emitSafe(state.copyWith(code: value));
  }

  Future<void> resend() async {
    emitSafe(state.copyWith(secondsLeft: 60, canResend: false));
    _startTimer();
    try {
      await _sendPhoneOtp(
        phoneNumber: _args.phone,
        timeout: const Duration(seconds: 60),
        forceResendingToken: _resendToken,
        verificationCompleted: (_) {},
        verificationFailed: (e) {
          emitSafe(
            state.copyWith(
              status: OtpStatus.failure,
              errorMessage: mapFirebaseAuthException(
                e,
                operationNotAllowedMessage: 'Phone auth is not enabled.',
                fallbackMessage: 'Phone verification failed. Please try again.',
              ),
            ),
          );
        },
        codeSent: (verificationId, resendToken) {
          _verificationId = verificationId;
          _resendToken = resendToken;
        },
        codeAutoRetrievalTimeout: (verificationId) {
          _verificationId = verificationId;
        },
      );
    } on FirebaseAuthException catch (e) {
      emitSafe(
        state.copyWith(
          status: OtpStatus.failure,
          errorMessage: mapFirebaseAuthException(
            e,
            operationNotAllowedMessage: 'Phone auth is not enabled.',
            fallbackMessage: 'Phone verification failed. Please try again.',
          ),
        ),
      );
    } catch (_) {
      emitSafe(
        state.copyWith(
          status: OtpStatus.failure,
          errorMessage: AppStrings.somethingWentWrong,
        ),
      );
    }
  }

  Future<void> verify() async {
    if (!state.isValid || state.status == OtpStatus.verifying) return;
    emitSafe(state.copyWith(status: OtpStatus.verifying, errorMessage: null));
    try {
      final result = await _verifyOtp(
        verificationId: _verificationId,
        smsCode: state.code,
      );
      final user = result.user;
      if (user == null) {
        emitSafe(
          state.copyWith(
            status: OtpStatus.failure,
            errorMessage: 'Unable to verify phone. Please try again.',
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
    } on FirebaseAuthException catch (e) {
      emitSafe(
        state.copyWith(
          status: OtpStatus.failure,
          errorMessage: mapFirebaseAuthException(
            e,
            operationNotAllowedMessage: 'Phone auth is not enabled.',
            fallbackMessage: 'Phone verification failed. Please try again.',
          ),
        ),
      );
    } catch (_) {
      emitSafe(
        state.copyWith(
          status: OtpStatus.failure,
          errorMessage: AppStrings.somethingWentWrong,
        ),
      );
    }
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

  Future<void> _finishRegisterFlow(User user) async {
    final email = (_args.email ?? '').trim();
    if (email.isEmpty) {
      throw FirebaseAuthException(code: 'invalid-email');
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
    User user,
    String email,
    String password,
  ) async {
    try {
      await _linkEmailPassword(user: user, email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'provider-already-linked') {
        return;
      }
      throw FirebaseAuthException(
        code: e.code,
        message: mapFirebaseAuthException(
          e,
          operationNotAllowedMessage:
              'Email/password accounts are not enabled.',
          fallbackMessage: 'Sign up failed. Please try again.',
        ),
      );
    }
  }
}
