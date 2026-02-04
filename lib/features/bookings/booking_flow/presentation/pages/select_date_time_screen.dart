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
      child: BlocBuilder<BookingFlowCubit, BookingFlowState>(
        builder: (context, state) {
          final selectedLabel = formatOfferDate(state.selectedDate);
          final selectedIndex = state.selectedOfferIndex;
          final isLoading = state.status == BookingFlowStatus.loading;
          final offers = isLoading ? _skeletonOffers() : state.offers;

          return Scaffold(
            backgroundColor: Colors.white,
            bottomNavigationBar: selectedIndex == null
                ? null
                : BottomCtaBar(
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
                    child: Skeletonizer(
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
                                  onTap: isLoading || _isSoldOut(offer)
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
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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
  }
}

bool _isSoldOut(OfferEntity offer) {
  return _availabilityFor(offer) == _OfferAvailability.soldOut;
}

_OfferAvailability _availabilityFor(OfferEntity offer) {
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

enum _OfferAvailability { available, low, soldOut }

int _remainingTotal(OfferEntity offer) {
  final totalCapacity = offer.capacityAdult + offer.capacityChild;
  final totalBooked = offer.bookedAdult + offer.bookedChild;
  final remaining = totalCapacity - totalBooked;
  return remaining < 0 ? 0 : remaining;
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
