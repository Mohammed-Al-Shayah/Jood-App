import '../entities/user_entity.dart';
import '../repositories/user_repository.dart';

class UpdateUserUseCase {
  const UpdateUserUseCase(this.repository);

  final UserRepository repository;

  Future<void> call(UserEntity user) {
    return repository.updateUser(user);
  }
}
