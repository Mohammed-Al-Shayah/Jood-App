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
  }) async {
    _restaurantId = restaurantId;
    _bookingCategory = bookingCategory.trim().toLowerCase();
    final dates = _buildDates();
    final selectedDate = dates.first;
    _emitIfOpen(
      state.copyWith(
        status: BookingFlowStatus.loading,
        dates: dates,
        selectedDate: selectedDate,
        selectedDateIndex: 0,
      ),
    );
    await _loadDateStripPrices(dates);
    await _loadOffersForDate(selectedDate);
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
    _emitIfOpen(
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

  List<DateTime> _buildDates() {
    final now = DateTime.now();
    return List.generate(5, (index) {
      final base = DateTime(now.year, now.month, now.day);
      return base.add(Duration(days: index));
    });
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
}
