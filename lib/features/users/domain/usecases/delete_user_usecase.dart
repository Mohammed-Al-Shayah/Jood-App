import '../repositories/user_repository.dart';

class DeleteUserUseCase {
  DeleteUserUseCase(this.repository);

  final UserRepository repository;

  Future<void> call(String id) {
    return repository.deleteUser(id);
  }
}
