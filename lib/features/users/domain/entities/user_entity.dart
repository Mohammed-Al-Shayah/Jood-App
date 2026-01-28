import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
  });

  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String role;

  @override
  List<Object?> get props => [id, fullName, email, phone, role];
}
