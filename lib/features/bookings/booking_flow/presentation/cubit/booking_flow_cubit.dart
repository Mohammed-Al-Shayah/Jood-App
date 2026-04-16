import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:jood/core/utils/app_strings.dart';
import 'package:jood/features/offers/domain/usecases/get_offers_for_date_usecase.dart';
import 'package:jood/features/offers/domain/usecases/get_offers_for_range_usecase.dart';
import 'package:jood/features/offers/domain/entities/offer_entity.dart';
import 'package:jood/core/utils/date_utils.dart';
import 'booking_flow_state.dart';

class BookingFlowCubit extends Cubit<BookingFlowState> {
  BookingFlowCubit({
    required this.getOffersForDate,
    required this.getOffersForRange,
  }) : super(BookingFlowState.initial());

  final GetOffersForDateUseCase getOffersForDate;
  final GetOffersForRangeUseCase getOffersForRange;
  String? _restaurantId;
  String _bookingCategory = '';

  Future<void> initialize({
    required String restaurantId,
    String bookingCategory = '',
    DateTime? initialDate,
    String? preferredOfferId,
  }) async {
    _restaurantId = restaurantId;
    _bookingCategory = bookingCategory.trim().toLowerCase();
    final selectedDate = _normalizedDate(initialDate ?? DateTime.now());
    final dates = _buildDates(initialDate: selectedDate);
    final selectedDateIndex = dates.indexWhere(
      (date) => _isSameDate(date, selectedDate),
    );
    _emitIfOpen(
      state.copyWith(
        status: BookingFlowStatus.loading,
        dates: dates,
        selectedDate: selectedDate,
        selectedDateIndex: selectedDateIndex < 0 ? 0 : selectedDateIndex,
      ),
    );
    await _loadDateStripPrices(dates);
    await _loadOffersForDate(selectedDate, preferredOfferId: preferredOfferId);
  }

  Future<void> selectDate(int index) async {
    final date = state.dates[index];
    _emitIfOpen(
      state.copyWith(
        selectedDate: date,
        selectedDateIndex: index,
        selectedOfferIndex: null,
      ),
    );
    await _loadOffersForDate(date);
  }

  Future<void> selectCustomDate(DateTime date) async {
    final normalizedDate = _normalizedDate(date);
    final dates = _mergedDates(state.dates, normalizedDate);
    final selectedIndex = dates.indexWhere(
      (candidate) => _isSameDate(candidate, normalizedDate),
    );
    _emitIfOpen(
      state.copyWith(
        dates: dates,
        selectedDate: normalizedDate,
        selectedDateIndex: selectedIndex < 0
            ? state.dates.length
            : selectedIndex,
        selectedOfferIndex: null,
      ),
    );
    await _loadDateStripPrices(dates);
    await _loadOffersForDate(normalizedDate);
  }

  void toggleOffer(int index) {
    final selected = state.selectedOfferIndex == index ? null : index;
    _emitIfOpen(state.copyWith(selectedOfferIndex: selected));
  }

  void selectOfferIndex(int? index) {
    _emitIfOpen(state.copyWith(selectedOfferIndex: index));
  }

  void clearSelectedOffer() {
    _emitIfOpen(state.copyWith(selectedOfferIndex: null));
  }

  void incrementAdults() {
    _emitIfOpen(state.copyWith(adultCount: state.adultCount + 1));
  }

  void decrementAdults() {
    if (state.adultCount <= 1) return;
    _emitIfOpen(state.copyWith(adultCount: state.adultCount - 1));
  }

  void incrementChildren() {
    _emitIfOpen(state.copyWith(childCount: state.childCount + 1));
  }

  void decrementChildren() {
    if (state.childCount <= 0) return;
    _emitIfOpen(state.copyWith(childCount: state.childCount - 1));
  }

  void setGuestCounts({required int adults, required int children}) {
    _emitIfOpen(
      state.copyWith(
        adultCount: adults < 0 ? 0 : adults,
        childCount: children < 0 ? 0 : children,
      ),
    );
  }

  void setAdultCount(int value) {
    _emitIfOpen(state.copyWith(adultCount: value < 0 ? 0 : value));
  }

  void setChildCount(int value) {
    _emitIfOpen(state.copyWith(childCount: value < 0 ? 0 : value));
  }

  Future<bool> refreshSelectedDate() async {
    final selectedId = state.selectedOffer()?.id;
    await _loadOffersForDate(state.selectedDate, preferredOfferId: selectedId);
    return state.selectedOffer()?.id == selectedId;
  }

