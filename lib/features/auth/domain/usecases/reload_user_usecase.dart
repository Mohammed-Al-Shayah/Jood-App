import 'package:firebase_auth/firebase_auth.dart';

import '../repositories/auth_repository.dart';

class ReloadUserUseCase {
  ReloadUserUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call(User user) {
    return _repository.reloadUser(user);
  }
}
