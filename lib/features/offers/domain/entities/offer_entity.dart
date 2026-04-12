import 'package:equatable/equatable.dart';

import '../../../../core/utils/guest_pricing_utils.dart' as guest_pricing;

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
    this.guestPricingMode = '',
    this.mealType = '',
    this.packageName = '',
    this.packageDescription = '',
    this.titleEn = '',
    this.titleAr = '',
    this.entryConditionsEn = const [],
    this.entryConditionsAr = const [],
    this.packageNameEn = '',
    this.packageNameAr = '',
    this.packageDescriptionEn = '',
    this.packageDescriptionAr = '',
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
  final String guestPricingMode;
  final String mealType;
  final String packageName;
  final String packageDescription;
  final String titleEn;
  final String titleAr;
  final List<String> entryConditionsEn;
  final List<String> entryConditionsAr;
  final String packageNameEn;
  final String packageNameAr;
  final String packageDescriptionEn;
  final String packageDescriptionAr;

  int get remainingAdult => capacityAdult - bookedAdult;
  int get remainingChild => capacityChild - bookedChild;
  String get resolvedGuestPricingMode =>
      guest_pricing.normalizeGuestPricingMode(
        guestPricingMode,
        bookingCategory: bookingCategory,
        bookableType: bookableType,
      );
  bool get usesUnifiedGuestCount => guest_pricing.usesUnifiedGuestCount(
    guestPricingMode: guestPricingMode,
    bookingCategory: bookingCategory,
    bookableType: bookableType,
  );

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
    guestPricingMode,
    mealType,
    packageName,
    packageDescription,
    titleEn,
    titleAr,
    entryConditionsEn,
    entryConditionsAr,
    packageNameEn,
    packageNameAr,
    packageDescriptionEn,
    packageDescriptionAr,
  ];
}
