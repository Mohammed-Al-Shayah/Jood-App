import '../entities/user_entity.dart';
import '../repositories/user_repository.dart';

class CreateUserUseCase {
  const CreateUserUseCase(this.repository);

  final UserRepository repository;

  Future<void> call(UserEntity user) {
    return repository.createUser(user);
  }
}
