import 'package:equatable/equatable.dart';

import '../../domain/entities/restaurant.dart';

enum HomeStatus { initial, loading, success, empty, failure }

class HomeState extends Equatable {
  const HomeState({
    this.status = HomeStatus.initial,
    this.restaurants = const [],
    this.errorMessage,
    this.userCity,
    this.userCountry,
  });

  final HomeStatus status;
  final List<Restaurant> restaurants;
  final String? errorMessage;
  final String? userCity;
  final String? userCountry;

  HomeState copyWith({
    HomeStatus? status,
    List<Restaurant>? restaurants,
    String? errorMessage,
    String? userCity,
    String? userCountry,
  }) {
    return HomeState(
      status: status ?? this.status,
      restaurants: restaurants ?? this.restaurants,
      errorMessage: errorMessage ?? this.errorMessage,
      userCity: userCity ?? this.userCity,
      userCountry: userCountry ?? this.userCountry,
    );
  }

  @override
  List<Object?> get props => [
        status,
        restaurants,
        errorMessage,
        userCity,
        userCountry,
      ];
}
