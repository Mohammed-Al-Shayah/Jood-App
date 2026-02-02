import '../entities/user_entity.dart';
import '../repositories/user_repository.dart';

class GetUserByPhoneUseCase {
  GetUserByPhoneUseCase(this.repository);

  final UserRepository repository;

  Future<UserEntity?> call(String phone) {
    return repository.getUserByPhone(phone);
  }
}
