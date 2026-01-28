import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'otp_state.dart';

class OtpCubit extends Cubit<OtpState> {
  OtpCubit() : super(OtpState.initial()) {
    _startTimer();
  }

  Timer? _timer;

  void updateCode(String value) {
    emit(state.copyWith(code: value));
  }

  void resend() {
    emit(state.copyWith(secondsLeft: 60, canResend: false));
    _startTimer();
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
