import 'package:equatable/equatable.dart';
import '../../../users/domain/entities/user_entity.dart';

enum AdminUsersStatus { initial, loading, success, failure }

class AdminUsersState extends Equatable {
  const AdminUsersState({
    this.status = AdminUsersStatus.initial,
    this.users = const [],
    this.errorMessage,
  });

  final AdminUsersStatus status;
  final List<UserEntity> users;
  final String? errorMessage;

  AdminUsersState copyWith({
    AdminUsersStatus? status,
    List<UserEntity>? users,
    String? errorMessage,
  }) {
    return AdminUsersState(
      status: status ?? this.status,
      users: users ?? this.users,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, users, errorMessage];
}
