enum OtpMode { auth, updatePhone }

extension OtpModeApiValue on OtpMode {
  String get apiValue {
    switch (this) {
      case OtpMode.auth:
        return 'auth';
      case OtpMode.updatePhone:
        return 'update_phone';
    }
  }
}
