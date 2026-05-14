import '../entities/auth_user_entity.dart';
import '../repositories/auth_repository.dart';

class GetCurrentUserUseCase {
  GetCurrentUserUseCase(this._repository);

  final AuthRepository _repository;

  AuthUserEntity? call() {
    return _repository.getCurrentUser();
  }
}
