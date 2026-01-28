import '../entities/user_entity.dart';
import '../repositories/user_repository.dart';

class GetUserByIdUseCase {
  const GetUserByIdUseCase(this.repository);

  final UserRepository repository;

  Future<UserEntity?> call(String id) {
    return repository.getUserById(id);
  }
}
