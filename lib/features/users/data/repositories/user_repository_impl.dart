import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_remote_data_source.dart';
import '../models/user_model.dart';

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl({required this.remoteDataSource});

  final UserRemoteDataSource remoteDataSource;

  @override
  Future<UserEntity?> getUserById(String id) {
    return remoteDataSource.getUserById(id);
  }

  @override
  Future<UserEntity?> getUserByPhone(String phone) {
    return remoteDataSource.getUserByPhone(phone);
  }

  @override
  Future<void> createUser(UserEntity user) {
    final model = UserModel(
      id: user.id,
      fullName: user.fullName,
      email: user.email,
      emailVerified: user.emailVerified,
      phone: user.phone,
      country: user.country,
      city: user.city,
      role: user.role,
      restaurantId: user.restaurantId,
    );
    return remoteDataSource.createUser(model);
  }

  @override
  Future<void> updateUser(UserEntity user) {
    final model = UserModel(
      id: user.id,
      fullName: user.fullName,
      email: user.email,
      emailVerified: user.emailVerified,
      phone: user.phone,
      country: user.country,
      city: user.city,
      role: user.role,
      restaurantId: user.restaurantId,
    );
    return remoteDataSource.updateUser(model);
  }

  @override
  Future<List<UserEntity>> getUsers() {
    return remoteDataSource.getUsers();
  }

  @override
  Future<void> deleteUser(String id) {
    return remoteDataSource.deleteUser(id);
  }
}
