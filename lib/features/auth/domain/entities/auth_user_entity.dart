import 'package:equatable/equatable.dart';

class AuthUserEntity extends Equatable {
  const AuthUserEntity({
    required this.uid,
    this.email,
    this.phoneNumber,
    this.displayName,
    this.emailVerified = false,
  });

  final String uid;
  final String? email;
  final String? phoneNumber;
  final String? displayName;
  final bool emailVerified;

  @override
  List<Object?> get props => [
    uid,
    email,
    phoneNumber,
    displayName,
    emailVerified,
  ];
}
