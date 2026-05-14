import '../entities/auth_user_entity.dart';
import '../repositories/auth_repository.dart';

class ReloadUserUseCase {
  ReloadUserUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call(AuthUserEntity user) {
    return _repository.reloadUser(user);
  }
}
