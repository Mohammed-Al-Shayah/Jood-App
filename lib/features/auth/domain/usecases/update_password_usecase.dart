import 'package:firebase_auth/firebase_auth.dart';

import '../repositories/auth_repository.dart';

class UpdatePasswordUseCase {
  UpdatePasswordUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call({required User user, required String newPassword}) {
    return _repository.updatePassword(user: user, newPassword: newPassword);
  }
}
