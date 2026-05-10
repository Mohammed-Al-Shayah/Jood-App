enum OtpMode { auth, register, updatePhone }

extension OtpModeApiValue on OtpMode {
  String get apiValue {
    switch (this) {
      case OtpMode.auth:
        return 'auth';
      case OtpMode.register:
        return 'register';
      case OtpMode.updatePhone:
        return 'update_phone';
    }
  }
}
