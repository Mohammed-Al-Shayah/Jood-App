import 'package:jood/features/offers/domain/entities/offer_entity.dart';

enum BookingFlowStatus { initial, loading, ready, failure }

class BookingFlowState {
  static const _unset = Object();

  const BookingFlowState({
    required this.status,
    required this.dates,
    required this.selectedDate,
    required this.selectedDateIndex,
    required this.offers,
    required this.selectedOfferIndex,
    required this.adultCount,
    required this.childCount,
    required this.datePrices,
    required this.currency,
    this.errorMessage,
  });

  final BookingFlowStatus status;
  final List<DateTime> dates;
  final DateTime selectedDate;
  final int selectedDateIndex;
  final List<OfferEntity> offers;
  final int? selectedOfferIndex;
  final int adultCount;
  final int childCount;
  final Map<String, double> datePrices;
  final String currency;
  final String? errorMessage;

  BookingFlowState copyWith({
    BookingFlowStatus? status,
    List<DateTime>? dates,
    DateTime? selectedDate,
    int? selectedDateIndex,
    List<OfferEntity>? offers,
    Object? selectedOfferIndex = _unset,
    int? adultCount,
    int? childCount,
    Map<String, double>? datePrices,
    String? currency,
    Object? errorMessage = _unset,
  }) {
    return BookingFlowState(
      status: status ?? this.status,
      dates: dates ?? this.dates,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedDateIndex: selectedDateIndex ?? this.selectedDateIndex,
      offers: offers ?? this.offers,
      selectedOfferIndex: selectedOfferIndex == _unset
          ? this.selectedOfferIndex
          : selectedOfferIndex as int?,
      adultCount: adultCount ?? this.adultCount,
      childCount: childCount ?? this.childCount,
      datePrices: datePrices ?? this.datePrices,
      currency: currency ?? this.currency,
      errorMessage: errorMessage == _unset ? this.errorMessage : errorMessage as String?,
    );
  }

  static BookingFlowState initial() {
    return BookingFlowState(
      status: BookingFlowStatus.initial,
      dates: const [],
      selectedDate: DateTime.now(),
      selectedDateIndex: 0,
      offers: const [],
      selectedOfferIndex: null,
      adultCount: 1,
      childCount: 0,
      datePrices: const {},
      currency: '',
      errorMessage: null,
    );
  }
}

extension BookingFlowStateX on BookingFlowState {
  OfferEntity? selectedOffer() {
    final index = selectedOfferIndex;
    if (index == null) return null;
    if (index < 0 || index >= offers.length) return null;
    return offers[index];
  }
}


