import '../entities/auth_credential_entity.dart';
import '../repositories/auth_repository.dart';

class LoginWithEmailUseCase {
  LoginWithEmailUseCase(this._repository);

  final AuthRepository _repository;

  Future<AuthCredentialEntity> call({
    required String email,
    required String password,
  }) {
    return _repository.loginWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
}