  Future<void> _loadOffersForDate(
    DateTime date, {
    String? preferredOfferId,
  }) async {
    final restaurantId = _restaurantId;
    if (restaurantId == null) {
      _emitIfOpen(
        state.copyWith(
          status: BookingFlowStatus.failure,
          errorMessage: AppStrings.missingRestaurantId,
          offers: const [],
        ),
      );
      return;
    }
    try {
      final offers = await getOffersForDate(
        restaurantId,
        AppDateUtils.formatDate(date),
      );
      final filteredOffers = offers.where(_matchesBookingCategory).toList();
      int? selectedOfferIndex = state.selectedOfferIndex;
      if (preferredOfferId != null && preferredOfferId.isNotEmpty) {
        selectedOfferIndex = filteredOffers.indexWhere(
          (offer) => offer.id == preferredOfferId,
        );
        if (selectedOfferIndex < 0) {
          selectedOfferIndex = null;
        }
      } else if (selectedOfferIndex != null &&
          (selectedOfferIndex < 0 ||
              selectedOfferIndex >= filteredOffers.length)) {
        selectedOfferIndex = null;
      }
      _emitIfOpen(
        state.copyWith(
          status: BookingFlowStatus.ready,
          offers: filteredOffers,
          selectedOfferIndex: selectedOfferIndex,
          currency: _resolveCurrency(filteredOffers, state.currency),
          errorMessage: null,
        ),
      );
    } catch (error) {
      _emitIfOpen(
        state.copyWith(
          status: BookingFlowStatus.failure,
          errorMessage: null,
          offers: const [],
        ),
      );
    }
  }

  List<DateTime> _buildDates({DateTime? initialDate}) {
    final base = _normalizedDate(DateTime.now());
    final dates = List.generate(
      5,
      (index) => base.add(Duration(days: index)),
      growable: true,
    );
    if (initialDate != null) {
      return _mergedDates(dates, initialDate);
    }
    return dates;
  }

  // Date formatting moved to DateUtils

  Future<Map<String, double>> loadDiscountPricesForMonth(DateTime month) async {
    final restaurantId = _restaurantId;
    if (restaurantId == null) return {};

    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 0);
    final startKey = AppDateUtils.formatDate(start);
    final endKey = AppDateUtils.formatDate(end);

    final offers = await getOffersForRange(restaurantId, startKey, endKey);
    final prices = <String, double>{};

    for (final offer in offers) {
      if (!_matchesBookingCategory(offer)) continue;
      final dayKey = offer.date;
      final candidate = offer.priceAdult;
      final current = prices[dayKey];
      if (current == null || candidate < current) {
        prices[dayKey] = candidate;
      }
    }

    return prices;
  }

  Future<void> _loadDateStripPrices(List<DateTime> dates) async {
    final restaurantId = _restaurantId;
    if (restaurantId == null || dates.isEmpty) return;
    final startKey = AppDateUtils.formatDate(dates.first);
    final endKey = AppDateUtils.formatDate(dates.last);
    try {
      final offers = await getOffersForRange(restaurantId, startKey, endKey);
      final prices = <String, double>{};
      var currency = state.currency;
      for (final offer in offers) {
        if (!_matchesBookingCategory(offer)) continue;
        if (currency.isEmpty && offer.currency.trim().isNotEmpty) {
          currency = offer.currency.trim();
        }
        final dayKey = offer.date;
        final candidate = offer.priceAdult;
        final current = prices[dayKey];
        if (current == null || candidate < current) {
          prices[dayKey] = candidate;
        }
      }
      _emitIfOpen(state.copyWith(datePrices: prices, currency: currency));
    } catch (_) {
      // Ignore date strip pricing failures.
    }
  }

  bool _matchesBookingCategory(OfferEntity offer) {
    if (_bookingCategory.isEmpty) return true;
    final raw = offer.bookingCategory.trim().toLowerCase().replaceAll(' ', '_');
    if (_bookingCategory == 'buffet') {
      return raw.isEmpty || raw == 'buffet';
    }
    if (_bookingCategory == 'set_menu') {
      return raw == 'set_menu' || raw == 'setmenu';
    }
    if (_bookingCategory == 'combo') {
      return raw == 'combo';
    }
    if (_bookingCategory == 'attraction') {
      final type = offer.bookableType.trim().toLowerCase();
      return raw == 'attraction' || type == 'attraction';
    }
    return raw == _bookingCategory;
  }

  String _resolveCurrency(List<OfferEntity> offers, String fallback) {
    for (final offer in offers) {
      if (offer.currency.trim().isNotEmpty) {
        return offer.currency.trim();
      }
    }
    return fallback;
  }

  void _emitIfOpen(BookingFlowState nextState) {
    if (isClosed) return;
    emit(nextState);
  }

  List<DateTime> _mergedDates(List<DateTime> dates, DateTime date) {
    final normalized = _normalizedDate(date);
    if (dates.any((candidate) => _isSameDate(candidate, normalized))) {
      return dates;
    }
    final next = List<DateTime>.from(dates)..add(normalized);
    next.sort((left, right) => left.compareTo(right));
    return next;
  }

  DateTime _normalizedDate(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  bool _isSameDate(DateTime left, DateTime right) {
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }
}
