import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jood/core/utils/app_strings.dart';

import '../../../attractions/domain/entities/attraction_entity.dart';
import '../../../attractions/domain/usecases/get_all_attractions_usecase.dart';
import '../../../auth/domain/usecases/get_current_user_usecase.dart';
import '../../../restaurants/domain/entities/restaurant_entity.dart';
import '../../../restaurants/domain/usecases/get_all_restaurants_usecase.dart';
import '../../domain/entities/booking_entity.dart';
import '../../domain/usecases/cancel_booking_usecase.dart';
import '../../domain/usecases/watch_my_bookings_usecase.dart';
import 'orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  OrdersCubit({
    required GetCurrentUserUseCase getCurrentUser,
    required WatchMyBookingsUseCase watchMyBookings,
    required CancelBookingUseCase cancelBooking,
    required GetAllRestaurantsUseCase getAllRestaurants,
    required GetAllAttractionsUseCase getAllAttractions,
  }) : _getCurrentUser = getCurrentUser,
       _watchMyBookings = watchMyBookings,
       _cancelBooking = cancelBooking,
       _getAllRestaurants = getAllRestaurants,
       _getAllAttractions = getAllAttractions,
       super(OrdersState.initial());

  final GetCurrentUserUseCase _getCurrentUser;
  final WatchMyBookingsUseCase _watchMyBookings;
  final CancelBookingUseCase _cancelBooking;
  final GetAllRestaurantsUseCase _getAllRestaurants;
  final GetAllAttractionsUseCase _getAllAttractions;

  StreamSubscription<List<BookingEntity>>? _ordersSubscription;
  List<RestaurantEntity>? _restaurants;
  List<AttractionEntity>? _attractions;
  String? _currentUserId;

  Future<void> initialize() async {
    if (isClosed) return;
    emit(state.copyWith(status: OrdersStatus.loading, errorMessage: null));
    final currentUser = _getCurrentUser();
    if (currentUser == null) {
      _currentUserId = null;
      await _ordersSubscription?.cancel();
      emit(
        state.copyWith(
          status: OrdersStatus.unauthenticated,
          orders: const [],
          venueDetailsByKey: const {},
          errorMessage: null,
        ),
      );
      return;
    }

    _currentUserId = currentUser.uid;
    await _ordersSubscription?.cancel();
    _ordersSubscription = _watchMyBookings(currentUser.uid).listen(
      _handleOrdersChanged,
      onError: (Object error) {
        if (isClosed) return;
        emit(state.copyWith(status: OrdersStatus.failure, errorMessage: null));
      },
    );
  }

  void _handleOrdersChanged(List<BookingEntity> orders) {
    if (isClosed) return;
    emit(
      state.copyWith(
        status: OrdersStatus.success,
        orders: orders,
        errorMessage: null,
      ),
    );
    unawaited(_hydrateVenueDetails(orders));
  }

  Future<void> _hydrateVenueDetails(List<BookingEntity> orders) async {
    final missingRestaurantDetails = orders.any(
      (booking) => _isRestaurantBooking(booking) && _needsVenueLookup(booking),
    );
    final missingAttractionDetails = orders.any(
      (booking) => !_isRestaurantBooking(booking) && _needsVenueLookup(booking),
    );

    if (!missingRestaurantDetails && !missingAttractionDetails) {
      return;
    }

    try {
      if (missingRestaurantDetails && _restaurants == null) {
        _restaurants = await _getAllRestaurants();
      }
      if (missingAttractionDetails && _attractions == null) {
        _attractions = await _getAllAttractions();
      }

      final nextVenueDetails = Map<String, OrderVenueDetails>.from(
        state.venueDetailsByKey,
      );

      for (final booking in orders) {
        if (!_needsVenueLookup(booking)) continue;
        final key = _venueKey(booking);
        if (nextVenueDetails.containsKey(key)) continue;

        if (_isRestaurantBooking(booking)) {
          final restaurant = _findRestaurant(booking.restaurantId);
          if (restaurant != null) {
            nextVenueDetails[key] = OrderVenueDetails(
              name: restaurant.name.trim().isEmpty
                  ? booking.restaurantId
                  : restaurant.name,
              coverImageUrl: restaurant.coverImageUrl.trim(),
            );
          }
          continue;
        }

        final attraction = _findAttraction(booking.restaurantId);
        if (attraction != null) {
          nextVenueDetails[key] = OrderVenueDetails(
            name: attraction.name.trim().isEmpty
                ? booking.restaurantId
                : attraction.name,
            coverImageUrl: attraction.coverImageUrl.trim(),
          );
        }
      }

      if (isClosed) return;
      emit(state.copyWith(venueDetailsByKey: nextVenueDetails));
    } catch (_) {
      // Keep the orders list visible even if venue hydration fails.
    }
  }

  Future<String?> cancelBooking(BookingEntity booking) async {
    final currentUserId = _currentUserId ?? _getCurrentUser()?.uid;
    if (currentUserId == null) {
      return AppStrings.pleaseLoginFirst;
    }

    if (isClosed) return AppStrings.failedToCancelBooking;
    emit(state.copyWith(cancellingBookingId: booking.id));
    try {
      await _cancelBooking(bookingId: booking.id, actorUserId: currentUserId);
      return null;
    } catch (error) {
      final raw = error.toString();
      if (raw.contains('CANCELLATION_EXPIRED') ||
          raw.contains(AppStrings.cancellationWindowEnded)) {
        return AppStrings.cancellationWindowEnded;
      }
      if (raw.trim().isNotEmpty) {
        return raw;
      }
      return AppStrings.failedToCancelBooking;
    } finally {
      if (!isClosed) {
        emit(state.copyWith(cancellingBookingId: null));
      }
    }
  }

  bool _needsVenueLookup(BookingEntity booking) {
    if (booking.restaurantId.trim().isEmpty) return false;
    return booking.coverImageUrlSnapshot?.trim().isEmpty != false;
  }

  bool _isRestaurantBooking(BookingEntity booking) {
    final type = (booking.bookableType ?? '').trim().toLowerCase();
    return type != 'attraction';
  }

  String _venueKey(BookingEntity booking) {
    final collection = _isRestaurantBooking(booking)
        ? 'restaurants'
        : 'attractions';
    return '$collection:${booking.restaurantId}';
  }

  RestaurantEntity? _findRestaurant(String id) {
    for (final restaurant in _restaurants ?? const <RestaurantEntity>[]) {
      if (restaurant.id == id) return restaurant;
    }
    return null;
  }

  AttractionEntity? _findAttraction(String id) {
    for (final attraction in _attractions ?? const <AttractionEntity>[]) {
      if (attraction.id == id) return attraction;
    }
    return null;
  }

  @override
  Future<void> close() async {
    await _ordersSubscription?.cancel();
    return super.close();
  }
}
