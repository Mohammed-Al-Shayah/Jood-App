import '../entities/auth_user_entity.dart';
import '../repositories/auth_repository.dart';

class SendEmailVerificationUseCase {
  SendEmailVerificationUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call(AuthUserEntity user) {
    return _repository.sendEmailVerification(user);
  }
}
