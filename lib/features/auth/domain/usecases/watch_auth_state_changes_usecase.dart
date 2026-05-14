import '../entities/auth_user_entity.dart';
import '../repositories/auth_repository.dart';

class WatchAuthStateChangesUseCase {
  WatchAuthStateChangesUseCase(this._repository);

  final AuthRepository _repository;

  Stream<AuthUserEntity?> call() {
    return _repository.authStateChanges();
  }
}
