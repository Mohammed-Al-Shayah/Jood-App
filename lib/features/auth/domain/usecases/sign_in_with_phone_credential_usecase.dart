import 'package:firebase_auth/firebase_auth.dart';

import '../repositories/auth_repository.dart';

class SignInWithPhoneCredentialUseCase {
  SignInWithPhoneCredentialUseCase(this._repository);

  final AuthRepository _repository;

  Future<UserCredential> call(AuthCredential credential) {
    return _repository.signInWithPhoneCredential(credential);
  }
}
