import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/utils/auth_validators.dart';
import '../entities/user_entity.dart';
import 'create_user_usecase.dart';
import 'get_user_by_id_usecase.dart';
import 'update_user_usecase.dart';

class SyncAuthUserUseCase {
  const SyncAuthUserUseCase({
    required GetUserByIdUseCase getUserById,
    required CreateUserUseCase createUser,
    required UpdateUserUseCase updateUser,
  }) : _getUserById = getUserById,
       _createUser = createUser,
       _updateUser = updateUser;

  final GetUserByIdUseCase _getUserById;
  final CreateUserUseCase _createUser;
  final UpdateUserUseCase _updateUser;

  Future<void> call(User authUser, {UserEntity? fallback}) async {
    final existing = await _getUserById(authUser.uid);
    final authPhone = AuthValidators.normalizePhone(authUser.phoneNumber ?? '');
    final fallbackPhone = AuthValidators.normalizePhone(fallback?.phone ?? '');
    final resolvedPhone = authPhone.isNotEmpty
        ? authPhone
        : (existing?.phone.trim().isNotEmpty ?? false)
        ? existing!.phone.trim()
        : fallbackPhone;
    final authEmail = (authUser.email ?? '').trim();
    final resolvedEmail = authEmail.isNotEmpty
        ? authEmail
        : existing?.email.trim() ?? fallback?.email.trim() ?? '';
    final resolvedEmailVerified = authEmail.isNotEmpty
        ? authUser.emailVerified
        : existing?.emailVerified ?? fallback?.emailVerified ?? false;

    final merged = UserEntity(
      id: authUser.uid,
      fullName: _firstNonEmpty(
        authUser.displayName?.trim(),
        existing?.fullName.trim(),
        fallback?.fullName.trim(),
      ),
      email: resolvedEmail,
      phone: resolvedPhone,
      country: _firstNonEmpty(
        existing?.country.trim(),
        fallback?.country.trim(),
      ),
      city: _firstNonEmpty(existing?.city.trim(), fallback?.city.trim()),
      role: _firstNonEmpty(
        existing?.role.trim(),
        fallback?.role.trim(),
        'customer',
      ),
      restaurantId: existing?.restaurantId ?? fallback?.restaurantId,
      emailVerified: resolvedEmailVerified,
    );

    if (existing == null) {
      await _createUser(merged);
      return;
    }
    await _updateUser(merged);
  }

  String _firstNonEmpty(String? first, [String? second, String? third]) {
    if (first != null && first.isNotEmpty) return first;
    if (second != null && second.isNotEmpty) return second;
    if (third != null && third.isNotEmpty) return third;
    return '';
  }
}
