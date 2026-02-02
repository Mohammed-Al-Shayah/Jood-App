import 'package:equatable/equatable.dart';

import '../../../restaurants/domain/entities/restaurant_entity.dart';

enum HomeStatus { initial, loading, success, empty, failure }
enum SortField { price, discount, rating }
enum SortOrder { asc, desc }

class HomeState extends Equatable {
  const HomeState({
    this.status = HomeStatus.initial,
    this.restaurants = const [],
    this.filteredRestaurants = const [],
    this.query = '',
    this.sortField,
    this.sortOrder = SortOrder.desc,
    this.errorMessage,
    this.userCity,
    this.userCountry,
  });

  final HomeStatus status;
  final List<RestaurantEntity> restaurants;
  final List<RestaurantEntity> filteredRestaurants;
  final String query;
  final SortField? sortField;
  final SortOrder sortOrder;
  final String? errorMessage;
  final String? userCity;
  final String? userCountry;

  HomeState copyWith({
    HomeStatus? status,
    List<RestaurantEntity>? restaurants,
    List<RestaurantEntity>? filteredRestaurants,
    String? query,
    SortField? sortField,
    SortOrder? sortOrder,
    String? errorMessage,
    String? userCity,
    String? userCountry,
  }) {
    return HomeState(
      status: status ?? this.status,
      restaurants: restaurants ?? this.restaurants,
      filteredRestaurants: filteredRestaurants ?? this.filteredRestaurants,
      query: query ?? this.query,
      sortField: sortField ?? this.sortField,
      sortOrder: sortOrder ?? this.sortOrder,
      errorMessage: errorMessage ?? this.errorMessage,
      userCity: userCity ?? this.userCity,
      userCountry: userCountry ?? this.userCountry,
    );
  }

  @override
  List<Object?> get props => [
      status,
      restaurants,
      filteredRestaurants,
      query,
      sortField,
      sortOrder,
      errorMessage,
      userCity,
      userCountry,
      ];
}
