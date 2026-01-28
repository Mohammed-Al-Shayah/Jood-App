import '../../../offers/domain/entities/offer_entity.dart';

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
      errorMessage: null,
    );
  }
}
