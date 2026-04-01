import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bookings/domain/entities/booking_entity.dart';
import '../../../bookings/domain/usecases/get_all_bookings_usecase.dart';
import '../../../offers/domain/entities/offer_entity.dart';
import '../../../offers/domain/usecases/get_offers_usecase.dart';
import '../../../restaurants/domain/entities/restaurant_entity.dart';
import '../../../restaurants/domain/usecases/get_all_restaurants_usecase.dart';
import '../../../users/domain/entities/user_entity.dart';
import '../../../users/domain/usecases/get_users_usecase.dart';
import 'admin_overview_state.dart';

class AdminOverviewCubit extends Cubit<AdminOverviewState> {
  AdminOverviewCubit({
    required GetAllRestaurantsUseCase getAllRestaurants,
    required GetOffersUseCase getOffers,
    required GetUsersUseCase getUsers,
    required GetAllBookingsUseCase getAllBookings,
  }) : _getAllRestaurants = getAllRestaurants,
       _getOffers = getOffers,
       _getUsers = getUsers,
       _getAllBookings = getAllBookings,
       super(const AdminOverviewState());

  final GetAllRestaurantsUseCase _getAllRestaurants;
  final GetOffersUseCase _getOffers;
  final GetUsersUseCase _getUsers;
  final GetAllBookingsUseCase _getAllBookings;

  Future<void> load() async {
    if (isClosed) return;
    emit(
      state.copyWith(status: AdminOverviewStatus.loading, errorMessage: null),
    );
    try {
      final results = await Future.wait<dynamic>([
        _getAllRestaurants(),
        _getOffers(),
        _getUsers(),
        _getAllBookings(),
      ]);
      if (isClosed) return;
      emit(
        state.copyWith(
          status: AdminOverviewStatus.success,
          data: AdminOverviewData(
            restaurants: results[0] as List<RestaurantEntity>,
            offers: results[1] as List<OfferEntity>,
            users: results[2] as List<UserEntity>,
            bookings: results[3] as List<BookingEntity>,
          ),
          errorMessage: null,
        ),
      );
    } catch (error) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: AdminOverviewStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }
}
