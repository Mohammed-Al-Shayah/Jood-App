import 'package:firebase_auth/firebase_auth.dart';

import '../repositories/auth_repository.dart';

class SendEmailVerificationUseCase {
  SendEmailVerificationUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call(User user) {
    return _repository.sendEmailVerification(user);
  }
}
