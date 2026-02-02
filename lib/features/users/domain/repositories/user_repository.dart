import '../entities/user_entity.dart';

abstract class UserRepository {
  Future<UserEntity?> getUserById(String id);
  Future<UserEntity?> getUserByPhone(String phone);
  Future<void> createUser(UserEntity user);
  Future<void> updateUser(UserEntity user);
}
