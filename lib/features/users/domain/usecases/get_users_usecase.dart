import '../entities/user_entity.dart';
import '../repositories/user_repository.dart';

class GetUsersUseCase {
  GetUsersUseCase(this.repository);

  final UserRepository repository;

  Future<List<UserEntity>> call() {
    return repository.getUsers();
  }
}
