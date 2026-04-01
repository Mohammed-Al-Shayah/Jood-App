import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/user_entity.dart';
import '../../../auth/domain/usecases/delete_account_usecase.dart';
import '../../../auth/domain/usecases/get_current_user_usecase.dart';
import '../../../auth/domain/usecases/reload_user_usecase.dart';
import '../../../auth/domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/get_user_by_id_usecase.dart';
import '../../domain/usecases/update_user_usecase.dart';
import 'profile_state.dart';

enum ProfileAccountActionStatus { success, reauthRequired, failure }

class ProfileAccountActionResult {
  const ProfileAccountActionResult({
    required this.status,
    required this.message,
  });

  final ProfileAccountActionStatus status;
  final String message;
}

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    required GetUserByIdUseCase getUserById,
    required UpdateUserUseCase updateUser,
    required GetCurrentUserUseCase getCurrentUser,
    required ReloadUserUseCase reloadUser,
    required SignOutUseCase signOut,
    required DeleteAccountUseCase deleteAccount,
  }) : _getUserById = getUserById,
       _updateUser = updateUser,
       _getCurrentUser = getCurrentUser,
       _reloadUser = reloadUser,
       _signOut = signOut,
       _deleteAccount = deleteAccount,
       super(const ProfileState());

  final GetUserByIdUseCase _getUserById;
  final UpdateUserUseCase _updateUser;
  final GetCurrentUserUseCase _getCurrentUser;
  final ReloadUserUseCase _reloadUser;
  final SignOutUseCase _signOut;
  final DeleteAccountUseCase _deleteAccount;

  Future<void> load() async {
    if (isClosed) return;
    emit(state.copyWith(status: ProfileStatus.loading, errorMessage: null));
    final user = _getCurrentUser();
    if (user == null) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: 'No signed-in user found.',
        ),
      );
      return;
    }
    try {
      await _reloadUser(user);
      if (isClosed) return;
      final refreshedUser = _getCurrentUser();
      if (refreshedUser == null) {
        if (isClosed) return;
        emit(
          state.copyWith(
            status: ProfileStatus.failure,
            errorMessage: 'No signed-in user found.',
          ),
        );
        return;
      }
      var profile = await _getUserById(refreshedUser.uid);
      if (isClosed) return;
      if (profile == null) {
        emit(
          state.copyWith(
            status: ProfileStatus.failure,
            errorMessage: 'Profile not found.',
          ),
        );
        return;
      }
      profile = await _syncEmailFromAuth(profile, refreshedUser);
      if (isClosed) return;
      emit(state.copyWith(status: ProfileStatus.success, user: profile));
    } catch (error) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<String?> signOut() async {
    try {
      await _signOut();
      return null;
    } catch (_) {
      return 'Unable to log out right now. Please try again.';
    }
  }

  Future<ProfileAccountActionResult> deleteAccount() async {
    try {
      await _deleteAccount();
      await _signOut();
      return const ProfileAccountActionResult(
        status: ProfileAccountActionStatus.success,
        message: 'Your account has been deleted.',
      );
    } on FirebaseFunctionsException catch (error) {
      if (_isReauthRequired(error)) {
        await _signOut();
        return const ProfileAccountActionResult(
          status: ProfileAccountActionStatus.reauthRequired,
          message:
              'Please log in again to confirm your identity, then retry deleting your account.',
        );
      }
      return ProfileAccountActionResult(
        status: ProfileAccountActionStatus.failure,
        message: error.message ?? 'Unable to delete account. Please try again.',
      );
    } catch (_) {
      return const ProfileAccountActionResult(
        status: ProfileAccountActionStatus.failure,
        message: 'Unable to delete account. Please try again.',
      );
    }
  }

  Future<UserEntity> _syncEmailFromAuth(
    UserEntity profile,
    User authUser,
  ) async {
    final authEmail = (authUser.email ?? '').trim();
    final emailChanged =
        authEmail.isNotEmpty && authEmail != profile.email.trim();
    final verifiedChanged =
        authEmail.isNotEmpty && profile.emailVerified != authUser.emailVerified;
    if (!emailChanged && !verifiedChanged) {
      return profile;
    }
    final updated = UserEntity(
      id: profile.id,
      fullName: profile.fullName,
      email: authEmail.isNotEmpty ? authEmail : profile.email,
      emailVerified: authEmail.isNotEmpty
          ? authUser.emailVerified
          : profile.emailVerified,
      phone: profile.phone,
      country: profile.country,
      city: profile.city,
      role: profile.role,
      restaurantId: profile.restaurantId,
    );
    await _updateUser(updated);
    return updated;
  }

  bool _isReauthRequired(FirebaseFunctionsException error) {
    final message = (error.message ?? '').toLowerCase();
    return error.code == 'unauthenticated' ||
        error.code == 'failed-precondition' ||
        error.code == 'permission-denied' ||
        message.contains('recent') ||
        message.contains('reauth');
  }
}
