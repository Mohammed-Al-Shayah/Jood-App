import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'package:jood/core/di/service_locator.dart';
import 'package:jood/core/routing/app_router.dart';
import 'package:jood/core/routing/routes.dart';
import 'package:jood/core/utils/extensions.dart';
import 'package:jood/core/theming/app_colors.dart';
import 'package:jood/core/theming/app_text_styles.dart';
import 'package:jood/core/utils/app_strings.dart';
import 'package:jood/core/widgets/bottom_cta_bar.dart';
import 'package:jood/features/offers/domain/entities/offer_entity.dart';
import '../cubit/booking_flow_cubit.dart';
import '../cubit/booking_flow_state.dart';
import '../widgets/date_strip.dart';
import '../widgets/date_utils.dart';
import '../widgets/offer_card.dart';
import '../widgets/calendar_sheet.dart';
import '../widgets/select_date_header.dart';

class SelectDateTimeScreen extends StatelessWidget {
  const SelectDateTimeScreen({
    super.key,
    required this.name,
    required this.restaurantId,
  });

  final String name;
  final String restaurantId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<BookingFlowCubit>()..initialize(restaurantId: restaurantId),
      child: Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar:
            BlocSelector<BookingFlowCubit, BookingFlowState, int?>(
              selector: (state) => state.selectedOfferIndex,
              builder: (context, selectedIndex) {
                if (selectedIndex == null) return const SizedBox.shrink();
                return BottomCtaBar(
                  label: 'Next',
                  onPressed: () {
                    context.pushNamed(
                      Routes.selectGuestsScreen,
                      arguments: SelectGuestsArgs(
                        restaurantName: name,
                        cubit: context.read<BookingFlowCubit>(),
                      ),
                    );
                  },
                  backgroundColor: Colors.white,
                  shadowColor: AppColors.shadowColor,
                  textStyle: AppTextStyles.cta,
                  buttonColor: AppColors.primary,
                );
              },
            ),
        body: SafeArea(
          child: Column(
            children: [
              SelectDateHeader(
                title: AppStrings.selectDateTitle,
                subtitle: name,
                onBack: () => Navigator.of(context).pop(),
              ),
              SizedBox(height: 12.h),
              Expanded(
                child: BlocBuilder<BookingFlowCubit, BookingFlowState>(
                  buildWhen: (previous, current) {
                    return previous.status != current.status ||
                        previous.dates != current.dates ||
                        previous.selectedDate != current.selectedDate ||
                        previous.selectedDateIndex !=
                            current.selectedDateIndex ||
                        previous.offers != current.offers ||
                        previous.selectedOfferIndex !=
                            current.selectedOfferIndex ||
                        previous.datePrices != current.datePrices ||
                        previous.currency != current.currency ||
                        previous.errorMessage != current.errorMessage;
                  },
                  builder: (context, state) {
                    final selectedLabel = formatOfferDate(state.selectedDate);
                    final selectedIndex = state.selectedOfferIndex;
                    final isLoading = state.status == BookingFlowStatus.loading;
                    final offers = isLoading ? _skeletonOffers() : state.offers;

                    return Skeletonizer(
                      enabled: isLoading,
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 86.h,
                              child: DateStrip(
                                dates: state.dates,
                                selectedIndex: state.selectedDateIndex,
                                onDateTap: (index) => context
                                    .read<BookingFlowCubit>()
                                    .selectDate(index),
                                onMoreTap: () => _openDatePicker(context),
                                datePrices: state.datePrices,
                                currency: state.currency,
                              ),
                            ),
                            SizedBox(height: 20.h),
                            Text(
                              '${AppStrings.availableOffersFor} $selectedLabel',
                              style: AppTextStyles.sectionTitle.copyWith(
                                fontSize: 18.sp,
                              ),
                            ),
                            SizedBox(height: 24.h),
                            if (state.status == BookingFlowStatus.failure)
                              Text(
                                state.errorMessage ?? 'Failed to load offers.',
                                style: AppTextStyles.cardMeta,
                              ),
                            if (state.status == BookingFlowStatus.ready &&
                                state.offers.isEmpty)
                              Column(
                                children: [
                                  SizedBox(height: 200.h),
                                  Center(
                                    child: Text(
                                      'No offers available for this date.',
                                      style: AppTextStyles.cardMeta.copyWith(
                                        fontSize: 16.sp,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ...offers.asMap().entries.map((entry) {
                              final index = entry.key;
                              final offer = entry.value;
                              return Padding(
                                padding: EdgeInsets.only(bottom: 12.h),
                                child: OfferCard(
                                  offer: offer,
                                  isSelected:
                                      !isLoading && selectedIndex == index,
                                  statusLabel: _statusLabel(offer),
                                  statusColor: _statusColor(offer),
                                  onTap: isLoading || _isUnavailable(offer)
                                      ? null
                                      : () => context
                                            .read<BookingFlowCubit>()
                                            .toggleOffer(index),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openDatePicker(BuildContext context) async {
    final cubit = context.read<BookingFlowCubit>();
    final now = DateTime.now();
    final currency = _currencyFromState(cubit.state);

    final picked = await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (_) => CalendarSheet(
        initialMonth: DateTime(now.year, now.month, 1),
        selectedDate: cubit.state.selectedDate,
        monthCount: 12,
        currency: currency,
        pricesLoader: (month) => cubit.loadDiscountPricesForMonth(month),
      ),
    );

    if (picked == null) return;
    await cubit.selectCustomDate(
      DateTime(picked.year, picked.month, picked.day),
    );
  }
}

String _statusLabel(OfferEntity offer) {
  final remaining = _remainingTotal(offer);
  final availability = _availabilityFor(offer);
  switch (availability) {
    case _OfferAvailability.available:
      return '$remaining ${AppStrings.ticketsAvailable}';
    case _OfferAvailability.low:
      return '${AppStrings.onlyTicketsLeft} $remaining ${AppStrings.ticketsAvailable}';
    case _OfferAvailability.soldOut:
      return AppStrings.soldOut;
    case _OfferAvailability.expired:
      return AppStrings.offerEnded;
  }
}

Color _statusColor(OfferEntity offer) {
  switch (_availabilityFor(offer)) {
    case _OfferAvailability.available:
      return const Color(0xFF2E9A76);
    case _OfferAvailability.low:
      return const Color(0xFFE28B25);
    case _OfferAvailability.soldOut:
      return const Color(0xFFDD5A5A);
    case _OfferAvailability.expired:
      return const Color(0xFF9E9E9E);
  }
}

bool _isUnavailable(OfferEntity offer) {
  final availability = _availabilityFor(offer);
  return availability == _OfferAvailability.soldOut ||
      availability == _OfferAvailability.expired;
}

_OfferAvailability _availabilityFor(OfferEntity offer) {
  if (_isExpired(offer)) return _OfferAvailability.expired;
  final status = offer.status.toLowerCase().replaceAll(' ', '');
  final remaining = _remainingTotal(offer);
  if (remaining <= 0) return _OfferAvailability.soldOut;
  if (status.contains('soldout') || status.contains('sold_out')) {
    return _OfferAvailability.soldOut;
  }
  if (status.contains('low')) {
    return _OfferAvailability.low;
  }
  if (remaining <= 3) return _OfferAvailability.low;
  return _OfferAvailability.available;
}

enum _OfferAvailability { available, low, soldOut, expired }

int _remainingTotal(OfferEntity offer) {
  final totalCapacity = offer.capacityAdult + offer.capacityChild;
  final totalBooked = offer.bookedAdult + offer.bookedChild;
  final remaining = totalCapacity - totalBooked;
  return remaining < 0 ? 0 : remaining;
}

bool _isExpired(OfferEntity offer) {
  final date = _parseOfferDate(offer.date);
  if (date == null) return false;
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  if (date.isBefore(today)) return true;
  if (date.isAfter(today)) return false;
  final endMinutes =
      _parseTimeToMinutes(offer.endTime) ??
      _parseTimeToMinutes(offer.startTime);
  if (endMinutes == null) return false;
  final nowMinutes = now.hour * 60 + now.minute;
  return nowMinutes >= endMinutes;
}

DateTime? _parseOfferDate(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return null;
  final parsed = DateTime.tryParse(trimmed);
  if (parsed == null) return null;
  return DateTime(parsed.year, parsed.month, parsed.day);
}

int? _parseTimeToMinutes(String value) {
  final trimmed = value.trim().toLowerCase();
  if (trimmed.isEmpty) return null;
  final amPmMatch = RegExp(
    r'^(\d{1,2})(?::(\d{2}))?\s*([ap]m)$',
  ).firstMatch(trimmed);
  if (amPmMatch != null) {
    final hour = int.tryParse(amPmMatch.group(1) ?? '');
    final minute = int.tryParse(amPmMatch.group(2) ?? '0') ?? 0;
    final period = amPmMatch.group(3);
    if (hour == null) return null;
    var h = hour % 12;
    if (period == 'pm') h += 12;
    return h * 60 + minute;
  }
  final match24 = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(trimmed);
  if (match24 != null) {
    final hour = int.tryParse(match24.group(1) ?? '');
    final minute = int.tryParse(match24.group(2) ?? '');
    if (hour == null || minute == null) return null;
    return hour * 60 + minute;
  }
  return null;
}

List<OfferEntity> _skeletonOffers() {
  final now = DateTime.now();
  return [
    OfferEntity(
      id: 'skeleton-1',
      restaurantId: 'skeleton',
      date: now.toIso8601String(),
      startTime: '12:00 PM',
      endTime: '02:00 PM',
      currency: r'$',
      priceAdult: 120,
      priceAdultOriginal: 145,
      priceChild: 80,
      capacityAdult: 20,
      capacityChild: 10,
      bookedAdult: 0,
      bookedChild: 0,
      status: 'Available',
      title: 'Buffet Entry',
      entryConditions: const ['Entry condition'],
      createdAt: now,
      updatedAt: now,
    ),
    OfferEntity(
      id: 'skeleton-2',
      restaurantId: 'skeleton',
      date: now.toIso8601String(),
      startTime: '04:00 PM',
      endTime: '06:00 PM',
      currency: r'$',
      priceAdult: 140,
      priceAdultOriginal: 170,
      priceChild: 90,
      capacityAdult: 20,
      capacityChild: 10,
      bookedAdult: 0,
      bookedChild: 0,
      status: 'Available',
      title: 'Buffet Entry',
      entryConditions: const ['Entry condition'],
      createdAt: now,
      updatedAt: now,
    ),
  ];
}

String _currencyFromState(BookingFlowState state) {
  if (state.offers.isEmpty) return 'AED';
  final currency = state.offers.first.currency.trim();
  return currency.isEmpty ? 'AED' : currency;
}
