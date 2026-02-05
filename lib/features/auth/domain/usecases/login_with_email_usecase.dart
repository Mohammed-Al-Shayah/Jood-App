import 'package:firebase_auth/firebase_auth.dart';

import '../repositories/auth_repository.dart';

class LoginWithEmailUseCase {
  LoginWithEmailUseCase(this._repository);

  final AuthRepository _repository;

  Future<UserCredential> call({
    required String email,
    required String password,
  }) {
    return _repository.loginWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
}
