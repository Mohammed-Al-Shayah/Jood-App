import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_user_by_id_usecase.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    required GetUserByIdUseCase getUserById,
    required FirebaseAuth auth,
  })  : _getUserById = getUserById,
        _auth = auth,
        super(const ProfileState());

  final GetUserByIdUseCase _getUserById;
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
      final profile = await _getUserById(user.uid);
      if (profile == null) {
        emit(
          state.copyWith(
            status: ProfileStatus.failure,
            errorMessage: 'Profile not found.',
          ),
        );
        return;
      }
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
}
