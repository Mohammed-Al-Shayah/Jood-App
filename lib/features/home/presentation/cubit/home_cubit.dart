import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/restaurant_repository.dart';
import '../../../users/domain/usecases/get_user_by_id_usecase.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required RestaurantRepository repository,
    required GetUserByIdUseCase getUserById,
    required FirebaseAuth auth,
  })  : _repository = repository,
        _getUserById = getUserById,
        _auth = auth,
        super(const HomeState());

  final RestaurantRepository _repository;
  final GetUserByIdUseCase _getUserById;
  final FirebaseAuth _auth;

  Future<void> fetchRestaurants() async {
    emit(state.copyWith(status: HomeStatus.loading));
    try {
      final restaurants = await _repository.getRestaurants();
      if (restaurants.isEmpty) {
        emit(state.copyWith(status: HomeStatus.empty, restaurants: const []));
      } else {
        emit(
          state.copyWith(
            status: HomeStatus.success,
            restaurants: restaurants,
          ),
        );
      }
    } catch (error) {
      emit(
        state.copyWith(
          status: HomeStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> fetchUserLocation() async {
    final user = _auth.currentUser;
    if (user == null) return;
    try {
      final profile = await _getUserById(user.uid);
      if (profile == null) return;
      emit(
        state.copyWith(
          userCity: profile.city,
          userCountry: profile.country,
        ),
      );
    } catch (_) {
      // Ignore profile errors; keep default location.
    }
  }
}
