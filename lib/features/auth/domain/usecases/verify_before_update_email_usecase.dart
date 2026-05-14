import '../entities/auth_user_entity.dart';
import '../repositories/auth_repository.dart';

class VerifyBeforeUpdateEmailUseCase {
  VerifyBeforeUpdateEmailUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call({required AuthUserEntity user, required String newEmail}) {
    return _repository.verifyBeforeUpdateEmail(user: user, newEmail: newEmail);
  }
}
