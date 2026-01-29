import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:jood/features/offers/domain/usecases/get_offers_for_date_usecase.dart';
import 'package:jood/features/offers/domain/usecases/get_offers_for_range_usecase.dart';
import 'booking_flow_state.dart';

class BookingFlowCubit extends Cubit<BookingFlowState> {
  BookingFlowCubit({
    required this.getOffersForDate,
    required this.getOffersForRange,
  }) : super(BookingFlowState.initial());

  final GetOffersForDateUseCase getOffersForDate;
  final GetOffersForRangeUseCase getOffersForRange;
  String? _restaurantId;

  Future<void> initialize({required String restaurantId}) async {
    _restaurantId = restaurantId;
    final dates = _buildDates();
    final selectedDate = dates.first;
    emit(
      state.copyWith(
        status: BookingFlowStatus.loading,
        dates: dates,
        selectedDate: selectedDate,
        selectedDateIndex: 0,
      ),
    );
    await _loadOffersForDate(selectedDate);
  }

  Future<void> selectDate(int index) async {
    final date = state.dates[index];
    emit(
      state.copyWith(
        selectedDate: date,
        selectedDateIndex: index,
        selectedOfferIndex: null,
      ),
    );
    await _loadOffersForDate(date);
  }

  Future<void> selectCustomDate(DateTime date) async {
    emit(
      state.copyWith(
        selectedDate: date,
        selectedDateIndex: state.dates.length,
        selectedOfferIndex: null,
      ),
    );
    await _loadOffersForDate(date);
  }

  void toggleOffer(int index) {
    final selected = state.selectedOfferIndex == index ? null : index;
    emit(state.copyWith(selectedOfferIndex: selected));
  }

  void incrementAdults() {
    emit(state.copyWith(adultCount: state.adultCount + 1));
  }

  void decrementAdults() {
    if (state.adultCount <= 1) return;
    emit(state.copyWith(adultCount: state.adultCount - 1));
  }

  void incrementChildren() {
    emit(state.copyWith(childCount: state.childCount + 1));
  }

  void decrementChildren() {
    if (state.childCount <= 0) return;
    emit(state.copyWith(childCount: state.childCount - 1));
  }

  Future<void> _loadOffersForDate(DateTime date) async {
    final restaurantId = _restaurantId;
    if (restaurantId == null) {
      emit(
        state.copyWith(
          status: BookingFlowStatus.failure,
          errorMessage: 'Missing restaurant id.',
          offers: const [],
        ),
      );
      return;
    }
    try {
      final offers = await getOffersForDate(restaurantId, _formatDate(date));
      emit(
        state.copyWith(
          status: BookingFlowStatus.ready,
          offers: offers,
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: BookingFlowStatus.failure,
          errorMessage: error.toString(),
          offers: const [],
        ),
      );
    }
  }

  List<DateTime> _buildDates() {
    final now = DateTime.now();
    return List.generate(5, (index) {
      final base = DateTime(now.year, now.month, now.day);
      return base.add(Duration(days: index));
    });
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  Future<Map<String, double>> loadDiscountPricesForMonth(DateTime month) async {
    final restaurantId = _restaurantId;
    if (restaurantId == null) return {};

    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 0);
    final startKey = _formatDate(start);
    final endKey = _formatDate(end);

    final offers = await getOffersForRange(restaurantId, startKey, endKey);
    final prices = <String, double>{};

    for (final offer in offers) {
      final dayKey = offer.date;
      final candidate = offer.priceAdult;
      final current = prices[dayKey];
      if (current == null || candidate < current) {
        prices[dayKey] = candidate;
      }
    }

    return prices;
  }
}
