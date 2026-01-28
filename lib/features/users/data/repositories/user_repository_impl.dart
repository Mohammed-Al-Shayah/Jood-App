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
  Future<void> createUser(UserEntity user) {
    final model = UserModel(
      id: user.id,
      fullName: user.fullName,
      email: user.email,
      phone: user.phone,
      role: user.role,
    );
    return remoteDataSource.createUser(model);
  }
}
