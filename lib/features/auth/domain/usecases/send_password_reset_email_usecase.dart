import '../repositories/auth_repository.dart';

class SendPasswordResetEmailUseCase {
  SendPasswordResetEmailUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call(String email) {
    return _repository.sendPasswordResetEmail(email);
  }
}
