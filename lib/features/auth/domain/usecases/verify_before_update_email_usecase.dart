import 'package:firebase_auth/firebase_auth.dart';

import '../repositories/auth_repository.dart';

class VerifyBeforeUpdateEmailUseCase {
  VerifyBeforeUpdateEmailUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call({required User user, required String newEmail}) {
    return _repository.verifyBeforeUpdateEmail(user: user, newEmail: newEmail);
  }
}
