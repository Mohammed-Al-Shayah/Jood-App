import 'package:equatable/equatable.dart';

import '../../../bookings/domain/entities/booking_entity.dart';
import '../../../offers/domain/entities/offer_entity.dart';
import '../../../restaurants/domain/entities/restaurant_entity.dart';
import '../../../users/domain/entities/user_entity.dart';

enum AdminOverviewStatus { initial, loading, success, failure }

class AdminOverviewData extends Equatable {
  const AdminOverviewData({
    this.restaurants = const [],
    this.offers = const [],
    this.users = const [],
    this.bookings = const [],
  });

  final List<RestaurantEntity> restaurants;
  final List<OfferEntity> offers;
  final List<UserEntity> users;
  final List<BookingEntity> bookings;

  @override
  List<Object?> get props => [restaurants, offers, users, bookings];
}

class AdminOverviewState extends Equatable {
  const AdminOverviewState({
    this.status = AdminOverviewStatus.initial,
    this.data = const AdminOverviewData(),
    this.errorMessage,
  });

  final AdminOverviewStatus status;
  final AdminOverviewData data;
  final String? errorMessage;

  AdminOverviewState copyWith({
    AdminOverviewStatus? status,
    AdminOverviewData? data,
    String? errorMessage,
  }) {
    return AdminOverviewState(
      status: status ?? this.status,
      data: data ?? this.data,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, data, errorMessage];
}
