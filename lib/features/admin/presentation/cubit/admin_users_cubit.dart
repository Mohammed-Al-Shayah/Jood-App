import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../users/domain/entities/user_entity.dart';
import '../../../users/domain/usecases/delete_user_usecase.dart';
import '../../../users/domain/usecases/get_users_usecase.dart';
import '../../../users/domain/usecases/update_user_usecase.dart';
import 'admin_users_state.dart';

class AdminUsersCubit extends Cubit<AdminUsersState> {
  AdminUsersCubit({
    required GetUsersUseCase getUsers,
    required UpdateUserUseCase updateUser,
    required DeleteUserUseCase deleteUser,
  }) : _getUsers = getUsers,
       _updateUser = updateUser,
       _deleteUser = deleteUser,
       super(const AdminUsersState());

  final GetUsersUseCase _getUsers;
  final UpdateUserUseCase _updateUser;
  final DeleteUserUseCase _deleteUser;

  Future<void> load() async {
    emit(state.copyWith(status: AdminUsersStatus.loading));
    try {
      final users = await _getUsers();
      emit(
        state.copyWith(
          status: AdminUsersStatus.success,
          users: users,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AdminUsersStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> update(UserEntity user) async {
    try {
      await _updateUser(user);
      await load();
    } catch (e) {
      emit(
        state.copyWith(
          status: AdminUsersStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> delete(String id) async {
    try {
      await _deleteUser(id);
      await load();
    } catch (e) {
      emit(
        state.copyWith(
          status: AdminUsersStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
