import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/get_user_by_id_usecase.dart';
import '../../domain/usecases/update_user_usecase.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    required GetUserByIdUseCase getUserById,
    required UpdateUserUseCase updateUser,
    required FirebaseAuth auth,
  }) : _getUserById = getUserById,
       _updateUser = updateUser,
       _auth = auth,
       super(const ProfileState());

  final GetUserByIdUseCase _getUserById;
  final UpdateUserUseCase _updateUser;
  final FirebaseAuth _auth;

  Future<void> load() async {
    emit(state.copyWith(status: ProfileStatus.loading, errorMessage: null));
    final user = _auth.currentUser;
    if (user == null) {
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: 'No signed-in user found.',
        ),
      );
      return;
    }
    try {
      await user.reload();
      final refreshedUser = _auth.currentUser;
      if (refreshedUser == null) {
        emit(
          state.copyWith(
            status: ProfileStatus.failure,
            errorMessage: 'No signed-in user found.',
          ),
        );
        return;
      }
      var profile = await _getUserById(refreshedUser.uid);
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
      emit(state.copyWith(status: ProfileStatus.success, user: profile));
    } catch (error) {
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: error.toString(),
        ),
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
}
