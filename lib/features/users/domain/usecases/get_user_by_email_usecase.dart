import '../entities/user_entity.dart';
import '../repositories/user_repository.dart';

class GetUserByEmailUseCase {
  const GetUserByEmailUseCase(this.repository);

  final UserRepository repository;

  Future<UserEntity?> call(String email) {
    return repository.getUserByEmail(email);
  }
}
