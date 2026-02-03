import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.country,
    required this.city,
    required this.role,
    this.restaurantId,
  });

  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String country;
  final String city;
  final String role;
  final String? restaurantId;

  @override
  List<Object?> get props => [
    id,
    fullName,
    email,
    phone,
    country,
    city,
    role,
    restaurantId,
  ];
}
