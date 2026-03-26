import 'package:equatable/equatable.dart';

class OfferEntity extends Equatable {
  const OfferEntity({
    required this.id,
    required this.restaurantId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.currency,
    required this.priceAdult,
    required this.priceAdultOriginal,
    required this.priceChild,
    required this.capacityAdult,
    required this.capacityChild,
    required this.bookedAdult,
    required this.bookedChild,
    required this.status,
    required this.title,
    required this.entryConditions,
    required this.createdAt,
    required this.updatedAt,
    this.bookingCategory = '',
    this.bookableType = 'restaurant',
    this.mealType = '',
    this.packageName = '',
    this.packageDescription = '',
  });

  final String id;
  final String restaurantId;
  final String date;
  final String startTime;
  final String endTime;
  final String currency;
  final double priceAdult;
  final double priceAdultOriginal;
  final double priceChild;
  final int capacityAdult;
  final int capacityChild;
  final int bookedAdult;
  final int bookedChild;
  final String status;
  final String title;
  final List<String> entryConditions;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String bookingCategory;
  final String bookableType;
  final String mealType;
  final String packageName;
  final String packageDescription;

  int get remainingAdult => capacityAdult - bookedAdult;
  int get remainingChild => capacityChild - bookedChild;

  @override
  List<Object?> get props => [
        id,
        restaurantId,
        date,
        startTime,
        endTime,
        currency,
        priceAdult,
        priceAdultOriginal,
        priceChild,
        capacityAdult,
        capacityChild,
        bookedAdult,
        bookedChild,
        status,
        title,
        entryConditions,
        createdAt,
        updatedAt,
        bookingCategory,
        bookableType,
        mealType,
        packageName,
        packageDescription,
      ];
}
