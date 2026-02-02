import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../users/domain/entities/user_entity.dart';
import '../../../../users/domain/usecases/create_user_usecase.dart';
import '../../../../../core/utils/auth_validators.dart';
import 'otp_state.dart';
import '../verify_otp_args.dart';

class OtpCubit extends Cubit<OtpState> {
  OtpCubit({
    required FirebaseAuth auth,
    required CreateUserUseCase createUser,
    required VerifyOtpArgs args,
  })  : _auth = auth,
        _createUser = createUser,
        _args = args,
        _verificationId = args.verificationId,
        _resendToken = args.resendToken,
        super(OtpState.initial()) {
    _startTimer();
  }

  final FirebaseAuth _auth;
  final CreateUserUseCase _createUser;
  final VerifyOtpArgs _args;

  String _verificationId;
  int? _resendToken;
  Timer? _timer;

  void updateCode(String value) {
    emit(state.copyWith(code: value));
  }

  Future<void> resend() async {
    emit(state.copyWith(secondsLeft: 60, canResend: false));
    _startTimer();
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: _args.phone,
        timeout: const Duration(seconds: 60),
        forceResendingToken: _resendToken,
        verificationCompleted: (_) {},
        verificationFailed: (e) {
          emit(
            state.copyWith(
              status: OtpStatus.failure,
              errorMessage: _mapPhoneError(e),
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
      emit(
        state.copyWith(
          status: OtpStatus.failure,
          errorMessage: _mapPhoneError(e),
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: OtpStatus.failure,
          errorMessage: 'Something went wrong. Please try again.',
        ),
      );
    }
  }

  Future<void> verify() async {
    if (!state.isValid || state.status == OtpStatus.verifying) return;
    emit(state.copyWith(status: OtpStatus.verifying, errorMessage: null));
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: state.code,
      );
      final result = await _auth.signInWithCredential(credential);
      final user = result.user;
      if (user == null) {
        emit(
          state.copyWith(
            status: OtpStatus.failure,
            errorMessage: 'Unable to verify phone. Please try again.',
          ),
        );
        return;
      }
      final linked = await _linkPasswordCredential(
        user,
        _args.phone,
        _args.password,
      );
      if (!linked) return;
      await user.updateDisplayName(_args.fullName.trim());
      await _createUser(
        UserEntity(
          id: user.uid,
          fullName: _args.fullName.trim(),
          email: (_args.email ?? '').trim(),
          phone: _args.phone.trim(),
          country: _args.country.trim(),
          city: _args.city.trim(),
          role: 'customer',
        ),
      );
      emit(state.copyWith(status: OtpStatus.success));
    } on FirebaseAuthException catch (e) {
      emit(
        state.copyWith(
          status: OtpStatus.failure,
          errorMessage: _mapPhoneError(e),
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: OtpStatus.failure,
          errorMessage: 'Something went wrong. Please try again.',
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

  String _mapPhoneError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-phone-number':
        return 'Invalid phone number.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      case 'invalid-verification-code':
        return 'Invalid OTP code.';
      case 'session-expired':
        return 'OTP session expired. Please resend the code.';
      case 'quota-exceeded':
        return 'SMS quota exceeded. Please try again later.';
      case 'credential-already-in-use':
        return 'Phone number already in use.';
      default:
        return e.message ?? 'Phone verification failed. Please try again.';
    }
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
          status: OtpStatus.failure,
          errorMessage: _mapPhoneError(e),
        ),
      );
      return false;
    } catch (_) {
      emit(
        state.copyWith(
          status: OtpStatus.failure,
          errorMessage: 'Something went wrong. Please try again.',
        ),
      );
      return false;
    }
  }
}
