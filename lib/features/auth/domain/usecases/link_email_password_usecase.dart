import 'package:firebase_auth/firebase_auth.dart';

import '../repositories/auth_repository.dart';

class LinkEmailPasswordUseCase {
  LinkEmailPasswordUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call({
    required User user,
    required String email,
    required String password,
  }) {
    return _repository.linkEmailPassword(
      user: user,
      email: email,
      password: password,
    );
  }
}
