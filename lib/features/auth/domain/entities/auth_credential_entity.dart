import 'package:equatable/equatable.dart';

import 'auth_user_entity.dart';

class AuthCredentialEntity extends Equatable {
  const AuthCredentialEntity({required this.user});

  final AuthUserEntity? user;

  @override
  List<Object?> get props => [user];
}
