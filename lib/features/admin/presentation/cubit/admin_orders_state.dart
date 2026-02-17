import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../../restaurants/domain/entities/restaurant_entity.dart';

enum AdminOrdersStatus { initial, loading, success, failure }

class AdminOrdersState extends Equatable {
  const AdminOrdersState({
    this.status = AdminOrdersStatus.initial,
    this.restaurants = const [],
    this.selectedRestaurantId = '',
    this.dateRange,
    this.errorMessage,
  });

  final AdminOrdersStatus status;
  final List<RestaurantEntity> restaurants;
  final String selectedRestaurantId;
  final DateTimeRange? dateRange;
  final String? errorMessage;

  bool get hasFilters =>
      selectedRestaurantId.trim().isNotEmpty || dateRange != null;

  static const _dateRangeSentinel = Object();

  AdminOrdersState copyWith({
    AdminOrdersStatus? status,
    List<RestaurantEntity>? restaurants,
    String? selectedRestaurantId,
    Object? dateRange = _dateRangeSentinel,
    String? errorMessage,
  }) {
    return AdminOrdersState(
      status: status ?? this.status,
      restaurants: restaurants ?? this.restaurants,
      selectedRestaurantId: selectedRestaurantId ?? this.selectedRestaurantId,
      dateRange: dateRange == _dateRangeSentinel
          ? this.dateRange
          : dateRange as DateTimeRange?,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        restaurants,
        selectedRestaurantId,
        dateRange,
        errorMessage,
      ];
}
