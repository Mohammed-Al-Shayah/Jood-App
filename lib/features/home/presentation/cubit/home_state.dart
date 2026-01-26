import 'package:equatable/equatable.dart';

import '../../domain/entities/restaurant.dart';

enum HomeStatus { initial, loading, success, empty, failure }

class HomeState extends Equatable {
  const HomeState({
    this.status = HomeStatus.initial,
    this.restaurants = const [],
    this.errorMessage,
  });

  final HomeStatus status;
  final List<Restaurant> restaurants;
  final String? errorMessage;

  HomeState copyWith({
    HomeStatus? status,
    List<Restaurant>? restaurants,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      restaurants: restaurants ?? this.restaurants,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, restaurants, errorMessage];
}
