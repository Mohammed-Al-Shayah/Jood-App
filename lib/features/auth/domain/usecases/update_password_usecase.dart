import '../entities/auth_user_entity.dart';
import '../repositories/auth_repository.dart';

class UpdatePasswordUseCase {
  UpdatePasswordUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call({
    required AuthUserEntity user,
    required String newPassword,
  }) {
    return _repository.updatePassword(user: user, newPassword: newPassword);
  }
}
