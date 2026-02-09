import '../../../../core/utils/auth_validators.dart';
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.fullName,
    required super.email,
    super.emailVerified = false,
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
      emailVerified: data['emailVerified'] as bool? ?? false,
      phone: data['phone'] as String? ?? '',
      country: data['country'] as String? ?? '',
      city: data['city'] as String? ?? '',
      role: data['role'] as String? ?? 'guest',
      restaurantId: data['restaurantId'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    final emailLower = email.trim().toLowerCase();
    return {
      'fullName': fullName,
      'email': email,
      'emailLower': emailLower,
      'emailVerified': emailVerified,
      'phone': phone,
      'phoneNormalized': AuthValidators.normalizePhone(phone),
      'country': country,
      'city': city,
      'role': role,
      'restaurantId': restaurantId,
    };
  }
}
