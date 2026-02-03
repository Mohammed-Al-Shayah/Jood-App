import '../../../../core/utils/auth_validators.dart';
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.fullName,
    required super.email,
    required super.phone,
    required super.country,
    required super.city,
    required super.role,
    super.restaurantId,
  });

  factory UserModel.fromMap(String id, Map<String, dynamic> data) {
    return UserModel(
      id: id,
      fullName: data['fullName'] as String? ?? '',
      email: data['email'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      country: data['country'] as String? ?? '',
      city: data['city'] as String? ?? '',
      role: data['role'] as String? ?? 'guest',
      restaurantId: data['restaurantId'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'phoneNormalized': AuthValidators.normalizePhone(phone),
      'country': country,
      'city': city,
      'role': role,
      'restaurantId': restaurantId,
    };
  }
}
